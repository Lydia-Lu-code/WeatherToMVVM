//
//  WeatherViewController.swift
//  WeatherToMVVM
//
//  Created by Lydia Lu on 2024/11/19.
//

import UIKit

class WeatherViewController: UIViewController {
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
    private let forecastTableView = UITableView()
    private let refreshButton = UIButton(type: .system)
    
    // MARK: - Properties
    private let viewModel: WeatherViewModel
    
    // MARK: - Initialization
    init(viewModel: WeatherViewModel = WeatherViewModel()) {
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
        viewModel.fetchWeather(for: "台北")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        title = "天氣預報"
        
        // 配置標籤樣式
        locationLabel.font = .systemFont(ofSize: 24, weight: .bold)
        temperatureLabel.font = .systemFont(ofSize: 48, weight: .medium)
        humidityLabel.font = .systemFont(ofSize: 18)
        conditionLabel.font = .systemFont(ofSize: 20)
        
        [locationLabel, temperatureLabel, humidityLabel, conditionLabel].forEach {
            $0.textAlignment = .center
            stackView.addArrangedSubview($0)
        }
        
        // 設置 TableView
        forecastTableView.translatesAutoresizingMaskIntoConstraints = false
        forecastTableView.register(ForecastCell.self, forCellReuseIdentifier: "ForecastCell")
        forecastTableView.delegate = self
        forecastTableView.dataSource = self
        
        // 設置重新整理按鈕
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.setTitle("重新整理", for: .normal)
        refreshButton.backgroundColor = .systemBlue
        refreshButton.setTitleColor(.white, for: .normal)
        refreshButton.layer.cornerRadius = 8
        refreshButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        refreshButton.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
        
        // 添加到視圖層級
        view.addSubview(stackView)
        view.addSubview(forecastTableView)
        view.addSubview(refreshButton)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            forecastTableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            forecastTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            forecastTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            forecastTableView.heightAnchor.constraint(equalToConstant: 200),
            
            refreshButton.topAnchor.constraint(equalTo: forecastTableView.bottomAnchor, constant: 20),
            refreshButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
//    private func setupUI() {
//        view.backgroundColor = .white
//        title = "天氣預報"
//        
//        // Configure UI components
//        [locationLabel, temperatureLabel, humidityLabel, conditionLabel].forEach {
//            $0.textAlignment = .center
//            stackView.addArrangedSubview($0)
//        }
//        
//        refreshButton.setTitle("重新整理", for: .normal)
//        refreshButton.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
//        
//        // Layout
//        view.addSubview(stackView)
//        view.addSubview(refreshButton)
//        
//        NSLayoutConstraint.activate([
//            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            
//            refreshButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
//            refreshButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
//        ])
//    }
    
    private func setupBindings() {
        viewModel.onWeatherUpdated = { [weak self] in
            self?.updateUI()
        }
        
        viewModel.onError = { [weak self] error in
            self?.showError(message: error)
        }
    }
    
    private func updateUI() {
        locationLabel.text = viewModel.locationText
        temperatureLabel.text = viewModel.temperatureText
        humidityLabel.text = viewModel.humidityText
        conditionLabel.text = viewModel.conditionText
        forecastTableView.reloadData()
    }
    
    @objc private func refreshTapped() {
        viewModel.refreshWeather()
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "錯誤", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
}


// WeatherViewController.swift 擴展
extension WeatherViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.forecastItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell", for: indexPath) as! ForecastCell
        let item = viewModel.forecastItems[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
