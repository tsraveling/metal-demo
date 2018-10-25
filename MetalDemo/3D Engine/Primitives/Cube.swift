//
//  Cube.swift
//  MetalDemo
//
//  Created by Timothy Raveling on 10/21/18.
//  Copyright © 2018 Firemark Foundry. All rights reserved.
//

import UIKit

class Cube: Node {
    
    init(device: MTLDevice, commandQueue : MTLCommandQueue){
        
        // Note: the `s` and `t` elements of these vertex objects tell us which chunks of the source PNG
        // to use for the given face of the cube.
        
        //Front
        let A = Vertex(x: -1.0, y:   1.0, z:   1.0, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.25, t: 0.25, nX: 0.0, nY: 0.0, nZ: 1.0)
        let B = Vertex(x: -1.0, y:  -1.0, z:   1.0, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.25, t: 0.50, nX: 0.0, nY: 0.0, nZ: 1.0)
        let C = Vertex(x:  1.0, y:  -1.0, z:   1.0, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.50, t: 0.50, nX: 0.0, nY: 0.0, nZ: 1.0)
        let D = Vertex(x:  1.0, y:   1.0, z:   1.0, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.50, t: 0.25, nX: 0.0, nY: 0.0, nZ: 1.0)
        
        //Left
        let E = Vertex(x: -1.0, y:   1.0, z:  -1.0, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.00, t: 0.25, nX: -1.0, nY: 0.0, nZ: 0.0)
        let F = Vertex(x: -1.0, y:  -1.0, z:  -1.0, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.00, t: 0.50, nX: -1.0, nY: 0.0, nZ: 0.0)
        let G = Vertex(x: -1.0, y:  -1.0, z:   1.0, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.25, t: 0.50, nX: -1.0, nY: 0.0, nZ: 0.0)
        let H = Vertex(x: -1.0, y:   1.0, z:   1.0, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.25, t: 0.25, nX: -1.0, nY: 0.0, nZ: 0.0)
        
        //Right
        let I = Vertex(x:  1.0, y:   1.0, z:   1.0, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.50, t: 0.25, nX: 1.0, nY: 0.0, nZ: 0.0)
        let J = Vertex(x:  1.0, y:  -1.0, z:   1.0, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.50, t: 0.50, nX: 1.0, nY: 0.0, nZ: 0.0)
        let K = Vertex(x:  1.0, y:  -1.0, z:  -1.0, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.75, t: 0.50, nX: 1.0, nY: 0.0, nZ: 0.0)
        let L = Vertex(x:  1.0, y:   1.0, z:  -1.0, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.75, t: 0.25, nX: 1.0, nY: 0.0, nZ: 0.0)
        
        //Top
        let M = Vertex(x: -1.0, y:   1.0, z:  -1.0, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.25, t: 0.00, nX: 0.0, nY: 1.0, nZ: 0.0)
        let N = Vertex(x: -1.0, y:   1.0, z:   1.0, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.25, t: 0.25, nX: 0.0, nY: 1.0, nZ: 0.0)
        let O = Vertex(x:  1.0, y:   1.0, z:   1.0, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.50, t: 0.25, nX: 0.0, nY: 1.0, nZ: 0.0)
        let P = Vertex(x:  1.0, y:   1.0, z:  -1.0, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.50, t: 0.00, nX: 0.0, nY: 1.0, nZ: 0.0)
        
        //Bot
        let Q = Vertex(x: -1.0, y:  -1.0, z:   1.0, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.25, t: 0.50, nX: 0.0, nY: -1.0, nZ: 0.0)
        let R = Vertex(x: -1.0, y:  -1.0, z:  -1.0, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.25, t: 0.75, nX: 0.0, nY: -1.0, nZ: 0.0)
        let S = Vertex(x:  1.0, y:  -1.0, z:  -1.0, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.50, t: 0.75, nX: 0.0, nY: -1.0, nZ: 0.0)
        let T = Vertex(x:  1.0, y:  -1.0, z:   1.0, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.50, t: 0.50, nX: 0.0, nY: -1.0, nZ: 0.0)
        
        //Back
        let U = Vertex(x:  1.0, y:   1.0, z:  -1.0, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.75, t: 0.25, nX: 0.0, nY: 0.0, nZ: -1.0)
        let V = Vertex(x:  1.0, y:  -1.0, z:  -1.0, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.75, t: 0.50, nX: 0.0, nY: 0.0, nZ: -1.0)
        let W = Vertex(x: -1.0, y:  -1.0, z:  -1.0, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 1.00, t: 0.50, nX: 0.0, nY: 0.0, nZ: -1.0)
        let X = Vertex(x: -1.0, y:   1.0, z:  -1.0, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 1.00, t: 0.25, nX: 0.0, nY: 0.0, nZ: -1.0)
        
        // Assemble the array
        let verticesArray:Array<Vertex> = [
            A,B,C ,A,C,D,   //Front
            E,F,G ,E,G,H,   //Left
            I,J,K ,I,K,L,   //Right
            M,N,O ,M,O,P,   //Top
            Q,R,S ,Q,S,T,   //Botttom
            U,V,W ,U,W,X    //Back
        ]
        
        // Set up the texture
        let texture = MetalTexture(resourceName: "cube", ext: "png", mipmaped: true)
        texture.loadTexture(device: device, commandQ: commandQueue, flip: true)
        
        super.init(name: "Cube", vertices: verticesArray, device: device, texture: texture.texture)
    }
    
    func setRotation(x : Float, y : Float, z : Float) {
        self.rotationX = x
        self.rotationY = y
        self.rotationZ = z
    }
    
    override func updateWithDelta(delta: CFTimeInterval) {
        
        // Update the base class
        super.updateWithDelta(delta: delta)
        
        // Rotate the cube
        let secsPerMove: Float = 6.0
        rotationY = sinf( Float(time) * 2.0 * Float(Double.pi) / secsPerMove)
        rotationX = sinf( Float(time) * 2.0 * Float(Double.pi) / secsPerMove)
    }
}
