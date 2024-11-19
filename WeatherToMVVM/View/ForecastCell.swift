//
//  ForecastCell.swift
//  WeatherToMVVM
//
//  Created by Lydia Lu on 2024/11/19.
//

import UIKit

class ForecastCell: UITableViewCell {
    private let dateLabel = UILabel()
    private let tempLabel = UILabel()
    private let conditionLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
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
