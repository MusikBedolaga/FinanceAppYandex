import UIKit

final class PeriodFilterView: UIView {
    private let startLabel = UILabel()
    private let endLabel = UILabel()
    private let sumLabel = UILabel()
    
    private let startValueLabel = PaddedLabel()
    private let endValueLabel = PaddedLabel()
    private let sumValueLabel = UILabel()
    
    private let line1 = UIView()
    private let line2 = UIView()
    
    
    var onStartDateTap: (() -> Void)?
    var onEndDateTap: (() -> Void)?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupLayout()
    }
    
    
    func setStartPeriod(_ text: String) {
        UIView.transition(with: startValueLabel, duration: 0.22, options: .transitionCrossDissolve, animations: {
            self.startValueLabel.text = text
        })
    }
    
    func setEndPeriod(_ text: String) {
        UIView.transition(with: endValueLabel, duration: 0.22, options: .transitionCrossDissolve, animations: {
            self.endValueLabel.text = text
        })
    }
    
    func setSum(_ text: String) {
        sumValueLabel.text = text
    }
    
    
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 14
        clipsToBounds = true

        [startLabel, endLabel, sumLabel].forEach {
            $0.font = .systemFont(ofSize: 19)
            $0.textColor = .black
        }
        startLabel.text = "Период: начало"
        endLabel.text = "Период: конец"
        sumLabel.text = "Сумма"
        
        [startValueLabel, endValueLabel].forEach {
            $0.font = .systemFont(ofSize: 19)
            $0.textColor = .black
            $0.backgroundColor = UIColor(red: 220/255, green: 255/255, blue: 235/255, alpha: 1)
            $0.layer.cornerRadius = 10
            $0.clipsToBounds = true
            $0.textAlignment = .center
            $0.isUserInteractionEnabled = true
        }
        startValueLabel.text = "Февраль 2025"
        endValueLabel.text = "Март 2025"
        
        sumValueLabel.font = .systemFont(ofSize: 19)
        sumValueLabel.textColor = .black
        sumValueLabel.text = "125 868 ₽"
        
        [line1, line2].forEach {
            $0.backgroundColor = UIColor(white: 0.92, alpha: 1)
        }
        
        // Жесты для бейджей
        let startTap = UITapGestureRecognizer(target: self, action: #selector(handleStartTap))
        startValueLabel.addGestureRecognizer(startTap)
        let endTap = UITapGestureRecognizer(target: self, action: #selector(handleEndTap))
        endValueLabel.addGestureRecognizer(endTap)
    }
    
    private func setupLayout() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false

        let row1 = UIStackView(arrangedSubviews: [startLabel, startValueLabel])
        row1.axis = .horizontal
        row1.spacing = 8
        row1.alignment = .center
        startValueLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        let row2 = UIStackView(arrangedSubviews: [endLabel, endValueLabel])
        row2.axis = .horizontal
        row2.spacing = 8
        row2.alignment = .center
        endValueLabel.setContentHuggingPriority(.required, for: .horizontal)

        let row3 = UIStackView(arrangedSubviews: [sumLabel, sumValueLabel])
        row3.axis = .horizontal
        row3.spacing = 8
        row3.alignment = .center
        sumValueLabel.setContentHuggingPriority(.required, for: .horizontal)

        stack.addArrangedSubview(row1)
        stack.addArrangedSubview(line1)
        stack.addArrangedSubview(row2)
        stack.addArrangedSubview(line2)
        stack.addArrangedSubview(row3)

        line1.heightAnchor.constraint(equalToConstant: 1).isActive = true
        line2.heightAnchor.constraint(equalToConstant: 1).isActive = true

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
    }
    
    @objc private func handleStartTap() {
        animateBounce(label: startValueLabel)
        onStartDateTap?()
    }
    @objc private func handleEndTap() {
        animateBounce(label: endValueLabel)
        onEndDateTap?()
    }

    private func animateBounce(label: UIView) {
        UIView.animate(withDuration: 0.12,
                       animations: {
            label.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            UIView.animate(withDuration: 0.12) {
                label.transform = .identity
            }
        })
    }
}

// MARK: - PaddedLabel (для бейджей)
final class PaddedLabel: UILabel {
    let inset = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: inset))
    }
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + inset.left + inset.right,
                      height: size.height + inset.top + inset.bottom)
    }
}

