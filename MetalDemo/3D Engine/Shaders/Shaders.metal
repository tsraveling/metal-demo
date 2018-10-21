//
//  Shaders.metal
//  MetalDemo
//
//  Created by Timothy Raveling on 10/19/18.
//  Copyright © 2018 Firemark Foundry. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

// Build structs for vertices
struct VertexIn {
    packed_float3 position;
    packed_float4 color;
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
};

struct Uniforms {
    float4x4 modelMatrix;
    float4x4 projectionMatrix;
};

// This is our basic vertex shader -- it just returns the positions of the vertices.
vertex VertexOut basic_vertex(const device VertexIn* vertex_array [[ buffer(0) ]],
                              const device Uniforms&  uniforms    [[ buffer(1) ]],
                              unsigned int vid [[ vertex_id ]]) {
    
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
    
    // Return the result
    return vertexOut;
}

// This is our basic fragment shader.
fragment half4 basic_fragment(VertexOut interpolated [[stage_in]]) {
    
    // Just return white, basically rgba(1,1,1,1).
    return half4(interpolated.color[0], interpolated.color[1], interpolated.color[2], interpolated.color[3]);
}
