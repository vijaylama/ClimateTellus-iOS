//
//  WeatherManager.swift
//  Clima
//
//  Created by Vijay Lama on 3/19/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//
import UIKit

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weathermanager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?APPID=176e1798a899e27b4ef8dbc77d48b57a&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName),US"
        print(urlString)
        performRequest(with: urlString)
    }
    
    func fetchWeath(latitude: Double, longitude: Double ) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String){
        //1. create URL
        
        if let url = URL(string: urlString){
            //2. Create a URL session
            let session = URLSession(configuration: .default)
            
            //3. Give the session a task
            let task =  session.dataTask(with: url) {(data, response, error ) in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                   if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            //4. Start the task
            task.resume()
            
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do{
          let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        } catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
        
    }
    
}
