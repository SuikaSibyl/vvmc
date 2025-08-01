#ifndef _SRENDERER_MATERIALS_HEADER_
#define _SRENDERER_MATERIALS_HEADER_

#include "srenderer/materials/bxdf.slang"
#include "srenderer/materials/lambertian.slang"
#include "srenderer/materials/conductor.slang"
#include "srenderer/materials/dielectric.slang"
#include "srenderer/materials/plastic.slang"
#include "srenderer/materials/rglbrdf.slang"

namespace materials {
/**
 * Sample the BSDF
 * @param i: input sample information
 * @param material: material data
 * @param uv: texture coordinate
 */
ibsdf::sample_out bsdf_sample(ibsdf::sample_in i, MaterialData material, float2 uv) {
   switch (material.bxdf_type) {
   case 0: return LambertianBRDF::sample(i, LambertMaterial(material, uv));
   case 1: return ConductorBRDF::sample(i, ConductorMaterial(material, uv));
   case 2: return DielectricBRDF::sample(i, DielectricMaterial(material, uv));
   case 3: return PlasticBRDF::sample(i, PlasticMaterial(material, uv));
   // case 3: return OrenNayarBRDF::sample(i, OrenNayarMaterial(material, uv));
   // case 4: return MixtureBRDF::sample(i, MixtureMaterial(material, uv));
   // case 5: return RefractBRDF::sample(i, RefractMaterial(material, uv));
   case 10: return RGLBRDF::sample(i, RGLMaterial(material, uv));
   }
   return {};
}

float3 bsdf_eval(ibsdf::eval_in i, MaterialData material, float2 uv) {
   switch (material.bxdf_type) {
   case 0: return LambertianBRDF::eval(i, LambertMaterial(material, uv));
   case 1: return ConductorBRDF::eval(i, ConductorMaterial(material, uv));
   case 2: return DielectricBRDF::eval(i, DielectricMaterial(material, uv));
   case 3: return PlasticBRDF::eval(i, PlasticMaterial(material, uv));
   // case 3: return OrenNayarBRDF::sample(i, OrenNayarMaterial(material, uv));
   // case 4: return MixtureBRDF::sample(i, MixtureMaterial(material, uv));
   // case 5: return RefractBRDF::sample(i, RefractMaterial(material, uv));
   case 10: return RGLBRDF::eval(i, RGLMaterial(material, uv));
   }
   return {};
}

float bsdf_pdf(ibsdf::pdf_in i, MaterialData material, float2 uv) {
   switch (material.bxdf_type) {
   case 0: return LambertianBRDF::pdf(i, LambertMaterial(material, uv));
   case 1: return ConductorBRDF::pdf(i, ConductorMaterial(material, uv));
   case 2: return DielectricBRDF::pdf(i, DielectricMaterial(material, uv));
   case 3: return PlasticBRDF::pdf(i, PlasticMaterial(material, uv));
   // case 3: return OrenNayarBRDF::sample(i, OrenNayarMaterial(material, uv));
   // case 4: return MixtureBRDF::sample(i, MixtureMaterial(material, uv));
   // case 5: return RefractBRDF::sample(i, RefractMaterial(material, uv));
   case 10: return RGLBRDF::pdf(i, RGLMaterial(material, uv));
   }
   return 0.0f;
}

/**
* Sample the BSDF, also return the per-channel pdf.
* @param i: input sample information
* @param material: material data
* @param uv: texture coordinate
* @param cv: output per-channel pdf
*/
ibsdf::sample_out bsdf_sample_with_perchannel_pdf(
   ibsdf::sample_in i, MaterialData material, float2 uv, out float3 cv
) {
   cv = float3(1, 1, 1);
   ibsdf::sample_out o = {};
   switch (material.bxdf_type) {
   case 0: {
       ibsdf::sample_out so = LambertianBRDF::sample(i, LambertMaterial(material, uv));
       cv = float3(so.pdf, so.pdf, so.pdf); // Lambertian is same across channels
       return so;
   }
   case 1: {
       ibsdf::sample_out so = ConductorBRDF::sample(i, ConductorMaterial(material, uv));
       cv = float3(so.pdf, so.pdf, so.pdf); // Lambertian is same across channels
       return so;
   }
   case 2: {
       ibsdf::sample_out so = LambertianBRDF::sample(i, LambertMaterial(material, uv));
       cv = float3(so.pdf, so.pdf, so.pdf); // Lambertian is same across channels
       return so;
   }
   case 3: {
       ibsdf::sample_out so = PlasticBRDF::sample(i, PlasticMaterial(material, uv));
       cv = float3(so.pdf, so.pdf, so.pdf); // Lambertian is same across channels
       return so;
   }
   case 10: return RGLBRDF::sample_with_perchannel_pdf(i, RGLMaterial(material, uv), cv);
   }
   return o;
}

}

#endif // _SRENDERER_MATERIALS_HEADER_