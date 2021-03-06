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

class MetalViewController: UIViewController {
    
    // MARK: - Outlets and class vars -
    
    var metalDevice      : MTLDevice!
    var metalLayer       : CAMetalLayer!
    var pipelineState    : MTLRenderPipelineState!
    var commandQueue     : MTLCommandQueue!
    var displayTimer     : CADisplayLink!
    var projectionMatrix : Matrix4!
    
    // Timing for rotation
    fileprivate var lastFrameTimestamp : CFTimeInterval = 0.0
    
    // MARK: - Actions -
    
    
    // MARK: - Overrideable functions -
    
    func render(_ drawable : CAMetalDrawable) {
        
    }
    
    func gameLoop(_ delta: CFTimeInterval) {
        
    }
    
    // MARK: - Game Loop and Rendering -
    
    fileprivate func baseRender() {
        
        // Make sure we have a drawable surface
        guard let drawable = self.metalLayer?.nextDrawable() else {
            return
        }
        
        // Perform the overrideabble function
        self.render(drawable)
    }
    
    @objc fileprivate func newFrame(displayLink: CADisplayLink){
        
        // Initialize the timestamp if we need to
        if self.lastFrameTimestamp == 0.0 {
            self.lastFrameTimestamp = displayLink.timestamp
        }
        
        // Get the delta from the timestamp
        let delta: CFTimeInterval = displayLink.timestamp - lastFrameTimestamp
        lastFrameTimestamp = displayLink.timestamp
        
        // Send the delta to the gameloop
        self.baseGameLoop(delta)
    }
    
    
    @objc fileprivate func baseGameLoop(_ delta: CFTimeInterval) {
        
        // Perform the overrideable function
        self.gameLoop(delta)
        
        // Perform the render
        autoreleasepool {
            self.baseRender()
        }
    }
    
    // MARK: - VC Functions -
    
    func updateProjectionMatrix() {
        self.projectionMatrix = Matrix4.makePerspectiveViewAngle(Matrix4.degrees(toRad: 85.0), aspectRatio: Float(self.view.bounds.size.width / self.view.bounds.size.height), nearZ: 0.01, farZ: 100.0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Build the MTLDevice
        self.metalDevice = MTLCreateSystemDefaultDevice()
        
        // Set up the projection matrix
        self.updateProjectionMatrix()
        
        // Now, construct the Metal layer
        self.metalLayer = CAMetalLayer()
        self.metalLayer.device = metalDevice
        self.metalLayer.pixelFormat = .bgra8Unorm
        self.metalLayer.framebufferOnly = true
        
        // Add the new Metal layer to the view's layer
        self.view.layer.addSublayer(self.metalLayer)
        
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
        self.displayTimer = CADisplayLink(target: self, selector: #selector(self.newFrame(displayLink:)))
        self.displayTimer.add(to: .main, forMode: .default)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Adjust the Metal layer if the view autorotates or otherwise changes frame
        if let window = view.window {
            
            // Get the new size and scale (Retina or Retina+) of the view
            let layerSize = view.bounds.size
            let scale = window.screen.nativeScale
            
            // Account for Retina
            view.contentScaleFactor = scale
            
            // Update Metal with the new values
            metalLayer.frame = CGRect(x: 0, y: 0, width: layerSize.width, height: layerSize.height)
            metalLayer.drawableSize = CGSize(width: layerSize.width * scale, height: layerSize.height * scale)
        }
        
        // Update the projection matrix
        self.updateProjectionMatrix()
    }
}

