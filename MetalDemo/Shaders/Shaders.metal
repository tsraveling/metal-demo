//
//  Shaders.metal
//  MetalDemo
//
//  Created by Timothy Raveling on 10/19/18.
//  Copyright © 2018 Firemark Foundry. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

// This is our basic vertex shader -- it just returns the positions of the vertices.
vertex float4 basic_vertex(const device packed_float3* vertex_array [[ buffer(0) ]],
                           unsigned int vid [[ vertex_id ]]) {
    
    // For the basic shader, just return the position of the given vertex without any extra
    // bells and whistles
    return float4(vertex_array[vid], 1.0);
}

// This is our basic fragment shader.
fragment half4 basic_fragment() {
    
    // Just return white, basically rgba(1,1,1,1).
    return half4(1.0);
}
