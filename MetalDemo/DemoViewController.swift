//
//  DemoViewController.swift
//  MetalDemo
//
//  Created by Timothy Raveling on 10/22/18.
//  Copyright © 2018 Firemark Foundry. All rights reserved.
//

import UIKit
import CoreMotion

class DemoViewController: MetalViewController {
    
    // MARK: - Outlets and Vars -
    
    var objectToDraw : Cube!
    var worldMatrix : Matrix4!
    let motionManager = CMMotionManager()
    
    // MARK: - Actions -
    
    
    // MARK: - Rendering and Game Functions -
    
    override func render(_ drawable: CAMetalDrawable) {
        super.render(drawable)
        
        // Draw the cube
        self.objectToDraw.render(commandQueue: self.commandQueue, pipelineState: self.pipelineState, drawable: drawable, parentModelViewMatrix: self.worldMatrix, projectionMatrix: self.projectionMatrix, clearColor: nil)
    }
    
    override func gameLoop(_ delta: CFTimeInterval) {
        super.gameLoop(delta)
        
        // Make suer we have access to the gyro
        if let gyroData = motionManager.gyroData {
            
            // Set sensitivity threshold for the gyro
            let threshold : Float = 0.02
            
            // Grab x and y values (we're not using Z)
            var x = Float(gyroData.rotationRate.x)
            var y = Float(gyroData.rotationRate.y)
            
            // Only use the vars if they're under the threshold -- this prevents gyro drifting.
            if (abs(x) < threshold) { x = 0 }
            if (abs(y) < threshold) { y = 0 }
            
            // Update the rotation of the object using the values
            self.objectToDraw.rotationX += y * Float(delta)
            self.objectToDraw.rotationY += x * Float(delta)
        }
    }
    
    // MARK: - VC Functions -
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.worldMatrix = Matrix4()
        self.worldMatrix.translate(0.0, y: 0.0, z: -4)
        self.worldMatrix.rotateAroundX(0.0, y: 0.0, z: 0.0)
     
        // Build our pumpkin
        self.objectToDraw = Cube(device: self.metalDevice, commandQueue: self.commandQueue)
        
        // Set up the accelerometer
        motionManager.startGyroUpdates()
    }
}
