//
//  DemoViewController.swift
//  MetalDemo
//
//  Created by Timothy Raveling on 10/22/18.
//  Copyright © 2018 Firemark Foundry. All rights reserved.
//

import UIKit

class DemoViewController: MetalViewController {
    
    // MARK: - Outlets and Vars -
    
    var objectToDraw : Cube!
    var worldMatrix : Matrix4!
    
    // MARK: - Actions -
    
    
    // MARK: - Rendering and Game Functions -
    
    override func render(_ drawable: CAMetalDrawable) {
        super.render(drawable)
        
        // Draw the cube
        self.objectToDraw.render(commandQueue: self.commandQueue, pipelineState: self.pipelineState, drawable: drawable, parentModelViewMatrix: self.worldMatrix, projectionMatrix: self.projectionMatrix, clearColor: nil)
    }
    
    override func gameLoop(_ delta: CFTimeInterval) {
        super.gameLoop(delta)
        
        // Update the spinning cube
        self.objectToDraw.updateWithDelta(delta: delta)
    }
    
    // MARK: - VC Functions -
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.worldMatrix = Matrix4()
        self.worldMatrix.translate(0.0, y: 0.0, z: -4)
        self.worldMatrix.rotateAroundX(Matrix4.degrees(toRad: 25), y: 0.0, z: 0.0)
        
        self.objectToDraw = Cube(device: self.metalDevice)
    }
}
