//
//  ContentView.swift
//  BetterRest
//
//  Created by Jared Bell on 7/7/22.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    func calculateBedtime(wakeUp: Date, sleepAmount: Double, coffeeAmount: Int) -> String{
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp-prediction.actualSleep
            return sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            return "Error"
            // alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
    }
    
    let amounts = Array(stride(from: 4.0, to: 12.0, by: 0.25))
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("When do you want to wake up?")
                        .font(.title2)
                    
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                Section {
                    
                    Picker("Desired amount of sleep:", selection: $sleepAmount) {
                        ForEach(amounts, id:\.self) {
                            Text("\($0.formatted()) hours")
                        }
                    }
                }
                Section {
                    Text("Daily coffee intake:")
                        .font(.title2)
                
                    Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                }
                Section {
                    Text("Bedtime: \(calculateBedtime(wakeUp: wakeUp, sleepAmount: sleepAmount,coffeeAmount: coffeeAmount))")
                }
            }
            .navigationTitle("BetterRest")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
