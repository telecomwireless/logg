//
//  ViewController.swift
//  WeatherApp
//
//  Created by wireless on 2/5/17.
//  Copyright © 2017 keerthichandra Nagareddy. All rights reserved.
//

import UIKit
import XCGLogger

class ViewController: UIViewController {
    
    
    
    var log = XCGLogger(identifier: "advancedLogger", includeDefaultDestinations: false)

    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var tempLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!

    @IBOutlet weak var weatherLabel: UILabel!
    
    @IBOutlet weak var cityNameField: UITextField!
    
    
    @IBOutlet weak var logButton: UISwitch!
    
        var weather = DataModel()
    
        override func viewDidLoad() {
            super.viewDidLoad()
           
        }
    
    
    @IBAction func logControl() {
        
        
        if logButton.isOn {
        log = XCGLogger(identifier: "advancedLogger", includeDefaultDestinations: false)
            
           // let fileDestination = FileDestination()
            
           // fileDestination.testing()
            
          //  fileDestination.logFileSizeMonitor()
 
    let fileDestination = FileDestination(writeToFile: "/Users/wireless/Documents/logs/file.txt", identifier: "advancedLogger.fileDestination")
        
        // Optionally set some configuration options
        fileDestination.outputLevel = .debug
        fileDestination.showLogIdentifier = false
        fileDestination.showFunctionName = true
        fileDestination.showThreadName = true
        fileDestination.showLevel = true
        fileDestination.showFileName = true
        fileDestination.showLineNumber = true
        fileDestination.showDate = true
            
        fileDestination.rotation = FileDestination.Rotation.alsoWhileWriting
        fileDestination.rotationFileSizeBytes = 1024
        fileDestination.rotationFilesMax = 2
        fileDestination.rotationFileDateFormat = "-yyyy-MM-dd'T'HH:mm"
        fileDestination.rotationFileHasSuffix = true
            
            
        
        // Process this destination in the background
        fileDestination.logQueue = XCGLogger.logQueue
        
        // Add the destination to the logger
        log.add(destination: fileDestination)

        }
 
        
        else {
            
        //    log.setup(level: .none)
            
        }
        
    }
    
    
    @IBAction func submitButton() {
        
        print(cityNameField.text ?? "nothing")
        
        log.debug(self.cityNameField.text)
        
  //      log.isEnabledFor(level: .debug)
        
        weather.cityName(cityNameField.text!)
        
        weather.downloadData( completed: {
            self.updateUI()
        })
        
    }
    
    
    func updateUI() {
        
        dateLabel.text = weather.date
        tempLabel.text = "\(weather.temp)"
        locationLabel.text = weather.location
        weatherLabel.text = weather.weather

    }
    
    
    
    
   
@IBAction func delteLogs() {
    
    if !logButton.isOn {
        
        let fileDest = FileDestination()
        
        fileDest.deleteLogFiles()
        
        print("success from delete files")
        
    //  FileDestination.deleteLogFiles()
        
    }
    
    else{
        
        print("Turn Logging off")
        
    }
       
        
    }
    
    
    
}


