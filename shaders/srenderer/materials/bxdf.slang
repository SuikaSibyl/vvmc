#ifndef _SRENDERER_MATERIALS_BXDF_HEADER_
#define _SRENDERER_MATERIALS_BXDF_HEADER_

#include "common/geometry.slang"
#include "common/math.slang"

interface IBxDFParameter : IDifferentiable {};

namespace ibsdf {
struct eval_in {
    float3 wi;
    float3 wo;
    float3 geometric_normal;
    Frame shading_frame;
    Optional<float3> wh;
};

struct sample_in {
    float3 u;
    float3 wi;
    float3 geometric_normal;
    Frame shading_frame;
};

struct sample_out {
    float3 bsdf;
    float3 wo;
    float pdf;
    float3 wh;    // microfacet orientation
    float pdf_wh; // microfacet pdf
};

struct pdf_in {
    float3 wi;
    float3 wo;
    float3 wh;
    float3 geometric_normal;
    Frame shading_frame;
};

struct bwd_in {
    eval_in eval;
    int hash_value;
    float pdf;
};

struct dsample_out<TBxDFParameter : IBxDFParameter> {
    float3 wo;
    float pdf;
    TBxDFParameter.Differential dparam;
};

struct dsample_noeval_out {
    float3 wo;
    float pdf;
    float3 wh;    // microfacet orientation
    float pdf_wh; // microfacet pdf
};
}

interface IBxDF {
    // Associated a parameter type for each microfacet distribution
    associatedtype TParam : IBxDFParameter;

    // Evaluate the BSDF
    static float3 eval(ibsdf::eval_in i, TParam param);
    // importance sample the BSDF
    static ibsdf::sample_out sample(ibsdf::sample_in i, TParam param);
    // Evaluate the PDF of the BSDF sampling
    static float pdf(ibsdf::pdf_in i, TParam param);
};

namespace ibsdf {
float u2theta(float u) { return 
        sqr(u) * (M_PI / 2.f); }
float2 u2theta(float2 u) { return 
        float2(u2theta(u.x), u2theta(u.y)); }
float3 u2theta(float3 u) { return 
        float3(u2theta(u.xy), u2theta(u.z)); }
float4 u2theta(float4 u) { return 
        float4(u2theta(u.xy), u2theta(u.zw)); }

float u2phi(float u) { return 
        (2.f * u - 1.f) * M_PI; }
float2 u2phi(float2 u) { return 
        float2(u2phi(u.x), u2phi(u.y)); }
float3 u2phi(float3 u) { return 
        float3(u2phi(u.xy), u2phi(u.z)); }
float4 u2phi(float4 u) { return 
        float4(u2phi(u.xy), u2phi(u.zw)); }

float theta2u(float theta) { return 
        sqrt(theta * (2.f / M_PI)); }
float2 theta2u(float2 theta) { return 
        float2(theta2u(theta.x), theta2u(theta.y)); }
float3 theta2u(float3 theta) { return 
        float3(theta2u(theta.xy), theta2u(theta.z)); }
float4 theta2u(float4 theta) { return 
        float4(theta2u(theta.xy), theta2u(theta.zw)); }

float phi2u(float phi) { return 
        (phi + M_PI) / (2.f * M_PI); }
float2 phi2u(float2 phi) { return 
        float2(phi2u(phi.x), phi2u(phi.y)); }
float3 phi2u(float3 phi) { return 
        float3(phi2u(phi.xy), phi2u(phi.z)); }
float4 phi2u(float4 phi) { return 
        float4(phi2u(phi.xy), phi2u(phi.zw)); }
}

#endif // _SRENDERER_MATERIALS_BXDF_HEADER_