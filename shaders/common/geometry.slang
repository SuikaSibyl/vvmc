#ifndef _SIBYLENGINE_GEOMETRY_SLANG_
#define _SIBYLENGINE_GEOMETRY_SLANG_

#include "math.slang"
#include "rotation.slang"

// Convert an vector v from local coordinates defined by the frame to world coordinates.
float3 to_world(float3x3 frame, float3 v) { return v[0] * frame[0] + v[1] * frame[1] + v[2] * frame[2]; }
// Convert an vector v from world coordinates defined by the frame to local coordinates.
float3 to_local(float3x3 frame, float3 v) { return float3(dot(v, frame[0]), dot(v, frame[1]), dot(v, frame[2])); }

struct Frame {
    float3 n;
    float3 x;
    float3 y;
    
    __init(float3x3 frame) {
        n = frame[2];
        x = frame[0];
        y = frame[1];
    }
    
    static Frame from_float3x3(float3x3 frame) { return Frame(frame); }
    static Frame from_normal(float3 n) {
        if (n[2] < float(-1 + 1e-5)) {
            return from_float3x3(float3x3(float3(0, -1, 0), float3(-1, 0, 0), float3(0, 0, -1)));
        } else {
            const float a = 1 / (1 + n[2]);
            const float b = -n[0] * n[1] * a;
            return from_float3x3(float3x3(float3(1 - n[0] * n[0] * a, b, -n[0]),
                float3(b, 1 - n[1] * n[1] * a, -n[1]), n));
        }
    }

    float3x3 to_float3x3() { return float3x3(x, y, n); }

    [mutating]
    void flip() {
        n = -n;
        x = -x;
        y = -y;
    }

    float3 to_world(float3 v) {
        return v[0] * x + v[1] * y + v[2] * n;
    }

    float3 to_local(float3 v) {
        return float3(dot(v, x), dot(v, y), dot(v, n));
    }
};

///////////////////////////////////////////////////////////////////////////////////////////
// Theta-Phi Coordinate Conversion Functions
// ----------------------------------------------------------------------------------------
// A set of utility functions to convert between theta-phi and xyz coordinates.
// The theta-phi coordinate system is a spherical coordinate system where theta is the
// angle from the z-axis and phi is the angle from the x-axis in the x-y plane.
///////////////////////////////////////////////////////////////////////////////////////////

namespace theta_phi_coord {
[Differentiable] float cos_theta(float3 w) { return w.z; }
[Differentiable] float cos2_theta(float3 w) { return w.z * w.z; }
[Differentiable] float abs_cos_theta(float3 w) { return abs(w.z); }
[Differentiable] float sin2_theta(float3 w) { return max(0.0, 1.0 - cos2_theta(w)); }
[Differentiable] float sin_theta(float3 w) { return sqrt(sin2_theta(w)); }
[Differentiable] float tan_theta(float3 w) { return sin_theta(w) / cos_theta(w); }
[Differentiable] float tan2_theta(float3 w) { return sin2_theta(w) / cos2_theta(w); }
[Differentiable] float theta(float3 w) { return acos(cos_theta(w)); }

[Differentiable] float cos_phi(float3 w) { float sinTheta = sin_theta(w); return (sinTheta == 0) ? 1 : clamp(w.x / sinTheta, -1, 1); }
[Differentiable] float sin_phi(float3 w) { float sinTheta = sin_theta(w); return (sinTheta == 0) ? 0 : clamp(w.y / sinTheta, -1, 1); }
[Differentiable] float cos2_phi(float3 w) { return cos_phi(w) * cos_phi(w); }
[Differentiable] float sin2_phi(float3 w) { return sin_phi(w) * sin_phi(w); }
[Differentiable] float phi(float3 w) { const float res = atan2(w.y, w.x); return (res < 0) ? (res + 2 * M_PI) : res; }

/* Gives the cosine of the phi angle between two directions. */
[Differentiable] float cos_diff_phi(float3 wa, float3 wb) { return clamp((wa.x * wb.x + wa.y * wb.y) / sqrt((wa.x * wa.x + wa.y * wa.y) * (wb.x * wb.x + wb.y * wb.y)), -1, 1); }

[Differentiable] float3 spherical_direction(float sinTheta, float cosTheta, float phi) {
    float sin_phi; float cos_phi; 
    sincos(phi, sin_phi, cos_phi); 
    return float3(sinTheta * cos_phi, sinTheta * sin_phi, cosTheta);
}

[Differentiable] float3 spherical_direction(float theta, float phi) {
    float sin_theta; float cos_theta;
    float sin_phi; float cos_phi;
    sincos(theta, sin_theta, cos_theta);
    sincos(phi, sin_phi, cos_phi);
    return float3(sin_theta * cos_phi, sin_theta * sin_phi, cos_theta);
}

[Differentiable] float3 spherical_direction(
    float sinTheta, float cosTheta, float phi,
    float3 x, float3 y, float3 z) {
    return sinTheta * cos(phi) * x + sinTheta * sin(phi) * y + cosTheta * z;
}

[Differentiable] bool same_hemisphere(float3 w, float3 wp) {
    return w.z * wp.z > 0;
}
}

