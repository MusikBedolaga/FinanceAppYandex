//
//  AnalysisMainView.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 05.07.2025.
//

import UIKit

final class AnalysisMainView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализ"
        label.font = .boldSystemFont(ofSize: 34)
        label.textColor = .black
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let filterView = PeriodFilterView()
    var onStartDateTap: (() -> Void)? {
        didSet { filterView.onStartDateTap = onStartDateTap }
    }
    var onEndDateTap: (() -> Void)? {
        didSet { filterView.onEndDateTap = onEndDateTap }
    }
    
    let operationTable: UITableView = {
        let table = UITableView()
        table.register(AnalysisCell.self, forCellReuseIdentifier: AnalysisCell.identifier)
        table.backgroundColor = .clear
        table.separatorStyle = .singleLine
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    
    init() {
        super.init(frame: .zero)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setStartPeriod(_ text: String) {
        filterView.setStartPeriod(text)
    }

    func setEndPeriod(_ text: String) {
        filterView.setEndPeriod(text)
    }
    
    func setAmount(_ text: String) {
        filterView.setSum(text)
    }
    
    func setupOperationTable(
        dataSource: UITableViewDataSource,
        delegate: UITableViewDelegate
    ) {
        operationTable.dataSource = dataSource
        operationTable.delegate = delegate
    }
    
    
    private func setupLayout() {
        backgroundColor = .systemGroupedBackground
        
        [titleLabel, filterView, operationTable].forEach({ addSubview($0) })
        
        //MARK: titleLabel
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor,constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16)
        ])
        
        //MARK: filterView
        filterView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filterView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            filterView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            filterView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18)
        ])
        
        //MARK: operationTable
        NSLayoutConstraint.activate([
            operationTable.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            operationTable.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            operationTable.topAnchor.constraint(equalTo: filterView.bottomAnchor, constant: 50),
            operationTable.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
}
