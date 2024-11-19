//
//  Weather.swift
//  WeatherToMVVM
//
//  Created by Lydia Lu on 2024/11/19.
//

import Foundation

struct Weather: Codable {
    let temperature: Double
    let humidity: Int
    let condition: WeatherCondition
    let location: String
    let forecast: [DailyForecast]
}

struct DailyForecast: Codable {
    let date: Date
    let highTemp: Double
    let lowTemp: Double
    let condition: WeatherCondition
}

enum WeatherCondition: String, Codable {
    case sunny = "晴天"
    case cloudy = "多雲"
    case rainy = "雨天"
    case snow = "下雪"
}
