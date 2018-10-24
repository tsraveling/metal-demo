//
//  Light.swift
//  MetalDemo
//
//  Created by Timothy Raveling on 10/24/18.
//  Copyright © 2018 Firemark Foundry. All rights reserved.
//

import Foundation

struct Light {
    
    var color: (Float, Float, Float)
    var ambientIntensity: Float
    
    static func size() -> Int {
        return MemoryLayout<Float>.size * 4
    }
    
    func raw() -> [Float] {
        return [self.color.0, self.color.1, self.color.2, self.ambientIntensity]
    }
}
