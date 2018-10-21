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
    
    var metalDevice      : MTLDevice!
    var metalLayer       : CAMetalLayer!
    var pipelineState    : MTLRenderPipelineState!
    var commandQueue     : MTLCommandQueue!
    var displayTimer     : CADisplayLink!
    var projectionMatrix : Matrix4!
    
    // MARK: - World content vars -
    
    var objectToDraw: Cube!
    
    // MARK: - Actions -
    
    
    // MARK: - Game Loop and Rendering -
    
    func render() {
        
        // Make sure we have a drawable surface
        guard let drawable = self.metalLayer?.nextDrawable() else {
            return
        }
        
        // Create the render pass descriptor
        let worldModelMatrix = Matrix4()
        worldModelMatrix.translate(0.0, y: 0.0, z: -7.0)
        worldModelMatrix.rotateAroundX(Matrix4.degrees(toRad: 25), y: 0.0, z: 0.0)
        
        objectToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable, parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix ,clearColor: nil)
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
        
        // Set up the projection matrix
        self.projectionMatrix = Matrix4.makePerspectiveViewAngle(Matrix4.degrees(toRad: 85.0), aspectRatio: Float(self.view.bounds.size.width / self.view.bounds.size.height), nearZ: 0.01, farZ: 100.0)
        
        // Now, construct the Metal layer
        self.metalLayer = CAMetalLayer()
        self.metalLayer.device = metalDevice
        self.metalLayer.pixelFormat = .bgra8Unorm
        self.metalLayer.framebufferOnly = true
        self.metalLayer.frame = self.view.layer.frame
        
        // Add the new Metal layer to the view's layer
        self.view.layer.addSublayer(self.metalLayer)
        
        // Build the triangle object
        self.objectToDraw = Cube(device: self.metalDevice)
        
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

