//
//  Node.swift
//  MetalDemo
//
//  Created by Timothy Raveling on 10/21/18.
//  Copyright © 2018 Firemark Foundry. All rights reserved.
//

import UIKit
import Metal
import QuartzCore

class Node {
    
    // Meta and render attributes
    
    let name: String
    let device: MTLDevice
    var vertexCount: Int
    var vertexBuffer: MTLBuffer
    var time : CFTimeInterval = 0.0
    var bufferPool : BufferPool
    let light = Light(color: (1.0, 1.0, 1.0), ambientIntensity: 0.2)
    
    // Texturing attributes
    
    var texture : MTLTexture
    lazy var samplerState : MTLSamplerState? = Node.defaultSampler(device: self.device)
    
    // Transform attributes
    
    var positionX: Float = 0.0
    var positionY: Float = 0.0
    var positionZ: Float = 0.0
    
    var rotationX: Float = 0.0
    var rotationY: Float = 0.0
    var rotationZ: Float = 0.0
    var scale: Float     = 1.0
    
    init(name: String, vertices: Array<Vertex>, device: MTLDevice, texture: MTLTexture){
        
        // Build the data from the vertex argument
        var vertexData = Array<Float>()
        for vertex in vertices{
            vertexData += vertex.floatBuffer()
        }
        
        // Calculate size of data and create buffer
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        self.vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])!
        
        // Name the node and finish initializing the data
        self.name = name
        self.device = device
        vertexCount = vertices.count
        
        // Add the texture
        self.texture = texture
        
        // Build the buffer pool
        let uniformsBufferSize = (BufferPool.standardMatrixSize * 2) + Light.size()
        self.bufferPool = BufferPool(device: device, poolSize: BufferPool.defaultSize, bufferSize: uniformsBufferSize)
    }
    
    func render(commandQueue: MTLCommandQueue, pipelineState: MTLRenderPipelineState, drawable: CAMetalDrawable, parentModelViewMatrix: Matrix4, projectionMatrix: Matrix4, clearColor: MTLClearColor?){
        
        // Build render pass descriptor
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        // Get the command buffer
        let commandBuffer = commandQueue.makeCommandBuffer()!
        
        // Notify bufferPool's sempahore on completion of task
        commandBuffer.addCompletedHandler { _ in
            self.bufferPool.greenlightSemaphore()
        }
        
        // Set up the encoder for this node
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setCullMode(MTLCullMode.front)
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        // Attach the texture
        renderEncoder.setFragmentTexture(self.texture, index: 0)
        if let samplerState = self.samplerState {
            renderEncoder.setFragmentSamplerState(samplerState, index: 0)
        }
        
        // Build transformation matrix
        let nodeModelMatrix = self.modelMatrix()
        nodeModelMatrix.multiplyLeft(parentModelViewMatrix)
        
        // Get the uniform buffer from the buffer pool
        let uniformBuffer = bufferPool.fetchNextBuffer(projectionMatrix: projectionMatrix, modelMatrix: nodeModelMatrix, light: self.light)
        
        // Set the vertex buffer
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 1)
        
        // Draw the node
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: vertexCount/3)
        renderEncoder.endEncoding()
        
        // Send the render to the buffer
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func modelMatrix() -> Matrix4 {
        
        // Apply transform using the Matrix4 class
        let matrix = Matrix4()
        matrix.translate(positionX, y: positionY, z: positionZ)
        matrix.rotateAroundX(rotationX, y: rotationY, z: rotationZ)
        matrix.scale(scale, y: scale, z: scale)
        return matrix
    }
    
    func updateWithDelta(delta: CFTimeInterval) {
        self.time += delta
    }
    
    class func defaultSampler(device: MTLDevice) -> MTLSamplerState {
        
        let sampler = MTLSamplerDescriptor()
        
        // Use nearest-neighbor filtering for efficiency reasons
        sampler.minFilter             = MTLSamplerMinMagFilter.nearest
        sampler.magFilter             = MTLSamplerMinMagFilter.nearest
        sampler.mipFilter             = MTLSamplerMipFilter.nearest
        
        // Limit anistropic sampling to one
        sampler.maxAnisotropy         = 1
        
        // Use clamp-to-edge in case we accidentally use a texture that's too small
        sampler.sAddressMode          = MTLSamplerAddressMode.clampToEdge
        sampler.tAddressMode          = MTLSamplerAddressMode.clampToEdge
        sampler.rAddressMode          = MTLSamplerAddressMode.clampToEdge
        
        // Used normalized instead of pixel coordinates
        sampler.normalizedCoordinates = true
        
        // Set clamp to the full range
        sampler.lodMinClamp           = 0
        sampler.lodMaxClamp           = .greatestFiniteMagnitude
        
        return device.makeSamplerState(descriptor: sampler)!
    }
}
