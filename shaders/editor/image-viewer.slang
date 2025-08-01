struct AssembledVertex { int vertexId : SV_VertexId; };
struct CoarseVertex { float2 uv; };
struct VertexStageOutput {
    CoarseVertex coarseVertex : CoarseVertex;
    float4 sv_position : SV_Position;
};

enum DisplayChannel {
    RGBA,
    RGB,
    RChannel,
    GChannel,
    BChannel,
};

[[vk::push_constant]]
cbuffer PushConstants {
    float2 scale;
    float2 offset;
    int outputSize;
    DisplayChannel channelShow;
};

struct HostInfo {
    float4 color;
    int2 pixel;
    int2 outPixel;
};
RWStructuredBuffer<HostInfo> rw_buffer;
Texture2D ro_texture;
// SamplerState g_sampler;

[shader("vertex")]
VertexStageOutput VertexMain(
    AssembledVertex assembledVertex
) {
    // A full screen quad with two triangles:
    const float2 positions[6] = {
        {-1.0f, -1.0f}, {1.0f, -1.0f}, {1.0f, 1.0f},
        {-1.0f, -1.0f}, {1.0f, 1.0f}, {-1.0f, 1.0f}
    };

    const float2 uvs[6] = {
        {0.0f, 0.0f}, {1.0f, 0.0f}, {1.0f, 1.0f},
        {0.0f, 0.0f}, {1.0f, 1.0f}, {0.0f, 1.0f}
    };

    VertexStageOutput output;
    output.coarseVertex.uv = uvs[assembledVertex.vertexId];
    output.sv_position = float4(positions[assembledVertex.vertexId] * scale + offset, 0.0f, 1.0f);
    return output;
}

[shader("fragment")]
void FragmentMain(
    in CoarseVertex coarseVertex: CoarseVertex,
    nointerpolation in int primitiveID: SV_PrimitiveID,
    in bool isFrontFace: SV_IsFrontFace,
    float4 svPos: SV_POSITION,
    in float3 bary: SV_Barycentrics,
    out float4 o_color: SV_Target0) : SV_Target
{
    uint2 texture_size;
    ro_texture.GetDimensions(texture_size.x, texture_size.y);
    uint texture_size_max = max(texture_size.x, texture_size.y);
    uint texture_size_min = min(texture_size.x, texture_size.y);
    float2 texel = coarseVertex.uv * texture_size_max;
    float offset_x = (texture_size_max - texture_size.x) * 0.5f;
    float offset_y = (texture_size_max - texture_size.y) * 0.5f;
    texel -= float2(offset_x, offset_y);
    float2 uv = (floor(texel) + float2(0.5, 0.5)) / texture_size_max;

    const float GridWidth = 2. / clamp(scale.x + scale.y, 0, 50) * 512 / outputSize;
    float2 texelMod = fmod(texel, float2(1.0, 1.0));
    float2 texelEdge = step(texelMod, GridWidth);
    float isGrid = max(texelEdge.x, texelEdge.y);

    const int grid_pixel_size = int(outputSize * scale.x / texture_size_max);

    float4 sampled = ro_texture.Load(int3(int2(texel), 0));
    float4 ct = sampled;

    int2 pixelScreen = int2(svPos.xy);
    if (all(pixelScreen == rw_buffer[0].pixel)) {
        rw_buffer[0].color = ct;
        rw_buffer[0].outPixel = int2(texel);
    }

    const float3 grid_rgb = float3(0.0, 0.0, 0.0); // Grid color
    const float grid_alpha = lerp(0.0, 0.5, clamp((grid_pixel_size - 8) / 32.0, 0.0, 1.0)); // Grid alpha based on pixel size

    if (grid_pixel_size > 8)
        ct = lerp(ct, float4(grid_rgb, 1.0), grid_alpha * isGrid);

    bool inside = all(floor(texel) >= 0 && floor(texel) < texture_size);

    switch (channelShow) {
        case DisplayChannel::RGBA:
            ct = sampled;
            break;
        case DisplayChannel::RGB:
            ct = float4(sampled.rgb, 1.0);
            break;
        case DisplayChannel::RChannel:
            ct = float4(sampled.r, sampled.r, sampled.r, 1.0);
            break;
        case DisplayChannel::GChannel:
            ct = float4(sampled.g, sampled.g, sampled.g, 1.0);
            break;
        case DisplayChannel::BChannel:
            ct = float4(sampled.b, sampled.b, sampled.b, 1.0);
            break;
    }
    
    o_color = inside ? ct : float4(0.0, 0.0, 0.0, 1.0);
}
