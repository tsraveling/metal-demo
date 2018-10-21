//
//  Vertex.swift
//  MetalDemo
//
//  Created by Timothy Raveling on 10/19/18.
//  Copyright © 2018 Firemark Foundry. All rights reserved.
//

import Foundation

struct Vertex {
    
    // Position
    var x,y,z   : Float
    
    // Color
    var r,g,b,a : Float
    
    // Build a buffer from the data here
    func floatBuffer() -> [Float] {
        return [x,y,z,r,g,b,a];
    }
}
