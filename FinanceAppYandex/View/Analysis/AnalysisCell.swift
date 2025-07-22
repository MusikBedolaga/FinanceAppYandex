import UIKit

final class AnalysisCell: UITableViewCell {
    static let identifier = "AnalysisCell"
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        label.textAlignment = .center
        label.backgroundColor = UIColor(red: 220/255, green: 255/255, blue: 235/255, alpha: 1)
        label.layer.cornerRadius = 20
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 19, weight: .semibold)
        l.textColor = .black
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15)
        l.textColor = .gray
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let percentLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17)
        l.textColor = .black
        l.textAlignment = .right
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let amountLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .semibold)
        l.textColor = .black
        l.textAlignment = .right
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let arrowImage: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(systemName: "chevron.right")
        v.tintColor = UIColor(white: 0.8, alpha: 1)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let separator: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.92, alpha: 1)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let bg = UIView()
        bg.backgroundColor = .white
        bg.layer.cornerRadius = 14
        bg.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bg)
        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            bg.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            bg.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            bg.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0)
        ])
        
        bg.addSubview(emojiLabel)
        NSLayoutConstraint.activate([
            emojiLabel.widthAnchor.constraint(equalToConstant: 40),
            emojiLabel.heightAnchor.constraint(equalToConstant: 40),
            emojiLabel.leadingAnchor.constraint(equalTo: bg.leadingAnchor, constant: 12),
            emojiLabel.centerYAnchor.constraint(equalTo: bg.centerYAnchor)
        ])
        
        let labelStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 2
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        bg.addSubview(labelStack)
        NSLayoutConstraint.activate([
            labelStack.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 12),
            labelStack.centerYAnchor.constraint(equalTo: emojiLabel.centerYAnchor),
            labelStack.trailingAnchor.constraint(lessThanOrEqualTo: bg.trailingAnchor, constant: -100)
        ])
        
        bg.addSubview(percentLabel)
        bg.addSubview(arrowImage)
        NSLayoutConstraint.activate([
            arrowImage.widthAnchor.constraint(equalToConstant: 16),
            arrowImage.heightAnchor.constraint(equalToConstant: 16),
            arrowImage.trailingAnchor.constraint(equalTo: bg.trailingAnchor, constant: -16),
            arrowImage.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            percentLabel.trailingAnchor.constraint(equalTo: arrowImage.leadingAnchor, constant: -5),
            percentLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])
        
        bg.addSubview(amountLabel)
        NSLayoutConstraint.activate([
            amountLabel.trailingAnchor.constraint(equalTo: arrowImage.trailingAnchor),
            amountLabel.topAnchor.constraint(equalTo: percentLabel.bottomAnchor, constant: 5),
            amountLabel.bottomAnchor.constraint(lessThanOrEqualTo: bg.bottomAnchor, constant: -10)
        ])
        
        bg.addSubview(separator)
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: labelStack.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: bg.trailingAnchor, constant: -12),
            separator.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 8),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func configure(with tx: Transaction, totalAmount: Decimal) {
        emojiLabel.text = String(tx.category.emoji)
        titleLabel.text = tx.category.name
        subtitleLabel.text = tx.comment ?? "Нету"
        
        let percent: String
        if totalAmount > 0 {
            let fraction = (tx.amount / totalAmount as NSDecimalNumber).doubleValue
            let percentValue = Int(fraction * 100)
            percent = "\(percentValue)%"
        } else {
            percent = "-"
        }
        percentLabel.text = percent
        
        amountLabel.text = "\(NSDecimalNumber(decimal: tx.amount).intValue) ₽"
    }
    
    func setSeparatorHidden(_ hidden: Bool) {
        separator.isHidden = hidden
    }
}
