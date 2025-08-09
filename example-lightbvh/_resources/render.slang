#include "srenderer/spt.slang"
#include "srenderer/materials.slang"
#include "common/random.slang"

#define MACRO_USE_MIS 1

enum EstimatorEnum {
    PATH_TRACING = 0,
    RATIO_CONTROL_VARIATE = 1,
    HARTLEY_ROSS = 2,
};

[[vk::push_constant]]
cbuffer PushConstants {
    EstimatorEnum estimator;
    int random_seed;
    int SPP; // Samples per pixel
};

RWTexture2D<float4> rw_output;

float3 path_tracing(
    Ray primary_ray, IntersectionPayload primary_payload, 
    inout random::RandomSampler sampler
) {
    // If the primary ray hit nothing, return the background color (black):
    if (!primary_payload.hit.has_hit()) return float3(0, 0, 0);

    float3 radiance = primary_payload.emission();

    if (let ls = primary_payload.light_sample(primary_ray, sampler.next_float3())) {
        Ray shadow_ray = primary_payload.hit.spawn_visibility_ray(ls.x);
        if (visibility_ray_query(shadow_ray)) {
            float3 bsdf = primary_payload.bsdf_eval(-primary_ray.direction, shadow_ray.direction);
            float bsdf_pdf = primary_payload.bsdf_pdf(-primary_ray.direction, shadow_ray.direction);
            #if MACRO_USE_MIS == 1
            radiance += bsdf * ls.L / (ls.pdf + bsdf_pdf);
            #else
            radiance += bsdf * ls.L / ls.pdf;
            #endif
        }
    }
    
    #if MACRO_USE_MIS == 1
    // If the primary ray hit something, sample the BSDF:
    if (let bs = primary_payload.bsdf_sample(primary_ray, sampler.next_float3())) {
        Ray ray = primary_payload.hit.spawn_ray(bs.wo);
        IntersectionPayload payload = intersection_ray_query(ray);
        if (payload.hit.has_hit()) {
            // If the ray hit something, accumulate the radiance:
            float light_pdf = primary_payload.light_pdf(payload);
            radiance += bs.bsdf * payload.emission() / (bs.pdf + light_pdf);
        }
    }
    #endif

    return radiance;
}

struct PathStatistics {
    float3 f_brdf;
    float3 f_nee;
    float3 h_brdf;
    float3 h_nee;
    float3 f_emission;
};

PathStatistics ratio_estimator(
    Ray primary_ray, IntersectionPayload primary_payload,
    inout random::RandomSampler sampler
) {
    PathStatistics stats;
    stats.f_brdf = float3(0.f, 0.f, 0.f);
    stats.f_nee = float3(0.f, 0.f, 0.f);
    stats.h_brdf = float3(1.f, 1.f, 1.f);
    stats.h_nee = float3(1.f, 1.f, 1.f);
    stats.f_emission = float3(0.f, 0.f, 0.f);

    // If the primary ray hit nothing, return the background color (black):
    if (!primary_payload.hit.has_hit()) return stats;
    stats.f_emission += primary_payload.emission();

    if(!primary_payload.material().hasValue) return stats;

    float3 per_channel_pdf_nee;
    if (let ls = primary_payload.light_sample_with_perchannel_pdf(primary_ray, sampler.next_float3(), per_channel_pdf_nee)) {
        Ray shadow_ray = primary_payload.hit.spawn_visibility_ray(ls.x);
        stats.h_nee = per_channel_pdf_nee / ls.pdf; // Control variate for NEE
        if (visibility_ray_query(shadow_ray)) {
            float3 bsdf = primary_payload.bsdf_eval(-primary_ray.direction, shadow_ray.direction);
            float bsdf_pdf = primary_payload.bsdf_pdf(-primary_ray.direction, shadow_ray.direction);
            #if MACRO_USE_MIS == 1
            stats.f_nee = bsdf * ls.L / (ls.pdf + bsdf_pdf);
            #else
            stats.f_nee = bsdf * ls.L / ls.pdf;
            #endif
        }
    }
    
    // If the primary ray hit something, sample the BSDF:
    #if MACRO_USE_MIS == 1
    float3 per_channel_pdf_brdf;
    if (let bs = primary_payload.bsdf_sample_with_perchannel_pdf(primary_ray, sampler.next_float3(), per_channel_pdf_brdf)) {
        Ray ray = primary_payload.hit.spawn_ray(bs.wo);
        IntersectionPayload payload = intersection_ray_query(ray);
        stats.h_brdf = per_channel_pdf_brdf / bs.pdf; // Control variate for BRDF
        if (payload.hit.has_hit()) {
            // If the ray hit something, accumulate the radiance:
            float light_pdf = primary_payload.light_pdf(payload);
            stats.f_brdf += bs.bsdf * payload.emission() / (bs.pdf + light_pdf);
        }
    }
    #endif
    
    // BSDF sample failed, should not happen in this example
    return stats;
}


