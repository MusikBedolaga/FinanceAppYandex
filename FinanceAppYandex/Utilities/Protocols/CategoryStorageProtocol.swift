import Foundation

protocol CategoryStorageProtocol {
    func saveCategories(_ categories: [Category]) async throws -> [Category]
    func fetchAllCategories() async throws -> [Category]
    func clearAllCategories() async throws
}
