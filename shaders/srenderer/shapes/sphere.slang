#ifndef _SRENDERER_SHAPES_SPHERE_HLSLI_
#define _SRENDERER_SHAPES_SPHERE_HLSLI_

#include "common/ray.slang"
#include "common/sampling.slang"
#include "srenderer/shapes/shape.slang"
#include "srenderer/spt-definition.slang"

struct SphereParameter {
    float3  center;
    float   radius;
};

struct Sphere {
    typedef SphereParameter TParam;

    /**
     * Ray-sphere intersection test.
     * @param ray: The ray to test.
     * @param sphere: The sphere to test.
     * Precision Improvements for Ray/Sphere Intersection
     * @url: https://research.nvidia.com/publication/2019-03_precision-improvements-raysphere-intersection
     */
    static float hit(Ray ray, SphereParameter sphere) {
        const float3 center = sphere.center;
        const float radius = sphere.radius;
        const float3 origin = ray.origin;
        const float3 direction = ray.direction;

        float3 f = origin - center;
        float r2 = radius * radius;
        float a = dot(direction, direction);
        float b = 2.0f * dot(f, direction);
        float3 dirnorm = normalize(direction);
        float3 fd = f - dot(f, dirnorm) * dirnorm;
        float discriminant = 4.0f * a * (r2 - dot(fd, fd));
        
        if (discriminant >= 0.0f) {
            float c = dot(f, f) - r2;
            float sqrtVal = sqrt(discriminant);
            // include Press, William H., Saul A. Teukolsky, William T. Vetterling, and Brian P. Flannery,
            // "Numerical Recipes in C," Cambridge University Press, 1992.
            float q = (b >= 0) ? -0.5f * (b + sqrtVal) : -0.5f * (b - sqrtVal);

            float t0 = c / q; float t1 = q / a; // t0 is the first hit, t1 is the second hit
            float t = -1;
            if (t0 >= 0 && t0 < M_INF)
                t = t0;
            if (t1 >= 0 && t1 < M_INF && t < 0)
                t = t1;
            return t;
        }
        return -1;
    }

    static ishape::sample sample(ishape::sample_in i, SphereParameter param) {
        const float3 center = param.center;
        const float radius = param.radius;
        bool validRef = i.position.hasValue;
        
        // If the reference point is inside the sphere, just sample the whole sphere uniformly
        if (!validRef || distance_squared(i.position.value, center) < radius * radius) {
            float z = 1 - 2 * i.uv.x;
            float r_ = sqrt(max(0., 1 - z * z));
            float phi = 2 * M_PI * i.uv.y;
            float3 offset = normalize(float3(r_ * cos(phi), r_ * sin(phi), z));
            ishape::sample sample;
            sample.position = center + radius * offset;
            sample.normal = offset;
            sample.pdf = 1. / surface_area(param);
            return sample;
        }
        const float3 ref_point = i.position.value;
        // Otherwise sample a ray inside a cone towards the sphere center.
        // Build a coordinate system with n pointing towards the sphere
        float3 dir_to_center = normalize(center - ref_point);
        float3x3 frame = Frame::from_normal(dir_to_center).to_float3x3();
        float sin_theta_max_sq = radius * radius / distance_squared(ref_point, center);
        float cos_theta_max = sqrt(max(0.f, 1 - sin_theta_max_sq));
        float3 n_on_sphere;
        ishape::sample sample;
        if (cos_theta_max > 0.999999) {
            n_on_sphere = -normalize(mul(cosine_sample_hemisphere(i.uv), frame));
            sample.position = radius * n_on_sphere + center;
            sample.normal = n_on_sphere;
            const float3 mdir_to_center = normalize(ref_point - center);
            const float3 dir = normalize(sample.position - ref_point);
            sample.pdf = cosine_hemisphere_pdf(abs(dot(mdir_to_center, normalize(sample.position - center)))) 
            * distance_squared(ref_point, sample.position) / abs(dot(n_on_sphere, dir));
            return sample;
        }
        else {
            // Uniformly interpolate between 1 (angle 0) and max
            float cos_theta = (1 - i.uv[0]) + i.uv[0] * cos_theta_max;
            float sin_theta = sqrt(max(0.f, 1 - cos_theta * cos_theta));
            float phi = i.uv[1] * 2 * M_PI;
            // Compute angle from center of sphere to sampled point on surface
            float dc = distance(ref_point, center);
            float ds = dc * cos_theta - sqrt(max(0.f, radius * radius - dc * dc * sin_theta * sin_theta));
            float cos_alpha = (dc * dc + radius * radius - ds * ds) / (2 * dc * radius);
            float sin_alpha = sqrt(max(0.f, 1 - cos_alpha * cos_alpha));
            // get the normal of the sample
            n_on_sphere = -normalize(mul(float3(sin_alpha * cos(phi), sin_alpha * sin(phi), cos_alpha), frame));
            sample.position = radius * n_on_sphere + center;
            sample.normal = n_on_sphere;
            // Uniform sampling PDF of a cone.
            sample.pdf = 1 / (2 * M_PI * (1 - cos_theta_max));
            return sample;
        }
    }

