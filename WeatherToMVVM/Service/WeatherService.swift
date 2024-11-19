//
//  WeatherService-.swift
//  WeatherToMVVM
//
//  Created by Lydia Lu on 2024/11/19.
//

import Foundation

protocol WeatherServiceProtocol {
    func fetchWeather(for location: String, completion: @escaping (Result<Weather, Error>) -> Void)
}


// WeatherService.swift
class WeatherService: WeatherServiceProtocol {
    private var mockIndex = 0
    private let mockWeathers = [
        Weather(
            temperature: 25.5,
            humidity: 65,
            condition: .sunny,
            location: "台北",
            forecast: [
                DailyForecast(date: Date(), highTemp: 27.0, lowTemp: 20.0, condition: .sunny),
                DailyForecast(date: Date().addingTimeInterval(86400), highTemp: 26.0, lowTemp: 19.0, condition: .cloudy),
                DailyForecast(date: Date().addingTimeInterval(172800), highTemp: 24.0, lowTemp: 18.0, condition: .rainy)
            ]
        ),
        Weather(
            temperature: 20.0,
            humidity: 85,
            condition: .rainy,
            location: "台北",
            forecast: [
                DailyForecast(date: Date(), highTemp: 22.0, lowTemp: 18.0, condition: .rainy),
                DailyForecast(date: Date().addingTimeInterval(86400), highTemp: 23.0, lowTemp: 17.0, condition: .cloudy),
                DailyForecast(date: Date().addingTimeInterval(172800), highTemp: 25.0, lowTemp: 19.0, condition: .sunny)
            ]
        )
    ]
    
    func fetchWeather(for location: String, completion: @escaping (Result<Weather, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            let weather = self.mockWeathers[self.mockIndex]
            self.mockIndex = (self.mockIndex + 1) % self.mockWeathers.count
            completion(.success(weather))
        }
    }
}
