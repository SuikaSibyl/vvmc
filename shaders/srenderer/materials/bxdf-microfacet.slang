#ifndef _SRENDERER_BXDF_MICROFACET_HEADER_
#define _SRENDERER_BXDF_MICROFACET_HEADER_

#include "common/microfacet.slang"
#include "srenderer/materials/bxdf.slang"

namespace microfacet_reflection {
// importance sample the BSDF
ibsdf::sample_out sample_vnormal<TMicrofacetDistribution : IMicrofacetDistribution>(
    ibsdf::sample_in i,
    TMicrofacetDistribution.TParam parameter) {
    ibsdf::sample_out o;
    // Sample microfacet orientation wh and reflected direction wi
    float3 wi = i.shading_frame.to_local(i.wi);
    if (wi.z < 0) wi.z = -wi.z;
    const float3 wh = TMicrofacetDistribution::sample_wh_vnormal(wi, i.u.xy, parameter);
    // const float3 wh = sample_cos_hemisphere(i.u);
    const float3 wo = reflect(-wi, wh);
    o.wh = i.shading_frame.to_world(wh);
    o.wo = i.shading_frame.to_world(wo);
    // Compute PDF of wi for microfacet reflection
    float VdotH = dot(wi, wh);
    const float pdf = TMicrofacetDistribution::pdf_vnormal(wi, wh, parameter);
    // const float pdf = pdf_cos_hemisphere(wh);
    o.pdf = pdf / (4 * abs(VdotH));
    o.pdf_wh = pdf;
    return o;
}

// importance sample the BSDF
ibsdf::sample_out sample_normal<TMicrofacetDistribution : IMicrofacetDistribution>(
    ibsdf::sample_in i,
    TMicrofacetDistribution.TParam parameter) {
    ibsdf::sample_out o;
    // Sample microfacet orientation wh and reflected direction wi
    float3 wi = i.shading_frame.to_local(i.wi);
    if (wi.z < 0) {
        wi.z = -wi.z;
        i.wi = i.shading_frame.to_world(wi);
    }
    const float3 wh = TMicrofacetDistribution::sample_wh_normal(wi, i.u.xy, parameter);
    // const float3 wh = sample_cos_hemisphere(i.u);
    const float3 wo = reflect(-wi, wh);
    o.wh = i.shading_frame.to_world(wh);
    o.wo = i.shading_frame.to_world(wo);
    // Compute PDF of wi for microfacet reflection
    float VdotH = dot(wi, wh);
    const float pdf = TMicrofacetDistribution::pdf_normal(wi, wh, parameter);
    // const float pdf = pdf_cos_hemisphere(wh);
    o.pdf = pdf / (4 * abs(VdotH));
    o.pdf_wh = pdf;
    return o;
}


// Evaluate the PDF of the BSDF sampling
float pdf_vnormal<TMicrofacetDistribution : IMicrofacetDistribution>
(ibsdf::pdf_in i, TMicrofacetDistribution.TParam parameter) {
    ibsdf::sample_out o;
    // Sample microfacet orientation wh and reflected direction wi
    float3 wi = i.shading_frame.to_local(i.wi);
    if (wi.z < 0) wi.z = -wi.z;
    const float3 wh = i.shading_frame.to_local(i.wh);
    float VdotH = dot(wi, wh);
    const float pdf = TMicrofacetDistribution::pdf_vnormal(wi, wh, parameter);
    // const float pdf = pdf_cos_hemisphere(wh);
    return pdf / (4 * abs(VdotH));
}


}

#endif // !_SRENDERER_BXDF_MICROFACET_HEADER_