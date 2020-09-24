//
//  DetailController.swift
//  Server Health WatchKit Extension
//
//  Created by Fernando Alonso Pecina on 21/09/20.
//

import WatchKit
import Foundation
class DetailController: WKInterfaceController {
    @IBOutlet weak var table: WKInterfaceTable!
  
    func loadTable() {
        let url = URL(string: "http://sil.red:9973/healthz")!

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            
            guard let data = data else { return }
            //data = Data(data.utf8)
            do {
                // make sure this JSON is in the format we expect
               // let jsonResponse = try JSONSerialization.jsonObject(with:
               //     dataResponse, options: [])
               // guard let jsonArray = jsonResponse as? [[String: Any]] else {
                 //   return
               // }
                
               
                
                
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let results = json["results"] as! [String: Any]
                    let rowCount = results.keys.count
                    self.table.setNumberOfRows(rowCount, withRowType: "cell")
                    var count = 0
                    for k in results.keys {
                        let row = self.table.rowController(at: count) as! MyRowController
                        let subdata = results[k] as! [String: Any]
                        let subdictionary = subdata["last_known_check"] as! [String: Any]
                        
                        let state = subdictionary["state"] as? String
                        if state != "ok" {
                            row.image.setImage(UIImage(systemName: "hand.thumbsdown.fill" ))
                            row.image.setTintColor(UIColor.white)
                            row.group.setBackgroundColor(UIColor.red)
                        }
                        row.titleLabel.setText(subdata["name"] as? String)
                        row.subtitleLabel.setText(state)
                        count+=1
                    }
                    
                    
                                    }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            
        }
        task.resume()
    }
    
   
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        super.awake(withContext: context)
        loadTable()
    }
    
    override func willActivate() {
        
    }
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
}

class MyRowController: NSObject {
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var subtitleLabel: WKInterfaceLabel!
    @IBOutlet weak var image: WKInterfaceImage!
    @IBOutlet weak var group: WKInterfaceGroup!
}
