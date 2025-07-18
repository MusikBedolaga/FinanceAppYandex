import Foundation
import SwiftData

@Model
final class CategoryStorage {
    @Attribute(.unique) var id: Int
    var emoji: String
    var name: String
    @Attribute(originalName: "is_income") var isIncome: Bool

    @Relationship(deleteRule: .nullify, inverse: \TransactionStorage.category)
    var transactions: [TransactionStorage] = []

    @Transient
    var direction: Direction {
        return isIncome ? .income : .outcome
    }

    init(id: Int, emoji: Character, name: String, isIncome: Bool) {
        self.id = id
        self.emoji = String(emoji)
        self.name = name
        self.isIncome = isIncome
    }

    func toDomain() -> Category {
        let emojiCharacter = self.emoji.first ?? "❓"
        return Category(
            id: self.id,
            name: self.name,
            emoji: emojiCharacter,
            isIncome: self.isIncome
        )
    }
}
