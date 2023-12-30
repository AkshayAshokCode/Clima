//
//  WeatherManager.swift
//  Clima
//
//  Created by Akshay Ashok on 30/12/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation
struct WeatherManager{
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=8644b56762efaa181e2d1cc45782e6d7&units=metric"
    
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude:CLLocationDegrees, longitude:CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    func performRequest(with urlString :String){
        //1.Create a URL
        if let url = URL(string: urlString){
            
            //2. Create a URLSession
            let session = URLSession(configuration: .default)
            
            //3. Give the session a task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil{
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data{
                    if let weather = parseJSON(weatherData: safeData){
                      
                        self.delegate?.didUpdateWeather(self,weather: weather)
                    }
                }
            }
            
            //4. Start the task
            task.resume()
        }
    }
    
    func parseJSON(weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do{
           let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weatherModel = WeatherModel(conditionID: id, cityName: name, temprature: temp)
            return weatherModel
        } catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager:WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}
