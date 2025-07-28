
import Foundation
import UIKit

public struct Entity {
    public let value: Decimal
    public let label: String

    public init(value: Decimal, label: String) {
        self.value = value
        self.label = label
    }
}

public final class PieChartView: UIView {
    // MARK: - Properties
    public var entities: [Entity] = [] {
        didSet { setNeedsDisplay() }
    }
    
    private var isAnimating = false
    
    public let segmentColors: [UIColor] = [
        UIColor(red: 0.20, green: 0.60, blue: 0.86, alpha: 1.00), // Blue
        UIColor(red: 0.96, green: 0.49, blue: 0.00, alpha: 1.00), // Orange
        UIColor(red: 0.58, green: 0.80, blue: 0.16, alpha: 1.00), // Green
        UIColor(red: 0.91, green: 0.12, blue: 0.39, alpha: 1.00), // Pink
        UIColor(red: 0.50, green: 0.22, blue: 0.60, alpha: 1.00), // Purple
        UIColor(red: 0.80, green: 0.80, blue: 0.80, alpha: 1.00)  // Gray
    ]
    
    public let legendFont = UIFont.systemFont(ofSize: 12, weight: .medium)
    public let legendDotSize: CGFloat = 8
    public let legendSpacing: CGFloat = 12
    public let chartInset: CGFloat = 20
    
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        guard !entities.isEmpty else { return }
        
        let (segments, total) = prepareSegments()
        
        drawPieChart(segments: segments, total: total, in: rect, context: context)
        
        drawLegend(segments: segments, in: rect, context: context)
    }
    
    public func prepareSegments() -> (segments: [(value: Decimal, label: String)], total: Decimal) {
        let firstFive = Array(entities.prefix(5))
        let others = entities.dropFirst(5)
        
        var segments: [(value: Decimal, label: String)] = firstFive.map { ($0.value, $0.label) }
        
        if !others.isEmpty {
            let othersSum = others.reduce(0) { $0 + $1.value }
            segments.append((othersSum, "Остальные"))
        }
        
        let total = segments.reduce(0) { $0 + $1.value }
        
        guard total > 0 else {
            return (segments.map { ($0.value == 0 ? Decimal(1) : $0.value, $0.label) }, Decimal(segments.count))
        }
        
        return (segments, total)
    }
    
    public func drawPieChart(segments: [(value: Decimal, label: String)],
                             total: Decimal,
                             in rect: CGRect,
                             context: CGContext) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 - chartInset
        let lineWidth: CGFloat = 12

        var startAngle: CGFloat = -.pi / 2

        for (index, segment) in segments.enumerated() {
            let segmentFraction = CGFloat(NSDecimalNumber(decimal: segment.value / total).floatValue)
            let endAngle = startAngle + .pi * 2 * segmentFraction

            let path = UIBezierPath(
                arcCenter: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: true
            )
            path.lineWidth = lineWidth
            path.lineCapStyle = .butt

            let color = segmentColors[safe: index] ?? segmentColors.last!
            color.setStroke()
            path.stroke()

            startAngle = endAngle
        }
    }

    public func drawLegend(segments: [(value: Decimal, label: String)],
                           in rect: CGRect,
                           context: CGContext) {
        let total = segments.reduce(0) { $0 + $1.value }
        guard total > 0 else { return }

        let center = CGPoint(x: rect.midX, y: rect.midY)
        let totalHeight = CGFloat(segments.count) * legendSpacing
        let startY = center.y - totalHeight / 2

        let attributes: [NSAttributedString.Key: Any] = [
            .font: legendFont,
            .foregroundColor: UIColor.label
        ]

        for (index, segment) in segments.enumerated() {
            let yPosition = startY + CGFloat(index) * legendSpacing
            let color = segmentColors[safe: index] ?? segmentColors.last!

            let dotRect = CGRect(
                x: center.x - 40,
                y: yPosition - legendDotSize / 2,
                width: legendDotSize,
                height: legendDotSize
            )
            color.setFill()
            UIBezierPath(ovalIn: dotRect).fill()

            let labelX = dotRect.maxX + 4
            let percentage = (segment.value / total) * 100
            let roundedPercentage = (percentage as NSDecimalNumber).doubleValue.rounded(toPlaces: 1)
            let text = "\(segment.label) \(String(format: "%.1f%%", roundedPercentage))"

            let maxWidth = rect.width / 2 - chartInset
            let truncated = text.truncated(to: maxWidth, font: legendFont)
            let attributed = NSAttributedString(string: truncated, attributes: attributes)
            attributed.draw(at: CGPoint(
                x: labelX,
                y: yPosition - legendFont.lineHeight / 2
            ))
        }
    }
    
    public func animateChartChange(to newEntities: [Entity]) {
        guard !isAnimating else { return }
        isAnimating = true

        UIView.animate(withDuration: 0.5, animations: {
            self.transform = CGAffineTransform(rotationAngle: .pi)
            self.alpha = 0.0
        }, completion: { _ in
            self.entities = newEntities
            self.transform = CGAffineTransform(rotationAngle: .pi)
            self.alpha = 0.0

            UIView.animate(withDuration: 0.5, animations: {
                self.transform = CGAffineTransform(rotationAngle: .pi * 2)
                self.alpha = 1.0
            }, completion: { _ in
                self.transform = .identity
                self.isAnimating = false
            })
        })
    }
}

// MARK: - Extensions
private extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

private extension String {
    func truncated(to width: CGFloat, font: UIFont) -> String {
        let attributes = [NSAttributedString.Key.font: font]
        var truncated = self
        
        while truncated.size(withAttributes: attributes).width > width && truncated.count > 0 {
            truncated.removeLast()
        }
        
        if truncated.count < self.count {
            truncated.append("...")
        }
        
        return truncated
    }
}

private extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
