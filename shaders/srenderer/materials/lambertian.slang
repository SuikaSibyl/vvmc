#ifndef _SRENDERER_LAMBERTIAN_MATERIAL_
#define _SRENDERER_LAMBERTIAN_MATERIAL_

#include "common/sampling.slang"
#include "srenderer/materials/bxdf.slang"
#include "srenderer/spt-definition.slang"
#include "srenderer/spt-bindings.slang"

///////////////////////////////////////////////////////////////////////////////////////////
// Lambertian Diffuse Material
// ----------------------------------------------------------------------------------------
// A very simple diffuse material that follows the Lambertian reflectance model.
///////////////////////////////////////////////////////////////////////////////////////////

struct LambertMaterial : IBxDFParameter {
    float3 R; // reflectance

    __init() { R = float3(1.f); }
    __init(float3 r) { R = r; }
    __init(MaterialData mat, float2 uv) {
        R = mat.floatvec_0.xyz;
        if (mat.albedo_tex >= 0) {
            Sampler2D albedo_tex = scene_read_texture(mat.albedo_tex);
            R *= albedo_tex.Sample(uv).rgb;
        }
    }

    [BackwardDifferentiable]
    static LambertMaterial load(no_diff MaterialData mat, no_diff float2 uv) {
        LambertMaterial material = no_diff LambertMaterial();
        material.R = mat.floatvec_0.xyz;
        if (mat.albedo_tex >= 0) {
            no_diff Sampler2D albedo_tex = scene_read_texture(mat.albedo_tex);
            material.R *= (no_diff albedo_tex.Sample(uv)).rgb;
        }
        return material;
    }
};

struct LambertianBRDF : IBxDF {
    typedef LambertMaterial TParam;

    // Evaluate the BSDF
    [Differentiable]
    static float3 eval(no_diff ibsdf::eval_in i, LambertMaterial material) {
        Frame frame = i.shading_frame;
        // Lambertian BRDF
        return abs(dot(frame.n, i.wo)) *
               material.R * M_INV_PI;
    }
    
    static void backward_grad(
        ibsdf::bwd_in i, float3 dL,
        MaterialData mat,
        float2 texcoord
    ) {
        LambertMaterial material = LambertMaterial(mat, texcoord);
        var material_pair = diffPair(material);
        bwd_diff(eval)(i.eval, material_pair, dL);
        bwd_diff(LambertMaterial::load)(mat, texcoord, material_pair.d);
    }

    // importance sample the BSDF
    static ibsdf::sample_out sample(ibsdf::sample_in i, LambertMaterial material) {
        ibsdf::sample_out o;
        // Flip the shading frame if it is
        // inconsistent with the geometry normal.
        Frame frame = i.shading_frame;
        o.wo = frame.to_world(sample_cos_hemisphere(i.u.xy));
        o.pdf = abs(dot(frame.n, o.wo)) * M_INV_PI;

        // evaluate the BSDF
        ibsdf::eval_in eval_in;
        eval_in.wi = i.wi;
        eval_in.wo = o.wo;
        eval_in.geometric_normal = i.geometric_normal;
        eval_in.shading_frame = i.shading_frame;
        o.bsdf = eval(eval_in, material);
        return o;
    }
    // Evaluate the PDF of the BSDF sampling
    static float pdf(ibsdf::pdf_in i, LambertMaterial material) {
        Frame frame = i.shading_frame;
        return abs(dot(frame.n, i.wo)) * M_INV_PI;
    }
}

#endif // _SRENDERER_LAMBERTIAN_MATERIAL_