import Foundation

class WeatherViewModel {
    // MARK: - Output
    struct WeatherDisplayData {
        let location: String
        let temperature: String
        let humidity: String
        let condition: String
        let description: String
        let windSpeed: String
        let precipitation: String
        let forecast: [ForecastDisplayItem]
    }
    
    // MARK: - Input
    enum UserAction {
        case refresh
        case locationChanged(String)
        case selectForecast(Int)
    }
    
    // MARK: - Properties
    private let weatherService: WeatherServiceProtocol
    private let storageService: StorageServiceProtocol
    private var currentWeather: Weather? {
        didSet {
            updateDisplayData()
        }
    }
    
    private var isLoading = false {
        didSet {
            onLoadingStateChanged?(isLoading)
        }
    }
    
    // MARK: - Bindings
    var onWeatherUpdated: ((WeatherDisplayData) -> Void)?
    var onForecastUpdated: (([ForecastDisplayItem]) -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    
    // MARK: - Display Data
    var locationText: String = ""
    var temperatureText: String = ""
    var humidityText: String = ""
    var conditionText: String = ""
    var descriptionText: String = ""
    var windSpeedText: String = ""
    var precipitationText: String = ""
    var forecastItems: [ForecastDisplayItem] = []
    
    // MARK: - Initialization
    init(weatherService: WeatherServiceProtocol, storageService: StorageServiceProtocol) {
        self.weatherService = weatherService
        self.storageService = storageService
    }
    
    // MARK: - Public Methods
    func handleUserAction(_ action: UserAction) {
        switch action {
        case .refresh:
            refreshWeather()
        case .locationChanged(let location):
            fetchWeather(for: location)
        case .selectForecast(let index):
            handleForecastSelection(at: index)
        }
    }
    
    func fetchWeather(for location: String) {
        isLoading = true
        weatherService.fetchWeather(for: location) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let weather):
                    self?.currentWeather = weather
                case .failure(let error):
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    func refreshWeather() {
        if let location = currentWeather?.location {
            fetchWeather(for: location)
        }
    }
    
    // MARK: - Private Methods
    private func updateDisplayData() {
        guard let weather = currentWeather else { return }
        
        let displayData = WeatherDisplayData(
            location: weather.location,
            temperature: formatTemperature(weather.temperature),
            humidity: formatHumidity(weather.humidity),
            condition: weather.condition.rawValue,
            description: weather.description ?? "無詳細描述",
            windSpeed: formatWindSpeed(weather.windSpeed),
            precipitation: formatPrecipitation(weather.precipitation),
            forecast: formatForecastItems(weather.forecast)
        )
        
        DispatchQueue.main.async { [weak self] in
            self?.onWeatherUpdated?(displayData)
            self?.onForecastUpdated?(self?.forecastItems ?? [])
        }
        
        // 更新顯示數據
        locationText = weather.location
        temperatureText = formatTemperature(weather.temperature)
        humidityText = formatHumidity(weather.humidity)
        conditionText = weather.condition.rawValue
        descriptionText = weather.description ?? "無詳細描述"
        windSpeedText = formatWindSpeed(weather.windSpeed)
        precipitationText = formatPrecipitation(weather.precipitation)
        forecastItems = formatForecastItems(weather.forecast)
    }
    
    private func handleForecastSelection(at index: Int) {
        guard index < forecastItems.count else { return }
        // 處理預報選擇的邏輯可以在這裡實作
    }
    
    private func formatTemperature(_ temp: Double) -> String {
        return String(format: "%.1f°C", temp)
    }
    
    private func formatHumidity(_ humidity: Int) -> String {
        return "\(humidity)%"
    }
    
    private func formatWindSpeed(_ speed: Double?) -> String {
        guard let speed = speed else { return "無風速資料" }
        return String(format: "%.1f m/s", speed)
    }
    
    private func formatPrecipitation(_ precipitation: Double?) -> String {
        guard let precipitation = precipitation else { return "無降雨機率" }
        return String(format: "%.0f%%", precipitation * 100)
    }
    
    private func formatForecastItems(_ forecasts: [DailyForecast]) -> [ForecastDisplayItem] {
        return forecasts.map { forecast in
            ForecastDisplayItem(
                date: formatDate(forecast.date),
                highTemp: formatTemperature(forecast.highTemp),
                lowTemp: formatTemperature(forecast.lowTemp),
                condition: forecast.condition.rawValue
            )
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}

