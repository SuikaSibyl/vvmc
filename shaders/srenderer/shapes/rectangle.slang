#ifndef _SRENDERER_SHAPE_RECTANGLE_HEADER_
#define _SRENDERER_SHAPE_RECTANGLE_HEADER_

#include "common/rotation.slang"
#include "common/warps.slang"
#include "common/ray.slang"
#include "common/math.slang"
#include "shape.slang"
#include "srenderer/spt-definition.slang"

struct SphericalRectangle {
    float3 o, x, y, z;     // local reference system 'R'
    float z0, z0sq;        //
    float x0, y0, y0sq;    // rectangle coords in 'R'
    float x1, y1, y1sq;    //
    float b0, b1, b0sq, k; // misc precomputed constants
    float S;               // solid angle of 'Q'

    __init(float3 s, float3 ex, float3 ey, float3 o) {
        this.o = o;
        float exl = length(ex);
        float eyl = length(ey);
        // compute local reference system ’R’
        this.x = ex / exl;
        this.y = ey / eyl;
        this.z = cross(this.x, this.y);
        // compute rectangle coords in local reference system
        float3 d = s - o;
        this.z0 = dot(d, this.z);
        // flip ’z’ to make it point against ’Q’
        if (this.z0 > 0.) {
            this.z *= -1.;
            this.z0 *= -1.;
        }
        this.z0sq = this.z0 * this.z0;
        this.x0 = dot(d, this.x);
        this.y0 = dot(d, this.y);
        this.x1 = this.x0 + exl;
        this.y1 = this.y0 + eyl;
        this.y0sq = this.y0 * this.y0;
        this.y1sq = this.y1 * this.y1;
        // create vectors to four vertices
        float3 v00 = float3(this.x0, this.y0, this.z0);
        float3 v01 = float3(this.x0, this.y1, this.z0);
        float3 v10 = float3(this.x1, this.y0, this.z0);
        float3 v11 = float3(this.x1, this.y1, this.z0);
        // compute normals to edges
        float3 n0 = normalize(cross(v00, v10));
        float3 n1 = normalize(cross(v10, v11));
        float3 n2 = normalize(cross(v11, v01));
        float3 n3 = normalize(cross(v01, v00));
        // compute internal angles (gamma_i)
        float g0 = acos(-dot(n0, n1));
        float g1 = acos(-dot(n1, n2));
        float g2 = acos(-dot(n2, n3));
        float g3 = acos(-dot(n3, n0));
        // compute predefined constants
        this.b0 = n0.z;
        this.b1 = n2.z;
        this.b0sq = this.b0 * this.b0;
        this.k = 2. * M_PI - g2 - g3;
        // compute solid angle from internal angles
        this.S = g0 + g1 - this.k;
    }

    ishape::sample sample(ishape::sample_in i) {
        ishape::sample sample_o;
        // 1. compute ’cu’
        float au = i.uv.x * S + k;
        float fu = (cos(au) * b0 - b1) / sin(au);
        float cu = 1 / sqrt(fu * fu + b0sq) * (fu > 0 ? +1 : -1);
        cu = clamp(cu, -1, 1); // avoid NaNs
        // 2. compute ’xu’
        float xu = -(cu * z0) / sqrt(1 - cu * cu);
        xu = clamp(xu, x0, x1); // avoid Infs
        // 3. compute ’yv’
        float d = sqrt(xu * xu + z0sq);
        float h0 = y0 / sqrt(d * d + y0sq);
        float h1 = y1 / sqrt(d * d + y1sq);
        float hv = h0 + i.uv.y * (h1 - h0);
        float hv2 = hv * hv;
        float yv = (hv2 < 1 - 1e-4) ? (hv * d) / sqrt(1 - hv2) : y1;
        // 4. transform (xu,yv,z0) to world coords
        sample_o.position = (o + xu * x + yv * y + z0 * z);
        sample_o.pdf = 1.f / S;
        return sample_o;
    }
};