[shader("compute")]
[numthreads(32, 4, 1)]
[require(spirv, rayquery)]
void ComputeMain(
    int3 dtid: SV_DispatchThreadID,
    int3 gtid: SV_GroupThreadID,
    int3 gid: SV_GroupID,
    int gi: SV_GroupIndex
) {
    // The resolution of the image, which is the same as the launch size:
    int2 resolution; rw_output.GetDimensions(resolution.x, resolution.y);
    const int2 pixel = int2(dtid.xy);
    // If the pixel is outside of the image, don't do anything:
    if (any(pixel >= resolution)) return;
    // Initialize the random sampler with the pixel coordinates and a random seed:
    random::RandomSampler sampler = random::init_random_sampler(pixel, random_seed);

    // Spawn and trace the primary ray:
    CameraData camera = scene_read_camera(0);
    Ray ray = camera.spawn(pixel, resolution, false);
    IntersectionPayload payload = intersection_ray_query(ray);

    float3 output = float3(0, 0, 0);

    switch (estimator) {
    case EstimatorEnum::PATH_TRACING: {
        // In baseline, we compute the average of f
        float3 f = float3(0, 0, 0);
        for (int i = 0; i < SPP; ++i)
            f += path_tracing(ray, payload, sampler);
        output = f / SPP;
    }   
        break;
    case EstimatorEnum::RATIO_CONTROL_VARIATE: {
        // In RCV, we compute average f / average h
        float3 f_nee = float3(0, 0, 0); float3 f_brdf = float3(0, 0, 0);
        float3 h_nee = float3(0, 0, 0); float3 h_brdf = float3(0, 0, 0);
        float3 f_emission = float3(0, 0, 0);
        for (int i = 0; i < SPP; ++i) {
            PathStatistics stats = ratio_estimator(ray, payload, sampler);
            f_nee += stats.f_nee; f_brdf += stats.f_brdf;
            h_nee += stats.h_nee; h_brdf += stats.h_brdf;
            f_emission += stats.f_emission;
        }
        f_nee /= SPP; f_brdf /= SPP;
        h_nee /= SPP; h_brdf /= SPP;
        f_emission /= SPP;
        // we quickly hack the case h == 0 here to avoid division by zero
        // by making it one, if h is zero, which falls back to the standard MC.
        // Alternative way (defensive h, as disccused in appendix),
        // is shown below for HR:
        h_nee = select(h_nee == 0, float3(1, 1, 1), h_nee);
        h_brdf = select(h_brdf == 0, float3(1, 1, 1), h_brdf);
        // Finally, we compute the output as f / h
        output = f_nee / h_nee + f_brdf / h_brdf + f_emission;
    }
        break;
    case EstimatorEnum::HARTLEY_ROSS: {
        // HR needs at least 2 samples
        if (SPP <= 1) {
            output = float3(1, 0, 1);
            break;
        }

        // In HR, we additionally track f/h
        float3 f_nee = float3(0, 0, 0); float3 f_brdf = float3(0, 0, 0);
        float3 h_nee = float3(0, 0, 0); float3 h_brdf = float3(0, 0, 0);
        float3 f_emission = float3(0, 0, 0);
        float3 f_over_h_nee = float3(0, 0, 0); float3 f_over_h_brdf = float3(0, 0, 0);
        for (int i = 0; i < SPP; ++i) {
            PathStatistics stats = ratio_estimator(ray, payload, sampler);
            float3 cv_nee = 0.01 + 0.99 * stats.h_nee;
            float3 cv_brdf = 0.01 + 0.99 * stats.h_brdf; // Defensive h, as discussed in appendix
            f_brdf += stats.f_brdf; f_nee += stats.f_nee;
            h_brdf += cv_brdf; h_nee += cv_nee;
            f_over_h_brdf += stats.f_brdf / cv_brdf;
            f_over_h_nee += stats.f_nee / cv_nee;
            f_emission += stats.f_emission;
        }
        f_nee /= SPP; f_brdf /= SPP;
        h_nee /= SPP; h_brdf /= SPP;
        f_emission /= SPP;
        f_over_h_nee /= SPP; f_over_h_brdf /= SPP;
        
        output = f_over_h_nee + (SPP * 1.0 / (SPP - 1)) * (f_nee - f_over_h_nee * h_nee) +
                 f_over_h_brdf + (SPP * 1.0 / (SPP - 1)) * (f_brdf - f_over_h_brdf * h_brdf) + f_emission;
    }   
        break;
    }
    
    rw_output[pixel] = float4(output, 1);
}