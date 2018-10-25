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
    packed_float3 direction;
    float diffuseIntensity;
    float shininess;
    float specularIntensity;
};

// Structs for vertices and uniforms
struct VertexIn {
    packed_float3 position;
    packed_float4 color;
    packed_float2 texCoord;
    packed_float3 normal;
};

struct VertexOut {
    float4 position [[position]];
    float3 fragmentPosition;
    float4 color;
    float2 texCoord;
    float3 normal;
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
    
    // Add the fragment position (position of fragment relative to camera)
    vertexOut.fragmentPosition = (modelMatrix * float4(vertexIn.position, 1)).xyz;
    
    // Add in color data
    vertexOut.color = vertexIn.color;
    
    // Add in texture data
    vertexOut.texCoord = vertexIn.texCoord;
    
    // Add in normal data
    vertexOut.normal = (modelMatrix * float4(vertexIn.normal, 0.0)).xyz;
    
    // Return the result
    return vertexOut;
}

// Basic fragment shader. Return a pixel color defined by a combination of color, texture, and light.
fragment float4 basic_fragment(VertexOut interpolated           [[stage_in]],
                               const device Uniforms& uniforms  [[ buffer(1) ]],
                               texture2d<float> tex2D           [[ texture(0)]],
                               sampler sampler2D                [[ sampler(0) ]] ) {
    
    // Get vertex color
    float4 vertexColor = interpolated.color;
    
    // Get texture color
    float4 textureColor = tex2D.sample(sampler2D, interpolated.texCoord);
    
    // Get ambient light
    Light light = uniforms.light;
    float4 ambientColor = float4(light.color * light.ambientIntensity, 1);
    
    // Get the diffuse factor by using the dot product of the vertex's normal and the direction of the light (eliminating
    // the negative values of vertices facing away from us)
    float diffuseFactor = max(0.0, dot(interpolated.normal, (float3)light.direction));
    
    // From that factor combined with the color of the light itself, get the diffuse color.
    float4 diffuseColor = float4(light.color * light.diffuseIntensity * diffuseFactor, 1.0);
    
    // Get the camera position
    float3 camera = normalize(interpolated.fragmentPosition);
    
    // Get the reflection vector
    float3 reflection = reflect((float3)light.direction, interpolated.normal);
    
    // Get the specular factor based on how close to reflection the vertex is to the camera vector, the light direction, and the shininess
    float specularFactor = pow(max(0.0, dot(reflection, camera)), light.shininess);
    
    // Generate the specular color from that
    float4 specularColor = float4(light.color * light.specularIntensity * specularFactor, 1.0);
    
    // Return the resulting color value for this pixel
    return (ambientColor + diffuseColor + specularColor) * vertexColor * textureColor;
}
