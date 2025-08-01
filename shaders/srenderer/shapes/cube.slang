#ifndef _SRENDERER_SHAPES_CUBE_HLSLI_
#define _SRENDERER_SHAPES_CUBE_HLSLI_

#include "common/math.slang"
#include "common/ray.slang"
#include "common/sampling.slang"
#include "shape.slang"
#include "srenderer/spt-definition.slang"

struct CubeParameter {
    float4x4 o2w;
    float4x4 w2o;
};

struct Cube {
    typedef CubeParameter TParam;

    // from iq:
    // https://iquilezles.org/articles/boxfunctions/
    static float hit(Ray ray, CubeParameter param) {
        // convert from world to box space
        float3 rd = mul(float4(ray.direction, 0.0), param.w2o).xyz;
        float3 ro = mul(float4(ray.origin, 1.0), param.w2o).xyz;
        // ray-box intersection in box space
        float3 m = 1.0 / rd;
        float3 s = float3((rd.x < 0.0) ? 1.0 : -1.0,
                          (rd.y < 0.0) ? 1.0 : -1.0,
                          (rd.z < 0.0) ? 1.0 : -1.0);
        float3 t1 = m * (-ro + s * float3(1));
        float3 t2 = m * (-ro - s * float3(1));
        float tN = max(max(t1.x, t1.y), t1.z);
        float tF = min(min(t2.x, t2.y), t2.z);
        // no intersection
        if (tN > tF || tF < 0.0) return -1;
        return tN;
    }
};

GeometryHit fetch_cube_geometry_hit(GeometryData geometry, Ray ray, float t) {
    // convert from world to box space
    float4x4 o2w = geometry.object_to_world();
    float4x4 w2o = geometry.world_to_object();
    float3 rd = mul(float4(ray.direction, 0.0), w2o).xyz;
    float3 ro = mul(float4(ray.origin, 1.0), w2o).xyz;
    // ray-box intersection in box space
    float3 m = 1.0 / rd;
    float3 s = float3((rd.x < 0.0) ? 1.0 : -1.0,
                      (rd.y < 0.0) ? 1.0 : -1.0,
                      (rd.z < 0.0) ? 1.0 : -1.0);
    float3 t1 = m * (-ro + s * float3(1));
    float3 t2 = m * (-ro - s * float3(1));
    float tN = max(max(t1.x, t1.y), t1.z);
    float tF = min(min(t2.x, t2.y), t2.z);
    // no intersection
    if (tN > tF || tF < 0.0) return {};
    // compute normal (in world space), face and UV
    GeometryHit hit;
    if (t1.x > t1.y && t1.x > t1.z) {
        hit.shadingNormal = mul(float4(s.x, 0, 0, 0), transpose(w2o)).xyz;
        hit.texcoord = -(ro.yz + rd.yz * t1.x);
    }
    else if (t1.y > t1.z) {
        hit.shadingNormal = mul(float4(0, s.y, 0, 0), transpose(w2o)).xyz;
        hit.texcoord = ro.zx + rd.zx * t1.y;
    }
    else {
        hit.shadingNormal = mul(float4(0, 0, s.z, 0), transpose(w2o)).xyz;
        hit.texcoord = ro.xy + rd.xy * t1.z;
    }
    hit.texcoord = (hit.texcoord * 0.5 + 0.5).yx;
    hit.shadingNormal = normalize(hit.shadingNormal);
    hit.position = ray.origin + tN * ray.direction;
    hit.geometryNormal = hit.shadingNormal;
    hit.barycentric = float2(0, 0);
    hit.tangent = float4(0);
    hit.barycentric = float2(0.333);

    if (all(ro > -1) && all(ro < 1)) {
        hit.set_face_forward(false);
        hit.shadingNormal = -hit.shadingNormal;
        hit.geometryNormal = -hit.geometryNormal;
    }
    else hit.set_face_forward(true);

    return hit;
}

#endif // _SRENDERER_SHAPES_CUBE_HLSLI_