//
//  Weather.swift
//  WeatherToMVVM
//
//  Created by Lydia Lu on 2024/11/19.
//

import Foundation

// WeatherError.swift
enum WeatherError: Error {
    case invalidLocation
    case networkError
    case decodingError
    case cacheError
    
    var localizedDescription: String {
        switch self {
        case .invalidLocation:
            return "無效的位置"
        case .networkError:
            return "網路連線錯誤"
        case .decodingError:
            return "資料解析錯誤"
        case .cacheError:
            return "快取存取錯誤"
        }
    }
}

// Weather.swift 擴展
struct Weather: Codable {
    let temperature: Double
    let humidity: Int
    let condition: WeatherCondition
    let location: String
    let forecast: [DailyForecast]
    let description: String?    // 新增可選屬性
    let windSpeed: Double?      // 新增可選屬性
    let precipitation: Double?  // 新增可選屬性
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


struct ForecastDisplayItem {
    let date: String
    let highTemp: String
    let lowTemp: String
    let condition: String
}
