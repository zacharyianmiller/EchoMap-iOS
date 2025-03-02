//
//  fileconvert.swift
//  EchoMap
//
//  Created by Zachary Miller on 2/26/25.
//

import AVFoundation

/* https://stackoverflow.com/questions/34751294/how-can-i-generate-an-array-of-floats-from-an-audio-file-in-swift */

public func wavToFloatArray(_ fname: String, _ ext: String) -> [Float] {
    let url = Bundle.main.url(forResource: fname, withExtension: ext)
    let file = try! AVAudioFile(forReading: url!)
    let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: 1, interleaved: false)

    // Buffer maxes out at nearest POT just greater than 10s @ 44.1kHz
    let buf = AVAudioPCMBuffer(pcmFormat: format!, frameCapacity: 524288)!
    try! file.read(into: buf)

    // Zero-pad IR if not POT
    if (log2(Float(buf.frameLength)).isInteger) {
        let targetPower = Float(nextpow2(Float(Float(buf.frameLength))))
        let neededZeros = pow(2, targetPower) - Float(buf.frameLength)
        
        // Move buffer to array for padding
        var tempArray = [Float](
            UnsafeBufferPointer(
                start: buf.floatChannelData?[0],
                count:Int(buf.frameLength)
            )
        )

        tempArray += Array(repeating: 0.0, count: Int(neededZeros))
        return tempArray
    }
    
    // Entire audio file
    return [Float](UnsafeBufferPointer(start: buf.floatChannelData?[0], count:Int(buf.frameLength)))
}
