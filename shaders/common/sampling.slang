#ifndef _SIBYLENGINE_COMMON_SAMPLING_SLANG_
#define _SIBYLENGINE_COMMON_SAMPLING_SLANG_

#include "common/math.slang"

[Differentiable]
float3 random_point_inside_sphere(float2 rvec) {
    const float theta = 2 * M_PI * rvec.x; // Random in [0, 2pi]
    const float u = 2.0 * rvec.y - 1.0;    // Random in [-1, 1]
    const float r = sqrt(1.0 - u * u);
    return float3(r * cos(theta), r * sin(theta), u);
}

[Differentiable]
float3 sample_cos_hemisphere(float2 u) {
    return normalize(float3(0, 0, 1) + random_point_inside_sphere(u));
}

[Differentiable]
float2 concentric_sample_disk(float2 u) {
    // Map uniform random numbers to[−1, 1]^2
    float2 uOffset = 2.f * u - float2(1, 1);
    // Handle degeneracy at the origin
    if (uOffset.x == 0 && uOffset.y == 0)
        return float2(0, 0);
    // Apply concentric mapping to point
    float theta, r;
    if (abs(uOffset.x) > abs(uOffset.y)) {
        r = uOffset.x;
        theta = M_PI_OVER_4 * (uOffset.y / uOffset.x);
    }
    else {
        r = uOffset.y;
        theta = M_PI_OVER_2 - M_PI_OVER_4 * (uOffset.x / uOffset.y);
    }
    return r * float2(cos(theta), sin(theta));
}

[Differentiable]
float3 cosine_sample_hemisphere(float2 u) {
    const float2 d = concentric_sample_disk(u);
    const float z = sqrt(max(0., 1 - d.x * d.x - d.y * d.y));
    return float3(d.x, d.y, z);
}

[Differentiable]
float3 cosine_sample_hemisphere(float2 u, out float inv_pdf) {
    const float3 smp = cosine_sample_hemisphere(u);
    inv_pdf = M_PI / abs(smp.z);
    return smp;
}

[Differentiable]
float cosine_hemisphere_pdf(float cosTheta) {
    return cosTheta * M_INV_PI;
}

int sample_discrete<let N : int>(Array<float, N> weights, inout float u) {
    // Compute sum of weights
    float sum_weights = 0;
    for (int i = 0; i < N; ++i)
        sum_weights += weights[i];
    // Compute rescaled u' sample
    float up = u * sum_weights;
    if (up == sum_weights)
        up = next_float_down(up);
    // Find offset in weights corresponding to u'
    int offset = 0;
    float sum = 0;
    while (sum + weights[offset] <= up) {
        sum += weights[offset++];
    }
    u = min((up - sum) / weights[offset], M_ONE_MINUS_EPSILON);
    return offset;
}

int sample_discrete<let N : int>(Array<float, N> weights, inout float u, inout float pmf) {
    // Compute sum of weights
    float sum_weights = 0;
    for (int i = 0; i < N; ++i)
        sum_weights += weights[i];
    // Compute rescaled u' sample
    float up = u * sum_weights;
    if (up == sum_weights)
        up = next_float_down(up);
    // Find offset in weights corresponding to u'
    int offset = 0;
    float sum = 0;
    while (sum + weights[offset] <= up) {
        sum += weights[offset++];
    }
    // Compute PMF and remapped u value, if necessary
    pmf = weights[offset] / sum_weights;
    u = min((up - sum) / weights[offset], M_ONE_MINUS_EPSILON);
    return offset;
}

#endif // _SIBYLENGINE_COMMON_SAMPLING_SLANG_