    static float surface_area(SphereParameter param) {
        return 4 * M_PI * param.radius * param.radius;
    }
    
    static float sample_pdf(ishape::pdf_in i, SphereParameter param) {
        const float3 sample_pos = i.sample_point;
        const float3 center = param.center;
        const float r = param.radius;

        bool validRef = i.ref_point.hasValue;
        const float3 p_on_sphere = sample_pos;
        const float3 n_on_sphere = normalize(sample_pos - center);
        const float3 dir = normalize(p_on_sphere - i.ref_point.value);

        if (!validRef || distance_squared(i.ref_point.value, center) < r * r) {
            // If the reference point is inside the sphere, just sample the whole sphere uniformly
            return 1. / surface_area(param)
               * distance_squared(i.ref_point.value, p_on_sphere) / abs(dot(n_on_sphere, dir));
        }
        float sin_theta_max_sq = r * r / distance_squared(i.ref_point.value, center);
        float cos_theta_max = sqrt(max(0.f, 1 - sin_theta_max_sq));
        if (cos_theta_max > 0.999999) {
            float3 mdir_to_center = normalize(i.ref_point.value - center);
            return cosine_hemisphere_pdf(abs(dot(mdir_to_center, normalize(sample_pos - center)))) 
            * distance_squared(i.ref_point.value, p_on_sphere) / abs(dot(n_on_sphere, dir));
        }
        else {
            // Uniform sampling PDF of a cone.
            float pdf_solid_angle = 1 / (2 * M_PI * (1 - cos_theta_max));
            // Convert it back to area measure
            // Output the result
            return pdf_solid_angle;
        }
    }
};

GeometryHit fetch_sphere_geometry_hit(GeometryData geometry, Ray ray, float t) {
    const float4x4 o2w = geometry.object_to_world();
    const float4x4 o2wn = geometry.object_to_world_normal();
    const float3 sphere_center = mul(float4(0, 0, 0, 1), o2w).xyz;
    const float sphere_radius = length(mul(float4(1, 0, 0, 1), o2w).xyz - sphere_center);
    // Record the intersection
    // *: we should re-normalize it, using tHit is super unstable
    const float3 hitPoint = sphere_center + sphere_radius * normalize(ray.origin + ray.direction * t - sphere_center);
    const float3 geometric_normal = normalize(hitPoint - sphere_center);
    const float3 cartesian = normalize(mul(o2wn, float4(geometric_normal, 0)).xyz);
    // We use the spherical coordinates as uv
    // We use the convention that y is up axis.
    // https://en.wikipedia.org/wiki/Spherical_coordinate_system#Cartesian_coordinates
    const float elevation = acos(clamp(cartesian.y, -1., 1.));
    const float azimuth = atan2(cartesian.z, cartesian.x);
    Frame TBN = Frame::from_normal(geometric_normal);

    GeometryHit hit;
    hit.position = hitPoint;
    hit.shadingNormal = geometric_normal;
    hit.geometryNormal = geometric_normal;
    hit.barycentric = float2(0, 0);
    hit.texcoord = float2(-azimuth * M_INV_2PI, elevation * M_INV_PI);
    hit.tangent = float4(TBN.x, 0);
    hit.barycentric = float2(0.333);
    if (distance(ray.origin, sphere_center) >= sphere_radius)
        hit.set_face_forward(true);
    else {
        hit.set_face_forward(false);
        hit.shadingNormal = -hit.shadingNormal;
        hit.geometryNormal = -hit.geometryNormal;
    }
    return hit;
}

#endif // _SRENDERER_SHAPES_SPHERE_HLSLI_