struct bounds3 {
    float3 pMin;
    float3 pMax;

    __init() { pMin = float3(M_INF, M_INF, M_INF); pMax = float3(-M_INF, -M_INF, -M_INF); }
    __init(float3 pmin, float3 pmax) { pMin = pmin; pMax = pmax; }

    float3 diagonal() { return pMax - pMin; }
    
    float3 offset(float3 p) {
        float3 o = p - pMin;
        if (pMax.x > pMin.x) o.x /= pMax.x - pMin.x;
        if (pMax.y > pMin.y) o.y /= pMax.y - pMin.y;
        if (pMax.z > pMin.z) o.z /= pMax.z - pMin.z;
        return o;
    }

    void bounding_sphere(out float3 center, out float radius) {
        center = (pMin + pMax) / 2;
        radius = inside(center, this) ? distance(center, pMax) : 0;
    }

    bool intersect_p(
        float3 o, float3 d, float tMax,
        out float hitt0, out float hitt1) {
        hitt0 = -M_INF; hitt1 = -M_INF;
        float t0 = 0; float t1 = tMax;
        for (int i = 0; i < 3; ++i) {
            // Update interval for ith bounding box slab
            float invRayDir = 1 / d[i];
            float tNear = (pMin[i] - o[i]) * invRayDir;
            float tFar = (pMax[i] - o[i]) * invRayDir;
            // Update parametric interval from slab intersection t values
            if (tNear > tFar) swap(tNear, tFar);
            // Update tFar to ensure robust ray–bounds intersection
            tFar *= 1 + 2 * gamma(3);

            t0 = tNear > t0 ? tNear : t0;
            t1 = tFar < t1 ? tFar : t1;
            if (t0 > t1) return false;
        }
        hitt0 = t0;
        hitt1 = t1;
        return true;
    }
};

/** * A 3D axis-aligned bounding box with integer coordinates.
 * It is used to define a 3D grid for sampling.
 */
struct bounds3i {
    int3 pMin;
    int3 pMax;

    static bool inside_exclusive(int3 p, bounds3i b) {
        return (p.x >= b.pMin.x && p.x < b.pMax.x &&
                p.y >= b.pMin.y && p.y < b.pMax.y &&
                p.z >= b.pMin.z && p.z < b.pMax.z);
    }
};

bool inside(float3 p, bounds3 b) {
    return (p.x >= b.pMin.x && p.x <= b.pMax.x &&
            p.y >= b.pMin.y && p.y <= b.pMax.y &&
            p.z >= b.pMin.z && p.z <= b.pMax.z);
}

struct DirectionCone {
    float3 w;
    float cosTheta;
    __init() { w = float3(0, 0, 0); cosTheta = M_INF; }
    __init(float3 w, float cosTheta) { this.w = w; this.cosTheta = cosTheta;}

    bool is_empty() { return cosTheta == M_INF; }

    static DirectionCone entire_sphere() { return DirectionCone(float3(0, 0, 1), -1); }
    static DirectionCone bound_subtended_directions(bounds3 b, float3 p) {
        // Compute bounding sphere for b and check if p is inside
        float radius; float3 pCenter;
        b.bounding_sphere(pCenter, radius);
        if (distance_squared(p, pCenter) < sqr(radius))
            return DirectionCone::entire_sphere();
        // Compute and return DirectionCone for bounding sphere
        float3 w = normalize(pCenter - p);
        float sin2ThetaMax = sqr(radius) / distance_squared(pCenter, p);
        float cosThetaMax = safe_sqrt(1 - sin2ThetaMax);
        return DirectionCone(w, cosThetaMax);
    }
};

DirectionCone union (DirectionCone a, DirectionCone b) {
    // Handle the cases where one or both cones are empty
    if (a.is_empty()) return b;
    if (b.is_empty()) return a;
    // Handle the cases where one cone is inside the other
    float theta_a = safe_acos(a.cosTheta);
    float theta_b = safe_acos(b.cosTheta);
    float theta_d = angle_between(a.w, b.w);
    if (min(theta_d + theta_b, M_PI) <= theta_a) return a;
    if (min(theta_d + theta_a, M_PI) <= theta_b) return b;
    // Compute the spread angle of the merged cone, theta_o
    float theta_o = (theta_a + theta_d + theta_b) / 2;
    if (theta_o >= M_PI)
        return DirectionCone::entire_sphere();
    // Find the merged cone’s axis and return cone union
    float theta_r = theta_o - theta_a;
    float3 wr = cross(a.w, b.w);
    if (length_squared(wr) == 0)
        return DirectionCone::entire_sphere();
    float3 w = mul(a.w, rotate(degrees(theta_r), wr));
    return DirectionCone(w, cos(theta_o));
}


#endif // _SIBYLENGINE_GEOMETRY_SLANG_