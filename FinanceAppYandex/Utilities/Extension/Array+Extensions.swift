import Foundation

extension Array where Element == Transaction {
    func uniqueById() -> [Transaction] {
        var seen = Set<Int>()
        return self.filter { seen.insert($0.id).inserted }
    }
}
