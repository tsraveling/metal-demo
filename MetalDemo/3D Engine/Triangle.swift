//
//  Triangle.swift
//  MetalDemo
//
//  Created by Timothy Raveling on 10/21/18.
//  Copyright © 2018 Firemark Foundry. All rights reserved.
//

import UIKit

class Triangle: Node {
    
    init(device: MTLDevice){
        
        let V0 = Vertex(x:  0.0, y:   1.0, z:   0.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0)
        let V1 = Vertex(x: -1.0, y:  -1.0, z:   0.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0)
        let V2 = Vertex(x:  1.0, y:  -1.0, z:   0.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0)
        
        let verticesArray = [V0,V1,V2]
        super.init(name: "Triangle", vertices: verticesArray, device: device)
    }
    
}
