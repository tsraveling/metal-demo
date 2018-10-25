//
//  Light.swift
//  MetalDemo
//
//  Created by Timothy Raveling on 10/24/18.
//  Copyright © 2018 Firemark Foundry. All rights reserved.
//

import Foundation

struct Light {
    
    var color               : (Float, Float, Float)
    var direction           : (Float, Float, Float)
    var ambientIntensity    : Float
    var diffuseIntensity    : Float
    var shininess           : Float
    var specularIntensity   : Float
    
    static func size() -> Int {
        return MemoryLayout<Float>.size * 12
    }
    
    func raw() -> [Float] {
        return [self.color.0, self.color.1, self.color.2, self.ambientIntensity, direction.0, direction.1, direction.2, diffuseIntensity, shininess, specularIntensity]
    }
}
