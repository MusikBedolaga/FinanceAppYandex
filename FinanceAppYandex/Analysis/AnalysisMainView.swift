import UIKit

final class AnalysisMainView: UIView {
    // MARK: - UI
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

    // Публичный контейнер для SwiftUI календаря
    let calendarContainerView = UIView()
    private var calendarHeightConstraint: NSLayoutConstraint!

    private let sortButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Без сортировки ⌄", for: .normal)
        btn.setTitleColor(UIColor(red: 100/255, green: 220/255, blue: 180/255, alpha: 1), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    var onSortChanged: ((SortOptions) -> Void)?
    private var sortOption: SortOptions = .none
    
    let operationTable: UITableView = {
        let table = UITableView()
        table.register(AnalysisCell.self, forCellReuseIdentifier: AnalysisCell.identifier)
        table.backgroundColor = .clear
        table.separatorStyle = .singleLine
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        setupLayout()
        updateSortButton(selected: .none)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Interface
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
    
    // MARK: - Calendar Animations
    func expandCalendar(animated: Bool = true) {
        calendarContainerView.isHidden = false
        calendarHeightConstraint.constant = 350 // высота календаря
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.calendarContainerView.alpha = 1
                self.layoutIfNeeded()
            })
        } else {
            calendarContainerView.alpha = 1
            layoutIfNeeded()
        }
    }

    func collapseCalendar(animated: Bool = true) {
        calendarHeightConstraint.constant = 0
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn], animations: {
                self.calendarContainerView.alpha = 0
                self.layoutIfNeeded()
            }) { _ in
                self.calendarContainerView.isHidden = true
            }
        } else {
            calendarContainerView.alpha = 0
            calendarContainerView.isHidden = true
            layoutIfNeeded()
        }
    }
    
    // MARK: - Private
    private func setupLayout() {
        backgroundColor = .systemGroupedBackground
        
        [titleLabel, filterView, calendarContainerView, operationTable, sortButton].forEach { addSubview($0) }

        // titleLabel
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16)
        ])
        
        // filterView
        filterView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filterView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            filterView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            filterView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18)
        ])
        
        // calendarContainerView (инлайн после filterView)
        calendarContainerView.translatesAutoresizingMaskIntoConstraints = false
        calendarContainerView.isHidden = true
        calendarContainerView.alpha = 0
        calendarHeightConstraint = calendarContainerView.heightAnchor.constraint(equalToConstant: 0)
        calendarHeightConstraint.isActive = true
        NSLayoutConstraint.activate([
            calendarContainerView.leadingAnchor.constraint(equalTo: filterView.leadingAnchor),
            calendarContainerView.trailingAnchor.constraint(equalTo: filterView.trailingAnchor),
            calendarContainerView.topAnchor.constraint(equalTo: filterView.bottomAnchor, constant: 4)
            // Высота — только через calendarHeightConstraint!
        ])
        
        // operationTable
        NSLayoutConstraint.activate([
            operationTable.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            operationTable.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            operationTable.topAnchor.constraint(equalTo: calendarContainerView.bottomAnchor, constant: 12),
            operationTable.bottomAnchor.constraint(equalTo: sortButton.topAnchor, constant: -10)
        ])
        
        // sortButton
        NSLayoutConstraint.activate([
            sortButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            sortButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15)
        ])
    }
    
    private func makeSortMenu(selected: SortOptions) -> UIMenu {
        let actions = SortOptions.allCases.map { option in
            UIAction(
                title: option.rawValue,
                state: option == selected ? .on : .off
            ) { [weak self] _ in
                self?.setSort(option)
            }
        }
        return UIMenu(title: "", options: .displayInline, children: actions)
    }
    
    private func setSort(_ option: SortOptions) {
        sortOption = option
        updateSortButton(selected: option)
        onSortChanged?(option)
    }
    
    private func updateSortButton(selected: SortOptions) {
        sortButton.menu = makeSortMenu(selected: selected)
        sortButton.showsMenuAsPrimaryAction = true
        sortButton.setTitle("\(selected.rawValue) ⌄", for: .normal)
    }
}
