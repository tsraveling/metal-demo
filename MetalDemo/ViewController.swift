//
//  ViewController.swift
//  MetalDemo
//
//  Created by Timothy Raveling on 10/19/18.
//  Copyright © 2018 Firemark Foundry. All rights reserved.
//

import UIKit

import Metal
import MetalKit

class ViewController: UIViewController {
    
    // MARK: - Outlets and class vars -
    
    var metalDevice     : MTLDevice!
    var metalLayer      : CAMetalLayer!
    var vertexBuffer    : MTLBuffer!
    var pipelineState   : MTLRenderPipelineState!
    var commandQueue    : MTLCommandQueue!
    var displayTimer    : CADisplayLink!
    
    // MARK: - World content vars -
    
    var objectToDraw: Triangle!
    
    // MARK: - Actions -
    
    
    // MARK: - Game Loop and Rendering -
    
    func render() {
        
        // Make sure we have a drawable surface
        guard let drawable = self.metalLayer?.nextDrawable() else {
            return
        }
        
        // Create the render pass descriptor
        objectToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable, clearColor: nil)
    }
    
    @objc func gameLoop() {
        
        autoreleasepool {
            self.render()
        }
    }
    
    // MARK: - VC Functions -

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Build the MTLDevice
        self.metalDevice = MTLCreateSystemDefaultDevice()
        
        // Now, construct the Metal layer
        self.metalLayer = CAMetalLayer()
        self.metalLayer.device = metalDevice
        self.metalLayer.pixelFormat = .bgra8Unorm
        self.metalLayer.framebufferOnly = true
        self.metalLayer.frame = self.view.layer.frame
        
        // Add the new Metal layer to the view's layer
        self.view.layer.addSublayer(self.metalLayer)
        
        // Build the triangle object
        self.objectToDraw = Triangle(device: self.metalDevice)
        
        // Set up the renderer using a default library and the renderers we created in Shaders.metal
        let defaultLibrary = self.metalDevice.makeDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")
        
        // Set up the pipeline state descriptor with the library and shader functions we just set up
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        
        // Match the color setting to the layer we created earlier
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        // Initialize the pipline state variable using the descriptor we've just built
        self.pipelineState = try! metalDevice.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        // Build the command queue
        commandQueue = metalDevice.makeCommandQueue()
        
        // Finally, initialize the display timer
        self.displayTimer = CADisplayLink(target: self, selector: #selector(ViewController.gameLoop))
        self.displayTimer.add(to: .main, forMode: .default)
    }
}

