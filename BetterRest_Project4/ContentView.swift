//
//  ContentView.swift
//  BetterRest_Project4
//
//  Created by Jesse Sheehan on 8/1/24.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    //STATIC - means it belongs to the ContentView struct itself!
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .leading, spacing:0) {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing:0) {
                    Text("Desired Amount of Sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                VStack(alignment: .leading, spacing:0) {
                    Text("Daily Coffee Intake")
                        .font(.headline)
                    //SEE CODE BELOW FOR PLURALIFICATION SYNTAX: "^[coffee cup](inflect: true)"
                    //Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 0...20)
                    Picker("Cups of Coffee", selection: $coffeeAmount) {
                        ForEach(0..<21) {
                            Text("^[\($0) cup](inflect: true)")
                        }
                        
                    }.pickerStyle(.wheel)
                    //("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 0...20)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack{
                        Text("Recommended Bedtime:")
                        Text(calculateBedtime())
                    }
                }
            }
            
            .navigationTitle("BetterRest")
//            .toolbar {
//                Button("Calculate", action: calculateBedtime)
//            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    func calculateBedtime() -> String {
        //important to use do/catch because there may not be data or soemthing?
        var sleepTime = Date.now
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            //even though we KNOW they'll be there, it's good to have the nil coalesce to zero, just in case!
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            //find prediction of what bedtime should be, then turn it into something readable
             sleepTime = wakeUp - prediction.actualSleep
//            
//            alertTitle = "Your ideal bedtime is..."
//            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime"
        }
        //showingAlert = true
        return sleepTime.formatted(date: .omitted, time: .shortened)
    }
}

#Preview {
    ContentView()
}


//DATEPICKER
//@State private var wakeUp = Date.now
//
//var body: some View {
//    DatePicker("Please enter a date", selection: $wakeUp, in: Date.now...) //displayedComponents: .hourAndMinute, )
//        .labelsHidden()
//}
//
//func exampleDates() {
//    let tomorrow = Date.now.addingTimeInterval(86400)
//    let range = Date.now...tomorrow
//}

//STEPPERS AND SLIDERS
//@State private var sleepAmount = 8.0
//
//var body: some View {
//    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
//}

