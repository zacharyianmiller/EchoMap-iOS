//
//  fft.swift
//  EchoMap
//
//  Created by Zachary Miller on 2/26/25.
//

import Accelerate

/* https://gist.github.com/jeremycochoy/45346cbfe507ee9cb96a08c049dfd34f */

public func fft(_ data: [Float], _ returnMag: Bool = true) -> [Float] {
    // Length of input signal
    let length = vDSP_Length(data.count)
    // The power of two of two times the length of the input.
    let log2n = vDSP_Length(ceil(log2(Float(data.count * 2))))
    // Create the instance of the FFT class which allow computing FFT of complex vector with length
    // up to `length`.
    let fftSetup = vDSP.FFT(log2n: log2n, radix: .radix2, ofType: DSPSplitComplex.self)!


    // --- Input / Output arrays
    var forwardInputReal = [Float](data) // Copy the signal here
    var forwardInputImag = [Float](repeating: 0, count: Int(length))
    var forwardOutputReal = [Float](repeating: 0, count: Int(length))
    var forwardOutputImag = [Float](repeating: 0, count: Int(length))
    var magnitudes = [Float](repeating: 0, count: Int(length))

    /// --- Compute FFT
    forwardInputReal.withUnsafeMutableBufferPointer { forwardInputRealPtr in
      forwardInputImag.withUnsafeMutableBufferPointer { forwardInputImagPtr in
        forwardOutputReal.withUnsafeMutableBufferPointer { forwardOutputRealPtr in
          forwardOutputImag.withUnsafeMutableBufferPointer { forwardOutputImagPtr in
            // Input
            let forwardInput = DSPSplitComplex(realp: forwardInputRealPtr.baseAddress!, imagp: forwardInputImagPtr.baseAddress!)
            // Output
            var forwardOutput = DSPSplitComplex(realp: forwardOutputRealPtr.baseAddress!, imagp: forwardOutputImagPtr.baseAddress!)
       
            fftSetup.forward(input: forwardInput, output: &forwardOutput)
            vDSP.absolute(forwardOutput, result: &magnitudes)
          }
        }
      }
    }

    return magnitudes
}
