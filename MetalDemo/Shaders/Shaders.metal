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
    float4 position [[position]];  //1
    float4 color;
};

// This is our basic vertex shader -- it just returns the positions of the vertices.
vertex VertexOut basic_vertex(const device VertexIn* vertexArray [[ buffer(0) ]],
                           unsigned int vid [[ vertex_id ]]) {
    
    // Get the specific vertex out of the buffer
    VertexIn vertexIn = vertexArray[vid];
    
    // Build the vertex out structure using the position and color passed in
    VertexOut vertexOut;
    vertexOut.position = float4(vertexIn.position,1);
    vertexOut.color = vertexIn.color;
    
    // Return the result
    return vertexOut;
}

// This is our basic fragment shader.
fragment half4 basic_fragment(VertexOut interpolated [[stage_in]]) {
    
    // Just return white, basically rgba(1,1,1,1).
    return half4(interpolated.color[0], interpolated.color[1], interpolated.color[2], interpolated.color[3]);
}
