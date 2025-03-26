//
//  ContentView.swift
//  DeepNap
//
//  Created by Kamol Madaminov on 26/03/25.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = Date.now
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack{
            VStack {
                Text("When do you want to wake up?")
                DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                
                Text("Desired amount of sleep")
                Stepper("\(sleepAmount.formatted())", value: $sleepAmount, in: 4...12, step: 0.25)
                
                Text("Daily coffee intake")
                Stepper("\(coffeeAmount) cup(s)", value: $coffeeAmount, in: 0...10)
                
            }
            .navigationTitle("DeepNap")
            .toolbar {
                Button("Calculate", action: calculateBedTime)
            }
            .alert(alertTitle, isPresented: $showAlert){
                Button("OK"){}
            } message: {
                Text(alertMessage)
            }
        }
    }
    func calculateBedTime(){
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minutes = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minutes), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry there was a problem calculating your sleep time."
            
        }
        showAlert = true
    }
    

}

#Preview {
    ContentView()
}
