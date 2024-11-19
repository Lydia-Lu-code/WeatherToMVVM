import Foundation

protocol WeatherServiceProtocol {
    func fetchWeather(for location: String, completion: @escaping (Result<Weather, WeatherError>) -> Void)
    func saveWeather(_ weather: Weather, for location: String) throws
    func getCachedWeather(for location: String) -> Weather?
}

class WeatherService: WeatherServiceProtocol {
    // MARK: - Properties
    private let storageService: StorageServiceProtocol
    private var weatherCache: [String: Weather] = [:]
    private let weatherKey = "cached_weather"
    
    // 新增 mockData
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
            ],
            description: "晴朗無雲",
            windSpeed: 2.5,
            precipitation: 0.1
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
            ],
            description: "有雨",
            windSpeed: 5.0,
            precipitation: 0.7
        )
    ]
    
    // MARK: - Initialization
    init(storageService: StorageServiceProtocol = StorageService()) {
        self.storageService = storageService
        loadCache()
    }
    
    // MARK: - Public Methods
    func fetchWeather(for location: String, completion: @escaping (Result<Weather, WeatherError>) -> Void) {
        // 先檢查快取
        if let cachedWeather = getCachedWeather(for: location) {
            completion(.success(cachedWeather))
            return
        }
        
        // 模擬網路請求
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            let weather = self.mockWeathers[self.mockIndex]
            self.mockIndex = (self.mockIndex + 1) % self.mockWeathers.count
            
            do {
                try self.saveWeather(weather, for: location)
                DispatchQueue.main.async {
                    completion(.success(weather))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.cacheError))
                }
            }
        }
    }
    
    func saveWeather(_ weather: Weather, for location: String) throws {
        weatherCache[location] = weather
        try saveCache()
    }
    
    func getCachedWeather(for location: String) -> Weather? {
        return weatherCache[location]
    }
    
    // MARK: - Private Methods
    private func loadCache() {
        do {
            if let cached: [String: Weather] = try storageService.load(forKey: weatherKey) {
                self.weatherCache = cached
            }
        } catch {
            print("Failed to load cache: \(error)")
        }
    }
    
    private func saveCache() throws {
        do {
            try storageService.save(weatherCache, forKey: weatherKey)
        } catch {
            throw WeatherError.cacheError
        }
    }
}
