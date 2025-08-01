#include "srenderer/spt.slang"

struct AssembledVertex { 
    int vertexId : SV_VertexId; };
struct VertexStageOutput {
    float4 sv_position : SV_Position;
};

[[vk::push_constant]]
cbuffer PushConstants {
    int c_geometryID;
};

[shader("vertex")]
VertexStageOutput VertexMain(
    AssembledVertex assembledVertex
) {
    CameraData camera = scene_read_camera(0);
    GeometryData geometry = scene_read_geometry(c_geometryID);

    const int indexID = assembledVertex.vertexId + geometry.indexOffset;
    const int index = scene_read_index(geometry.meshID, indexID);
    const float3 positionOS = scene_read_position(geometry.meshID, index + geometry.vertexOffset);

    const float4x4 o2w = geometry.object_to_world();
    const float3 positionWS = mul(float4(positionOS, 1.0), o2w).xyz;
    const float4 positionCS = mul(float4(positionWS, 1.0f), camera.get_view_proj_mat());
    
    VertexStageOutput output;
    output.sv_position = positionCS;
    return output;
}

[shader("fragment")]
void FragmentMain(
    nointerpolation in int primitiveID: SV_PrimitiveID,
    in bool isFrontFace: SV_IsFrontFace,
    float4 svPos: SV_POSITION,
    in float3 bary: SV_Barycentrics,
    out float4 o_color: SV_Target0) : SV_Target
{
    GeometryData geometry = scene_read_geometry(c_geometryID);
    Optional<MaterialData> material = scene_read_material(geometry);

    float3 albedo = float3(0, 0, 0);
    if (material.hasValue) {
        albedo = material.value.albedo();
    }
    
    o_color = float4(albedo, 1);
}
