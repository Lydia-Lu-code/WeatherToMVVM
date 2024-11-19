

import UIKit

class WeatherViewController: UIViewController {
    // MARK: - UI Components
    private lazy var weatherView: WeatherView = {
        let view = WeatherView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    // MARK: - Properties
    private let viewModel: WeatherViewModel
    
    // MARK: - Initialization
    init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.handleUserAction(.locationChanged("台北"))
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "天氣預報"
        view.backgroundColor = .systemBackground
        
        view.addSubview(weatherView)
        
        NSLayoutConstraint.activate([
            weatherView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            weatherView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weatherView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            weatherView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.onWeatherUpdated = { [weak self] displayData in
            self?.updateWeatherDisplay(with: displayData)
        }
        
        viewModel.onForecastUpdated = { [weak self] items in
            self?.weatherView.updateForecast(with: items)
        }
        
        viewModel.onError = { [weak self] message in
            self?.showError(message: message)
        }
        
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            self?.updateLoadingState(isLoading)
        }
    }
    
    @objc private func refreshTapped() {
        viewModel.handleUserAction(.refresh)
    }
    
    // MARK: - Private Methods
    private func updateWeatherDisplay(with data: WeatherViewModel.WeatherDisplayData) {
        weatherView.configure(with: data)
    }
    
    private func updateLoadingState(_ isLoading: Bool) {
        weatherView.setLoading(isLoading)
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "錯誤", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - WeatherViewDelegate
extension WeatherViewController: WeatherViewDelegate {
    func weatherViewDidTapRefresh() {
        viewModel.handleUserAction(.refresh)
    }
    
    func weatherViewDidSelectForecast(at index: Int) {
        viewModel.handleUserAction(.selectForecast(index))
    }
}

// MARK: - WeatherView
private final class WeatherView: UIView {
    // MARK: - UI Components
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let locationLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let humidityLabel = UILabel()
    private let conditionLabel = UILabel()
    private let infoStackView = UIStackView()
    private let descriptionLabel = UILabel()
    private let windSpeedLabel = UILabel()
    private let precipitationLabel = UILabel()
    private let forecastTableView = UITableView(frame: .zero, style: .insetGrouped)
    private let refreshButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Properties
    weak var delegate: WeatherViewDelegate?
    private var forecastItems: [ForecastDisplayItem] = []
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        setupComponents()
        setupLayout()
        setupActions()
    }
    
    // WeatherView class 中的設置方法
    private func setupComponents() {
        // 配置 stackView
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        
        // 配置 infoStackView
        infoStackView.axis = .vertical
        infoStackView.spacing = 8
        
        // 配置標籤
        locationLabel.font = .systemFont(ofSize: 24, weight: .bold)
        locationLabel.textColor = .label
        
        temperatureLabel.font = .systemFont(ofSize: 48, weight: .medium)
        temperatureLabel.textColor = .label
        
        humidityLabel.font = .systemFont(ofSize: 18)
        humidityLabel.textColor = .secondaryLabel
        
        conditionLabel.font = .systemFont(ofSize: 20)
        conditionLabel.textColor = .label
        
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        
        windSpeedLabel.font = .systemFont(ofSize: 16)
        windSpeedLabel.textColor = .secondaryLabel
        
        precipitationLabel.font = .systemFont(ofSize: 16)
        precipitationLabel.textColor = .secondaryLabel
        
        // 配置 TableView
        forecastTableView.register(ForecastCell.self, forCellReuseIdentifier: "ForecastCell")
        forecastTableView.delegate = self
        forecastTableView.dataSource = self
        forecastTableView.backgroundColor = .systemGroupedBackground
        forecastTableView.separatorStyle = .none
        
        // 配置按鈕
        refreshButton.setTitle("重新整理", for: .normal)
        refreshButton.backgroundColor = .systemBlue
        refreshButton.setTitleColor(.white, for: .normal)
        refreshButton.layer.cornerRadius = 8
        refreshButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    }

    private func setupLayout() {
        // 所有元件設置 translatesAutoresizingMaskIntoConstraints = false
        [stackView, infoStackView, forecastTableView, refreshButton, loadingIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        // 添加主要天氣資訊到 stackView
        [locationLabel, temperatureLabel, humidityLabel, conditionLabel].forEach {
            stackView.addArrangedSubview($0)
        }
        
        // 添加詳細資訊到 infoStackView
        [descriptionLabel, windSpeedLabel, precipitationLabel].forEach {
            infoStackView.addArrangedSubview($0)
        }
        
        // 設置約束
        NSLayoutConstraint.activate([
            // stackView 約束
            stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            // infoStackView 約束
            infoStackView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            infoStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            infoStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            // forecastTableView 約束
            forecastTableView.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 20),
            forecastTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            forecastTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            forecastTableView.bottomAnchor.constraint(equalTo: refreshButton.topAnchor, constant: -20),
            
            // refreshButton 約束
            refreshButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            refreshButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            refreshButton.heightAnchor.constraint(equalToConstant: 44),
            refreshButton.widthAnchor.constraint(equalToConstant: 120),
            
            // loadingIndicator 約束
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func setupActions() {
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func refreshButtonTapped() {
        delegate?.weatherViewDidTapRefresh()
    }
    
    // MARK: - Public Methods
    func configure(with data: WeatherViewModel.WeatherDisplayData) {
        locationLabel.text = data.location
        temperatureLabel.text = data.temperature
        humidityLabel.text = data.humidity
        conditionLabel.text = data.condition
        descriptionLabel.text = data.description
        windSpeedLabel.text = data.windSpeed
        precipitationLabel.text = data.precipitation
        updateForecast(with: data.forecast)
    }
    
    func updateForecast(with items: [ForecastDisplayItem]) {
        forecastItems = items
        forecastTableView.reloadData()
    }
    
    func setLoading(_ isLoading: Bool) {
        isLoading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = !isLoading
        alpha = isLoading ? 0.5 : 1.0
    }
}

// MARK: - UITableViewDataSource
extension WeatherView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecastItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell", for: indexPath) as! ForecastCell
        let item = forecastItems[indexPath.row]
        cell.configure(with: item)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension WeatherView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.weatherViewDidSelectForecast(at: indexPath.row)
    }
}

// MARK: - WeatherViewDelegate
protocol WeatherViewDelegate: AnyObject {
    func weatherViewDidTapRefresh()
    func weatherViewDidSelectForecast(at index: Int)
}
