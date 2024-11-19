//
//  WeatherViewModel.swift
//  WeatherToMVVM
//
//  Created by Lydia Lu on 2024/11/19.
//

import Foundation

class WeatherViewModel {
    // MARK: - Properties
    private let weatherService: WeatherServiceProtocol
    private var weather: Weather? {
        didSet {
            updateDisplayData()
        }
    }
    
    // MARK: - Binding Properties
    var onWeatherUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    // Display Data
    var locationText: String = ""
    var temperatureText: String = ""
    var humidityText: String = ""
    var conditionText: String = ""
    var forecastItems: [ForecastDisplayItem] = []
    
    init(weatherService: WeatherServiceProtocol = WeatherService()) {
        self.weatherService = weatherService
    }
    
    // MARK: - Public Methods
    func fetchWeather(for location: String) {
        weatherService.fetchWeather(for: location) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let weather):
                    self?.weather = weather
                case .failure(let error):
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    func refreshWeather() {
        guard let currentLocation = weather?.location else { return }
        fetchWeather(for: currentLocation)
    }
    
    // MARK: - Private Methods
    private func updateDisplayData() {
        guard let weather = weather else { return }
        
        locationText = weather.location
        temperatureText = String(format: "%.1f°C", weather.temperature)
        humidityText = "\(weather.humidity)%"
        conditionText = weather.condition.rawValue
        
        forecastItems = weather.forecast.map { forecast in
            ForecastDisplayItem(
                date: formatDate(forecast.date),
                highTemp: String(format: "%.1f°C", forecast.highTemp),
                lowTemp: String(format: "%.1f°C", forecast.lowTemp),
                condition: forecast.condition.rawValue
            )
        }
        
        onWeatherUpdated?()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}
