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
    fileprivate var availabilitySemaphore : DispatchSemaphore
    
    func waitForSemaphore() {
        _ = self.availabilitySemaphore.wait(timeout: .distantFuture)
    }
    
    func greenlightSemaphore() {
        self.availabilitySemaphore.signal()
    }
    
    func fetchNextBuffer(projectionMatrix : Matrix4, modelMatrix : Matrix4, light: Light) -> MTLBuffer {
        
        // Get the next free buffer
        let buffer = self.uniformsBuffers[nextAvailableBufferIndex]
        let bufferPointer = buffer.contents()
        
        // Copy in the transforms
        memcpy(bufferPointer, modelMatrix.raw(), BufferPool.standardMatrixSize)
        memcpy(bufferPointer + BufferPool.standardMatrixSize, projectionMatrix.raw(), BufferPool.standardMatrixSize)
        memcpy(bufferPointer + (BufferPool.standardMatrixSize * 2), light.raw(), Light.size())
        
        // Advance the next buffer index
        self.nextAvailableBufferIndex += 1
        if self.nextAvailableBufferIndex >= poolSize {
            self.nextAvailableBufferIndex = 0
        }
        
        // Pass back the buffer
        return buffer
    }
    
    init(device: MTLDevice, poolSize: Int, bufferSize: Int) {
        
        // Set up the semaphore
        self.availabilitySemaphore = DispatchSemaphore(value: poolSize)
        
        // Set the size of the pool
        self.poolSize = poolSize
        for _ in 0 ..< poolSize {
            
            // Build the individual buffers
            let buffer = device.makeBuffer(length: bufferSize, options: [])!
            self.uniformsBuffers.append(buffer)
        }
    }
    
    deinit {
        
        // As we clear this object, clear up the semaphores we're using
        for _ in 0 ..< self.poolSize {
            self.availabilitySemaphore.signal()
        }
    }
}
