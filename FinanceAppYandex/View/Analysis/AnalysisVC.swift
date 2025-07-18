import Foundation
import UIKit
import SwiftUI
import SwiftData

final class AnalysisVC: UIViewController {
    private let analysisMainView = AnalysisMainView()
    private let direction: Direction
    private let modelContainer: ModelContainer
    private lazy var vm = AnalysisViewModel(direction: direction, modelContainer: modelContainer)
    private var calendarHostingController: UIHostingController<CalendarDatePicker>?
    private var spinner: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupVMCallbacks()
        vm.fetchTransactions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDateFields()
    }

    init(direction: Direction, modelContainer: ModelContainer) {
        self.direction = direction
        self.modelContainer = modelContainer
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        view = analysisMainView

        analysisMainView.onStartDateTap = { [weak self] in
            guard let self = self else { return }
            if self.calendarHostingController == nil {
                self.showInlineCalendar(date: self.vm.startDate) { [weak self] date in
                    self?.vm.setStartTime(date)
                }
            } else {
                self.hideInlineCalendar()
            }
        }

        analysisMainView.onEndDateTap = { [weak self] in
            guard let self = self else { return }
            if self.calendarHostingController == nil {
                self.showInlineCalendar(date: self.vm.endDate) { [weak self] date in
                    self?.vm.setFinishTime(date)
                }
            } else {
                self.hideInlineCalendar()
            }
        }

        analysisMainView.setupOperationTable(dataSource: self, delegate: self)

        analysisMainView.onSortChanged = { [weak self] sortOption in
            guard let self else { return }
            self.vm.updateSortOption(to: sortOption)
            self.analysisMainView.operationTable.reloadData()
        }
    }

    private func setupVMCallbacks() {
        vm.onTransactionsUpdated = { [weak self] in
            guard let self else { return }
            self.analysisMainView.operationTable.reloadData()
            let amount = self.vm.totalAmountForDate
            self.analysisMainView.setAmount("\(amount)")
        }

        vm.onLoadingChanged = { [weak self] isLoading in
            guard let self else { return }
            if isLoading {
                self.showSpinner()
            } else {
                self.hideSpinner()
            }
        }

        vm.onError = { [weak self] message in
            guard let self else { return }
            self.hideSpinner()
            let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

    private func showInlineCalendar(date: Date, setDate: @escaping (Date) -> Void) {
        guard calendarHostingController == nil else { return }
        analysisMainView.expandCalendar(animated: true)
        var selectedDate = date

        let calendarView = CalendarDatePicker(
            selectedDate: Binding(
                get: { selectedDate },
                set: { [weak self] newValue in
                    guard let self = self else { return }
                    selectedDate = newValue
                    setDate(newValue)
                    self.updateDateFields()
                    self.hideInlineCalendar()
                }
            ),
            onDone: nil
        )

        let hostingController = UIHostingController(rootView: calendarView)
        hostingController.view.backgroundColor = .clear
        calendarHostingController = hostingController

        addChild(hostingController)
        analysisMainView.calendarContainerView.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: analysisMainView.calendarContainerView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: analysisMainView.calendarContainerView.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: analysisMainView.calendarContainerView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: analysisMainView.calendarContainerView.trailingAnchor)
        ])
        hostingController.didMove(toParent: self)
    }

    private func hideInlineCalendar() {
        if let hostingController = calendarHostingController {
            hostingController.willMove(toParent: nil)
            hostingController.view.removeFromSuperview()
            hostingController.removeFromParent()
            calendarHostingController = nil
        }
        analysisMainView.collapseCalendar(animated: true)
    }

    private func showSpinner() {
        if spinner == nil {
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.color = .purple
            spinner.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(spinner)
            NSLayoutConstraint.activate([
                spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
            self.spinner = spinner
        }
        spinner?.startAnimating()
        view.isUserInteractionEnabled = false
    }

    private func hideSpinner() {
        spinner?.stopAnimating()
        spinner?.removeFromSuperview()
        spinner = nil
        view.isUserInteractionEnabled = true
    }

    private func format(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date).capitalized
    }

    private func updateDateFields() {
        analysisMainView.setStartPeriod(format(date: vm.startDate))
        analysisMainView.setEndPeriod(format(date: vm.endDate))
    }
}

// MARK: - UITableViewDataSource
extension AnalysisVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AnalysisCell.identifier, for: indexPath) as! AnalysisCell
        cell.configure(with: vm.transactions[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension AnalysisVC: UITableViewDelegate { }
