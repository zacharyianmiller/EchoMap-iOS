//
//  math.swift
//  EchoMap
//
//  Created by Zachary Miller on 2/26/25.
//

import Foundation
import Numerics

/* Returns closes integer power of 2 */
public func nextpow2(_ x: Float) -> Int {
    if x <= 0 { return 0 }
    return Int(ceil(log2(x)))
}

public func linearTodB(_ x: Float) -> Float {
    20 * log10(abs(x))
}

public func magTodB(_ x: Float) -> Float {
    20 * log10(x)
}

public func downsample(_ x: [Float], _ ds: Int) -> [Float] {
    var output = [Float]()
    for n in stride(from: 0, through: x.count - 1, by: ds) {
        output.append(x[n])
    }
    return output
}

public func linspace(_ x1: Float, _ x2: Float, _ N: Int) -> [Float] {
    precondition(N > 1, "Length of array return should be greater than 1")

    let step = (x2 - x1) / Float(N - 1)
    
    // Iterate
    return (0 ..< N).map { x1 + Float($0) * step }
}
