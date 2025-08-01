#include "common/hashing.slang"
#include "common/random.slang"
#include "srenderer/materials.slang"
#include "srenderer/spt.slang"
#include "common/mapping.slang"

struct ChoosePoint {
    MinimalHit hit;
};

RWStructuredBuffer<ChoosePoint> rw_chose_point;
RWTexture2D<float4> rw_output;

enum DisplyaModeEnum {
    PATH_TRACING = 0,
    ALBEDO = 1,
    GEOMETRY_NORMAL = 2,
    SHADING_NORMAL = 3,
};

[[vk::push_constant]]
cbuffer PushConstants {
    DisplyaModeEnum display_mode;
    int random_seed;
};

float3 path_tracing(Ray ray, inout random::RandomSampler sampler) {
    Ray primary_ray = ray;
    IntersectionPayload primary_payload = intersection_ray_query(ray);
    // If the primary ray hit nothing, return the background color (white):
    if (!primary_payload.hit.has_hit()) return float3(0, 0, 0);
    IntersectionPayload payload = primary_payload;

    float3 radiance = float3(0.f, 0.f, 0.f);

    // If the ray hit something, accumulate the radiance:
    GeometryData primary_geometry = scene_read_geometry(primary_payload.hit.geometryID);
    Optional<MaterialData> material = scene_read_material(primary_geometry.materialID);
    radiance += material.value.emission();
    float3 throughput = float3(1.f, 1.f, 1.f);
    
    for (int i = 0; i < 10; ++i) {
        if (let ls = payload.light_sample(primary_ray, sampler.next_float3())) {
            Ray shadow_ray = payload.hit.spawn_visibility_ray(ls.x);
            if (visibility_ray_query(shadow_ray)) {
                float3 bsdf = payload.bsdf_eval(-primary_ray.direction, shadow_ray.direction);
                float bsdf_pdf = payload.bsdf_pdf(-primary_ray.direction, shadow_ray.direction);
                radiance += throughput * bsdf * ls.L / (ls.pdf + bsdf_pdf);
            }
        }

        // If the primary ray hit something, sample the BSDF:
        if (let bs = payload.bsdf_sample(primary_ray, sampler.next_float3())) {
            ray = payload.hit.spawn_ray(bs.wo);
            IntersectionPayload bsdf_payload = intersection_ray_query(ray);
            if (bsdf_payload.hit.has_hit()) {
                // If the ray hit something, accumulate the radiance:
                GeometryData next_geometry = scene_read_geometry(bsdf_payload.hit.geometryID);
                Optional<MaterialData> material = scene_read_material(next_geometry.materialID);
                float light_pdf = payload.light_pdf(bsdf_payload);
                radiance += throughput * bs.bsdf * material.value.emission() / (bs.pdf + light_pdf);
                throughput *= bs.bsdf / bs.pdf;
            }
            else break;
            
            payload = bsdf_payload;
        }
    }

    return radiance;
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
    random::RandomSampler sampler = random::init_random_sampler(pixel, random_seed);

    ChoosePoint choose = rw_chose_point[0];
    if (choose.hit.primitiveID < 0) {
        return;
    }
    if (choose.hit.primitiveType == 0) {
        const float3 barycentrics = float3(
            1 - choose.hit.barycentrics.x - choose.hit.barycentrics.y,
            choose.hit.barycentrics.x, choose.hit.barycentrics.y);
        GeometryHit hit = fetch_trimesh_geometry_hit(
            choose.hit.geometryID, barycentrics,
            choose.hit.primitiveID);

        //
        float2 uv = (pixel + 0.5) / resolution * 2 - 1;
        if (length(uv) >= 1) {
            rw_output[pixel] = float4(0, 0, 0, 1);
            return;
        }
        
        // float3 dir = mapping::disc_to_hemisphere_lambert(concentric_sample_disk(uv));
        float3 dir = float3(uv, sqrt(max(0, 1 - dot(uv, uv))));

        Frame frame = Frame::from_normal(hit.shadingNormal);
        float3 ro = frame.to_world(dir);

        Ray secondary_ray = hit.spawn_ray(ro);
        MinimalHit secondary_hit = intersection_ray_query_minimal(secondary_ray);
        rw_output[pixel] = float4(path_tracing(secondary_ray, sampler), 1);
    }
}