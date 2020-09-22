//
//  InterfaceController.swift
//  Server Health WatchKit Extension
//
//  Created by Fernando Alonso Pecina on 21/09/20.
//

import WatchKit
import Foundation
import HealthKit

class InterfaceController: WKInterfaceController {
    @IBOutlet weak var circleMain: WKInterfaceActivityRing!
    @IBOutlet weak var labelText: WKInterfaceLabel!
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
    }
    @IBAction func circleMainTouch() {
        self.pushController(withName: "DetailController", context: nil)
    }
    func refresh() {
        let url = URL(string: "http://example.com:9973/healthz")!

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            
            guard let data = data else { return }
            //data = Data(data.utf8)
            do {
                // make sure this JSON is in the format we expect
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print(json)
                    // try to read out a string array
                    let state = json["state"]
                    let stateString = state as! String
                    print(stateString)
                    if var currentHP = json["currentHP"] as? Double {
                        currentHP=currentHP*100.0
                        self.labelText.setText(String(format: "%.0f%% health is %@", currentHP,stateString))
                        let summary = HKActivitySummary()
                        let goal: Double = 100

                        summary.activeEnergyBurned = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: currentHP)
                        
                        summary.activeEnergyBurnedGoal = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: goal)
                        
                        summary.appleExerciseTime = HKQuantity(unit: HKUnit.minute(), doubleValue: currentHP)
                        summary.appleExerciseTimeGoal = HKQuantity(unit: HKUnit.minute(), doubleValue: goal)

                        summary.appleStandHours = HKQuantity(unit: HKUnit.count(), doubleValue: currentHP)
                        summary.appleStandHoursGoal = HKQuantity(unit: HKUnit.count(), doubleValue: goal)
                        
                        self.circleMain.setActivitySummary(summary, animated: true)
                    }
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            

            
            
        }

        task.resume()
    }
    override func willActivate() {
       refresh()
        
        
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }

}
