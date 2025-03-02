//
//  ContentView.swift
//  IRPlotTest
//
//  Created by Zachary Miller on 2/23/25.
//

import SwiftUI
import Charts
import AVKit
import AVFoundation

extension FloatingPoint {
    var isInteger: Bool { rounded() == self }
}

struct XLabelParameters {
    let label: String = "Frequency (Hz)"
    let range: ClosedRange<Int> = 15...22050
}

struct YLabelParameters {
    let label: String = "Magnitude (dB)"
    let range: ClosedRange<Int> = -100...10 // default
}

struct ResponseSelectToggle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 500, height: 65)
            .background(.blue)
            .foregroundStyle(.white)
            .clipShape(Rectangle())
    }
}

struct ContentView: View {
    let XParams = XLabelParameters(), YParams = YLabelParameters()
    
    // Read in WAV file
    var impulseResponse1: [Float] = wavToFloatArray("SchermerhornStage1", "wav")
    var impulseResponse2: [Float] = wavToFloatArray("SchermerhornStage2", "wav")
    var impulseResponse3: [Float] = wavToFloatArray("SchermerhornStage3", "wav")
   
    let ds: Int = 32
    
    @State private var tabPath: Int = 0

    var body: some View {
        // Project info
        Text("Project 1")
            .font(.headline)
            .fontWeight(.light)
        Divider()

        VStack {
            let H = downsample(fft(impulseResponse1), ds)
            let NH = H.count

            let F = linspace(0, 44100, NH)
            
            Chart(0..<NH/2, id: \.self) { n in
                LineMark(
                    x: .value(XParams.label,
                              Int(F[n])),
                    y: .value(YParams.label,
                              magTodB(H[n]))
                )
                .interpolationMethod(.monotone)
            }
            // Frequency plot
            .chartXAxisLabel(XParams.label)
            .chartXAxis {
                AxisMarks(
                    values: [20, 100, 1000, 10000, 20000]
                )
            }
            .chartXScale(
                domain: XParams.range,
                type: .log
            )
            // Magnitude plot
            .chartYAxisLabel(YParams.label)
            .chartYScale(
                domain: YParams.range,
                type: .linear
            )
        }
        .aspectRatio(1.45, contentMode: .fit)
        .padding(20)
                
        VStack {
            
            Picker(selection: $tabPath, label: Text("Authentication Path")) {
                Text("Record").tag(0)
                Text("Available IRs").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            Spacer()

            if tabPath == 0 {
                RecorderView()
                    .padding()
            }
            if tabPath == 1 {
                SelectIRView()
                    .padding()
            }
        }
        .background(Color("Color.Background").edgesIgnoringSafeArea(.all))
    }
}

/* Handles what IRs are plotted on graph */
struct SelectIRView: View {
    @State private var isOn = false

    var body: some View {
        VStack {
            // Available audio files in a session
            ScrollView(showsIndicators: false) {
                VStack(alignment: .listRowSeparatorLeading) {
                    ForEach(1..<11) {
                        Toggle("Audio File #\($0)", isOn: $isOn)
                        .toggleStyle(.button)
                        .toggleStyle(ResponseSelectToggle())
                    }
                }
            }
        }
    }
}

struct RecorderView: View {    
    @State var isRecording = false
    let recorder = Recorder()
    
    @ObservedObject var timer = Stopwatch()
    var displayTimer: String = "00:00.00"
    
    func formatTimer(time: Int) -> String {
        /* Milliseconds / [SPEED] % [WHEN_RESET] */
        let minutes = Int(time) / 6000 % 60
        let seconds = Int(time) / 100 % 60
        let milliseconds = Int(time) % 100

        return String(format: "%02i:%02i.%02i", minutes, seconds, milliseconds)
    }
    
    var body : some View {
        
        Text(formatTimer(time: Int(timer.secondsElapsed)))
            .font(.system(size: 22.5, weight: .light, design: .default))
            .monospacedDigit()
        
        ZStack {
            Circle()
                .frame(width: 95, height: 95)
                .foregroundColor(Color.black)
                .opacity(0.2)
            
            Circle()
                .frame(width: 85, height: 85)
                .foregroundColor(Color.white)
            
            Button(action: {
                withAnimation {
                    !isRecording ? self.timer.start() : self.timer.stop()
                    self.isRecording.toggle()
                }
            }) {
                RoundedRectangle(cornerRadius: isRecording ? 4 : 50)
                    .foregroundColor(Color.red)
                    .frame(width: isRecording ? 45 : 75, height: isRecording ? 45 : 75)
            }
        }
    }
}

#Preview {
    ContentView()
}
