import Foundation
import UIKit


//TODO: Сделать кастомный DataPicker
final class AnalysisVC: UIViewController {
    private let analysisMainView = AnalysisMainView()
    private var startDate = Date()
    private var endDate = Date()
    private let direction: Direction
    private lazy var vm = AnalysisViewModel(direction: direction)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    
    init(direction: Direction) {
        self.direction = direction
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupView() {
        view = analysisMainView

        analysisMainView.onStartDateTap = { [weak self] in
            self?.showDatePicker(
                title: "Выберите начало периода",
                date: self?.startDate ?? Date()
            ) { [weak self] date in
                self?.startDate = date
                self?.analysisMainView.setStartPeriod(self?.format(date: date) ?? "")
            }
        }
        analysisMainView.onEndDateTap = { [weak self] in
            self?.showDatePicker(
                title: "Выберите конец периода",
                date: self?.endDate ?? Date()
            ) { [weak self] date in
                self?.endDate = date
                self?.analysisMainView.setEndPeriod(self?.format(date: date) ?? "")
            }
        }
        
        analysisMainView.setupOperationTable(dataSource: self, delegate: self)
        
        vm.onTransactionsUpdated = { [weak self] in
            guard let self else { return }
            self.analysisMainView.operationTable.reloadData()
            let amount = self.vm.totalAmountForDate
            self.analysisMainView.setAmount("\(amount)")
        }
    }

    private func showDatePicker(title: String, date: Date, completion: @escaping (Date) -> Void) {
        let alert = UIAlertController(title: title, message: "\n\n\n\n\n\n", preferredStyle: .actionSheet)
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.date = date
        picker.locale = Locale(identifier: "ru_RU")
        picker.preferredDatePickerStyle = .wheels
        picker.frame = CGRect(x: 0, y: 20, width: alert.view.bounds.width-20, height: 160)
        alert.view.addSubview(picker)
        alert.addAction(UIAlertAction(title: "Готово", style: .default, handler: { _ in
            completion(picker.date)
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }

    private func format(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date).capitalized
    }
}


//MARK: = UITableViewDataSource
extension AnalysisVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(vm.transactions.count)
        return vm.transactions.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AnalysisCell.identifier, for: indexPath) as! AnalysisCell
        cell.configure(with: vm.transactions[indexPath.row])
        return cell
    }
}


//MARK: - UITableViewDelegate
extension AnalysisVC: UITableViewDelegate { }
