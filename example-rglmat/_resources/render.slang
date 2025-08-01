#include "srenderer/spt.slang"
#include "srenderer/materials.slang"
#include "common/random.slang"
#include "common/override.slang"

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
    // If the primary ray hit nothing, return the background color (white):
    if (!primary_payload.hit.has_hit()) return float3(1, 1, 1);
    
    // If the primary ray hit something, sample the BSDF:
    if (let bs = primary_payload.bsdf_sample(primary_ray, sampler.next_float3())) {
        Ray ray = primary_payload.hit.spawn_ray(bs.wo);
        if (visibility_ray_query(ray)) return bs.bsdf / bs.pdf;
        else return float3(0, 0, 0);
    }
    // BSDF sample failed, should not happen in this example
    else return error_color;
}

float3 ratio_estimator(
    Ray primary_ray, IntersectionPayload primary_payload,
    inout random::RandomSampler sampler, out float3 cv
) {
    // Default control variate to one:
    cv = float3(1, 1, 1);
    // If the primary ray hit nothing, return the background color (white):
    if (!primary_payload.hit.has_hit()) return float3(1, 1, 1);
    
    // If the primary ray hit something, sample the BSDF:
    float3 per_channel_pdf = float3(1, 1, 1);
    if (let bs = primary_payload.bsdf_sample_with_perchannel_pdf(primary_ray, sampler.next_float3(), per_channel_pdf)) {
        Ray ray = primary_payload.hit.spawn_ray(bs.wo);
        cv = per_channel_pdf / bs.pdf; // Update the control variate
        if (visibility_ray_query(ray)) return bs.bsdf / bs.pdf;
        else return float3(0, 0, 0);
    }
    // BSDF sample failed, should not happen in this example
    else return float3(1, 0, 1);
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
        float3 f = float3(0, 0, 0);
        float3 h = float3(0, 0, 0);
        for (int i = 0; i < SPP; ++i) {
            float3 cv;
            f += ratio_estimator(ray, payload, sampler, cv);
            h += cv;
        }
        f /= SPP; h /= SPP;
        // we quickly hack the case h == 0 here to avoid division by zero
        // by making it one, if h is zero, which falls back to the standard MC.
        // Alternative way (defensive h, as disccused in appendix),
        // is shown below for HR:
        h = select(h == 0, float3(1, 1, 1), h);
        output = f / h;
    }
        break;
    case EstimatorEnum::HARTLEY_ROSS: {
        // HR needs at least 2 samples
        if (SPP <= 1) {
            output = error_color;
            break;
        }
        
        // In HR, we additionally track f/h
        float3 f = float3(0, 0, 0);
        float3 h = float3(0, 0, 0);
        float3 f_over_h = float3(0, 0, 0);
        for (int i = 0; i < SPP; ++i) {
            float3 cv; float3 radiance = ratio_estimator(ray, payload, sampler, cv);
            cv = 0.01 + 0.99 * cv; // Defensive h, as discussed in appendix
            f += radiance; h += cv; f_over_h += radiance / cv;
        }
        f /= SPP; h /= SPP; f_over_h /= SPP;
        output = f_over_h + (SPP * 1.0 / (SPP - 1)) * (f - f_over_h * h);
    }   
        break;
    }
    
    rw_output[pixel] = float4(output, 1);
}