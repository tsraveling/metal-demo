//
//  Shaders.metal
//  MetalDemo
//
//  Created by Timothy Raveling on 10/19/18.
//  Copyright © 2018 Firemark Foundry. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

// Structs for worldspace entities
struct Light {
    packed_float3 color;
    float ambientIntensity;
};

// Structs for vertices and uniforms
struct VertexIn {
    packed_float3 position;
    packed_float4 color;
    packed_float2 texCoord;
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
    float2 texCoord;
};

struct Uniforms {
    float4x4 modelMatrix;
    float4x4 projectionMatrix;
    Light light;
};

// Basic vertex shader -- pass location, color, and texture data on so the fragment shader can use that information
vertex VertexOut basic_vertex(const device VertexIn* vertex_array   [[ buffer(0) ]],
                              const device Uniforms& uniforms       [[ buffer(1) ]],
                              unsigned int vid                      [[ vertex_id ]]) {
    
    // Pull the matrix
    float4x4 modelMatrix = uniforms.modelMatrix;
    float4x4 projectionMatrix = uniforms.projectionMatrix;
    
    // Get the specific vertex out of the buffer
    VertexIn vertexIn = vertex_array[vid];
    
    // Build the vertex out structure using the position and color passed in
    VertexOut vertexOut;
    
    // Multiply in the projection matrix and the model transform matrix. Note that because this is basically a vector,
    // order of multiplication makes a big difference.
    vertexOut.position = projectionMatrix * modelMatrix * float4(vertexIn.position,1);
    vertexOut.color = vertexIn.color;
    vertexOut.texCoord = vertexIn.texCoord;
    
    // Return the result
    return vertexOut;
}

// Basic fragment shader. Return a pixel color defined by a combination of color, texture, and light.
fragment float4 basic_fragment(VertexOut interpolated           [[stage_in]],
                               const device Uniforms& uniforms  [[ buffer(1) ]],
                               texture2d<float> tex2D           [[ texture(0)]],
                               sampler sampler2D                [[ sampler(0) ]] ) {
    
    // Get ambient light
    Light light = uniforms.light;
    float4 ambientColor = float4(light.color * light.ambientIntensity, 1);
    
    // Get vertex color
    float4 vertexColor = interpolated.color;
    
    // Get texture color
    float4 textureColor = tex2D.sample(sampler2D, interpolated.texCoord);
    
    // Return the interpolated part of the texture for the given vertex
    return ambientColor * vertexColor * textureColor;
}
