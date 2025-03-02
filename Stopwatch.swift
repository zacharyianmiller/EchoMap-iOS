//
//  Stopwatch.swift
//  EchoMap
//
//  Created by Zachary Miller on 3/1/25.
//

import Foundation
import SwiftUI

class Stopwatch: ObservableObject {
    enum TimerState {
        case running
        case stopped
    }
    @Published var mode: TimerState = .stopped
    
    @Published var secondsElapsed: Float = 0.0
    var timer = Timer()
    
    func start() {
        mode = .running
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            self.secondsElapsed += 1.0
        }
    }
    
    func stop() {
        timer.invalidate()
        mode = .stopped
    }
}
