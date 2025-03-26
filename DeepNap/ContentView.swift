//
//  ContentView.swift
//  DeepNap
//
//  Created by Kamol Madaminov on 26/03/25.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    var recommendedBedtime: String {
        calculateBedTime()
    }
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack{
            Form {
                Section {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                Section {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted())", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section {
                    Picker(selection: $coffeeAmount) {
                        ForEach(0...10, id: \.self) {
                            Text("^[\($0) cup](inflect: true)")
                        }
                    } label: {
                        Text("Daily coffee intake")
                            .font(.headline)
                    }
                }
                
                Section {
                    Text("Your ideal bedtime is: \(recommendedBedtime)")
                        .font(.headline)
                }
            }
            .navigationTitle("DeepNap")
        }
    }
    func calculateBedTime() -> String {
            do {
                let config = MLModelConfiguration()
                let model = try SleepCalculator(configuration: config)
                
                let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
                let hour = (components.hour ?? 0) * 60 * 60
                let minutes = (components.minute ?? 0) * 60
                
                let prediction = try model.prediction(wake: Double(hour + minutes), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
                
                let sleepTime = wakeUp - prediction.actualSleep
                return sleepTime.formatted(date: .omitted, time: .shortened)
            } catch {
                return "Error calculating bedtime"
            }
        }

}

#Preview {
    ContentView()
}