struct RectangleParameter {
    float4x4 o2w;
    float4x4 w2o;
};

struct Rectangle {
    typedef RectangleParameter TParam;

    // from iq:
    // https://iquilezles.org/articles/boxfunctions/
    static float hit(Ray ray, RectangleParameter param) {
        // convert from world to box space
        float3 rd = mul(float4(ray.direction, 0.0), param.w2o).xyz;
        float3 ro = mul(float4(ray.origin, 1.0), param.w2o).xyz;
        float t = -ro.z / rd.z;
        float3 local = ro + t * rd;
        if (abs(local.x) <= 1.f && abs(local.y) <= 1.f) return t;
        return -1.f;
    }
    
    static ishape::sample sample(ishape::sample_in i, RectangleParameter param) {
        float3 local_position = float3(i.uv * 2 - 1, 0);
        float3 world_position = mul(float4(local_position, 1.0), param.o2w).xyz;
        float3 world_0 = mul(float4(0, 0, 0, 1), param.o2w).xyz;
        float3 world_x = mul(float4(1, 0, 0, 1), param.o2w).xyz;
        float3 world_y = mul(float4(0, 1, 0, 1), param.o2w).xyz;
        float3 world_z = mul(float4(0, 0, 1, 1), param.o2w).xyz;
        float edge_1 = length(world_x - world_0);
        float edge_2 = length(world_y - world_0);
        float area = edge_1 * edge_2 * 4;
        float3 direction = normalize(world_position - i.position.value);

        ishape::sample sample_o;
        sample_o.position = world_position;
        sample_o.normal = normalize(world_z - world_0);
        sample_o.pdf = length_squared(i.position.value - sample_o.position) 
        / (area * abs(dot(sample_o.normal, -direction)));

        return sample_o;
    }

    static float sample_pdf(ishape::pdf_in i, RectangleParameter param) {
        float3 world_0 = mul(float4(0, 0, 0, 1), param.o2w).xyz;
        float3 world_x = mul(float4(1, 0, 0, 1), param.o2w).xyz;
        float3 world_y = mul(float4(0, 1, 0, 1), param.o2w).xyz;
        float3 world_z = mul(float4(0, 0, 1, 1), param.o2w).xyz;
        float edge_1 = length(world_x - world_0);
        float edge_2 = length(world_y - world_0);
        float area = edge_1 * edge_2 * 4;
        float3 direction = normalize(i.sample_point - i.ref_point.value);

        return length_squared(i.sample_point - i.ref_point.value) 
        / (area * abs(dot(i.sample_normal, -direction)));
    }
};

GeometryHit fetch_rectangle_geometry_hit(GeometryData geometry, Ray ray, float t) {
    // convert from world to box space
    float4x4 o2w = geometry.object_to_world();
    float4x4 w2o = geometry.world_to_object();
    float3 rd = mul(float4(ray.direction, 0.0), w2o).xyz;
    float3 ro = mul(float4(ray.origin, 1.0), w2o).xyz;
    float t = -ro.z / rd.z;
    GeometryHit hit;
    hit.shadingNormal = mul(float4(0, 0, 1, 0), transpose(w2o)).xyz;
    hit.shadingNormal = normalize(hit.shadingNormal);
    hit.texcoord = (ro + t * rd).xy * 0.5 + 0.5;
    hit.position = ray.origin + t * ray.direction;
    hit.geometryNormal = hit.shadingNormal;
    hit.barycentric = float2(0, 0);
    hit.tangent = float4(0);
    hit.barycentric = float2(0.333);

    if (ro.z > 0) hit.set_face_forward(true);
    else {
        hit.set_face_forward(false);
        hit.shadingNormal = -hit.shadingNormal;
        hit.geometryNormal = -hit.geometryNormal;
    }

    return hit;
}

#endif // _SRENDERER_SHAPE_RECTANGLE_HEADER_