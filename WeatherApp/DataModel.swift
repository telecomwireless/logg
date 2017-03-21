//
//  DataModel.swift
//  WeatherApp
//
//  Created by wireless on 2/5/17.
//  Copyright © 2017 keerthichandra Nagareddy. All rights reserved.
//
import UIKit
import Alamofire

class DataModel {
    
    private var _date: Double?
    private var _temp: String?
    private var _location: String?
    private var _weather: String?
    typealias JSONStandard = Dictionary<String, AnyObject>
    
   // private var cityNames = "portland"
    private var url:URL? = nil
    
    func cityName(_ city:String) {
    
         url = URL(string: "http://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=a7bbbd5e82c675f805e7ae084f742024")!
        
    }
    

var date: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        let date = Date(timeIntervalSince1970: _date!)
        return (_date != nil) ? "Today, \(dateFormatter.string(from: date))" : "Date Invalid"
    }
    

    var temp: String {
        return _temp ?? "0 °C"
    }
    
    var location: String {
        return _location ?? "Location Invalid"
    }
    
    var weather: String {
        return _weather ?? "Weather Invalid"
    }
    
    
    
    func downloadData(completed: @escaping ()-> ()) {
        
        Alamofire.request(url!).responseJSON(completionHandler: {
            response in
            let result = response.result
            
            if let dict = result.value as? JSONStandard, let main = dict["main"] as? JSONStandard, let temp = main["temp"] as? Double, let weatherArray = dict["weather"] as? [JSONStandard], let weather = weatherArray[0]["main"] as? String, let name = dict["name"] as? String, let sys = dict["sys"] as? JSONStandard, let country = sys["country"] as? String, let dt = dict["dt"] as? Double {
                
                self._temp = String(format: "%.0f °C", temp - 273.15)
                self._weather = weather
                self._location = "\(name), \(country)"
                self._date = dt
            }
            
            completed()
        })
    }



}
