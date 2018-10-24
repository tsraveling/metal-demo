//
//  BufferPool.swift
//  MetalDemo
//
//  Created by Timothy Raveling on 10/23/18.
//  Copyright © 2018 Firemark Foundry. All rights reserved.
//

import UIKit
import Metal

class BufferPool: NSObject {
    
    // Declare some default values so that we can quickly tweak how our engine works overall
    static let standardMatrixSize = MemoryLayout<Float>.size * Matrix4.numberOfElements()
    static let defaultSize = 3
   
    // Vars defining how this pool operates
    let poolSize : Int
    fileprivate var uniformsBuffers: [MTLBuffer] = []
    fileprivate var nextAvailableBufferIndex = 0
    
    func fetchNextBuffer(projectionMatrix : Matrix4, modelMatrix : Matrix4) -> MTLBuffer {
        
        // Get the next free buffer
        let buffer = self.uniformsBuffers[nextAvailableBufferIndex]
        let bufferPointer = buffer.contents()
        
        // Copy in the transforms
        memcpy(bufferPointer, modelMatrix.raw(), BufferPool.standardMatrixSize)
        memcpy(bufferPointer + BufferPool.standardMatrixSize, projectionMatrix.raw(), BufferPool.standardMatrixSize)
        
        // Advance the next buffer index
        self.nextAvailableBufferIndex += 1
        if self.nextAvailableBufferIndex >= poolSize {
            self.nextAvailableBufferIndex = 0
        }
        
        // Pass back the buffer
        return buffer
    }
    
    init(device: MTLDevice, poolSize: Int, bufferSize: Int) {
        
        // Set the size of the pool
        self.poolSize = poolSize
        for _ in 0 ..< poolSize {
            
            // Build the individual buffers
            let buffer = device.makeBuffer(length: bufferSize, options: [])!
            self.uniformsBuffers.append(buffer)
        }
    }
}
