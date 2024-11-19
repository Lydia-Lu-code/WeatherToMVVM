//
//  ForecastCell.swift
//  WeatherToMVVM
//
//  Created by Lydia Lu on 2024/11/19.
//

import UIKit

// ForecastCell.swift
class ForecastCell: UITableViewCell {
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let tempLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let conditionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        backgroundColor = .secondarySystemGroupedBackground // 系統群組背景色
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        [dateLabel, tempLabel, conditionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            tempLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            tempLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            conditionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            conditionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with item: ForecastDisplayItem) {
        dateLabel.text = item.date
        tempLabel.text = "\(item.highTemp) / \(item.lowTemp)"
        conditionLabel.text = item.condition
    }
}
