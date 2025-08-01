#ifndef SRENDERER_COMMON_ROTATION_HEADER
#define SRENDERER_COMMON_ROTATION_HEADER

#include "linear-algebra.slang"

/**
 * Build the skew-symmetric matrix from a vector.
 * @param v The input vector.
 * @return The skew-symmetric matrix.
 */
[Differentiable]
float3x3 skew_symmetric_matrix(float3 v) {
    return float3x3(
        0.f, -v.z, v.y,
        v.z, 0.f, -v.x,
        -v.y, v.x, 0.f);
}

/**
 * Build the rotation matrix from an axis-angle representation.
 * Unlike the Rodrigues formula, this function do not really
 * implies a given normalized rotation.
 * Also this implementation seems to be more numerically stable.
 * The derivation is adapted from the paper (Appendix B):
 * "Reparameterizing Discontinuous Integrands for Differentiable Rendering"
 * @url: https://rgl.epfl.ch/publications/Loubet2019Reparameterizing
 * The implementation is adapted from mitsuba:
 * @url: https://github.com/loubetg/mitsuba2/blob/90b25107fabbdab371c
         49c14a307718c3d246bd4/src/integrators/path-reparam.cpp
 * @param axis The axis of rotation.
 * @param angle The angle of rotation.
 * @return The rotation matrix.
 */
[Differentiable]
float3x3 rotation_from_axis_cosangle(float3 axis, float cosangle) {
    const float axy = axis.x * axis.y;
    const float axz = axis.x * axis.z;
    const float ayz = axis.y * axis.z;
    const float3x3 ux = skew_symmetric_matrix(axis);
    const float3x3 uu = float3x3(
        axis.x * axis.x, axy, axz,
        axy, axis.y * axis.y, ayz,
        axz, ayz, axis.z * axis.z);
    return identity3x3() * cosangle + ux + rcp(1 + cosangle) * uu;
}

float4x4 rotate_x(float x) {
    float sinx; float cosx;
    sincos(x, sinx, cosx);
    return float4x4(
        cosx, 0.f, sinx, 0.f,
        0.f, 1.f, 0.f, 0.f,
        -sinx, 0.f, cosx, 0.f,
        0.f, 0.f, 0.f, 1.f);
}

float4x4 rotate_y(float y) {
    float siny; float cosy;
    sincos(y, siny, cosy);
    return float4x4(
        1.f, 0.f, 0.f, 0.f,
        0.f, cosy, -siny, 0.f,
        0.f, siny, cosy, 0.f,
        0.f, 0.f, 0.f, 1.f);
}

float4x4 rotate_z(float z) {
    float sinz; float cosz;
    sincos(z, sinz, cosz);
    return float4x4(
        cosz, -sinz, 0.f, 0.f,
        sinz, cosz, 0.f, 0.f,
        0.f, 0.f, 1.f, 0.f,
        0.f, 0.f, 0.f, 1.f);
}

float4x4 rotate_euler(float3 euler_angles) {
    return mul(rotate_z(euler_angles.z), 
        mul(rotate_y(euler_angles.y), 
        rotate_x(euler_angles.x)));
}

/** Return a matrix that rotate vector around axis by angle. */
float4x4 rotationMatrix(
    in const float3 axis, // should be normalized
    in const float angle
) {
    const float s = sin(angle);
    const float c = cos(angle);
    const float oc = 1.0 - c;
    return float4x4(oc * axis.x * axis.x + c, oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s, 0.0,
                    oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c, oc * axis.y * axis.z - axis.x * s, 0.0,
                    oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c, 0.0,
                    0.0, 0.0, 0.0, 1.0);
}

/** Rotate vector around axis by angle */
float3 rotate(
    in const float3 v,
    in const float3 axis, // should be normalized
    in const float angle
) {
    return mul(rotationMatrix(axis, angle), float4(v, 0.0)).xyz;
}

float3x3 rotate(float sinTheta, float cosTheta, float3 axis) {
    float3 a = normalize(axis);
    float3x3 m;
    // Compute rotation of first basis vector
    m[0][0] = a.x * a.x + (1 - a.x * a.x) * cosTheta;
    m[0][1] = a.x * a.y * (1 - cosTheta) - a.z * sinTheta;
    m[0][2] = a.x * a.z * (1 - cosTheta) + a.y * sinTheta;
    // Compute rotations of second and third basis vectors
    m[1][0] = a.x * a.y * (1 - cosTheta) + a.z * sinTheta;
    m[1][1] = a.y * a.y + (1 - a.y * a.y) * cosTheta;
    m[1][2] = a.y * a.z * (1 - cosTheta) - a.x * sinTheta;
    m[2][0] = a.x * a.z * (1 - cosTheta) - a.y * sinTheta;
    m[2][1] = a.y * a.z * (1 - cosTheta) + a.x * sinTheta;
    m[2][2] = a.z * a.z + (1 - a.z * a.z) * cosTheta;
    return m;
}

float3x3 rotate(float theta, float3 axis) {
    float theta_rad = radians(theta);
    float sinTheta; float cosTheta;
    sincos(theta_rad, sinTheta, cosTheta);
    return rotate(sinTheta, cosTheta, axis);
}

#endif // SRENDERER_COMMON_ROTATION_HEADER