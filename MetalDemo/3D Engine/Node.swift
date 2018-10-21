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
    
    let name: String
    let device: MTLDevice
    var vertexCount: Int
    var vertexBuffer: MTLBuffer
    
    init(name: String, vertices: Array<Vertex>, device: MTLDevice){
        
        // Build the data from the vertex argument
        var vertexData = Array<Float>()
        for vertex in vertices{
            vertexData += vertex.floatBuffer()
        }
        
        // Calculate size of data and create buffer
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        self.vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])!
        
        // Finally, name the node and finish initializing the data
        self.name = name
        self.device = device
        vertexCount = vertices.count
    }
    
    func render(commandQueue: MTLCommandQueue, pipelineState: MTLRenderPipelineState, drawable: CAMetalDrawable, clearColor: MTLClearColor?){
        
        // Build render pass descriptor
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        // Get the command buffer
        let commandBuffer = commandQueue.makeCommandBuffer()!
        
        // Set up the encoder for this node
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount,
                                     instanceCount: vertexCount/3)
        renderEncoder.endEncoding()
        
        // Send the render to the buffer
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
