import Foundation
import SwiftData

protocol SwiftDataRepositoryProtocol<T> {
    associatedtype T: PersistentModel
    func fetchAll() throws -> [T]
    func fetch(by id: UUID) throws -> T?
    func delete(by id: UUID) throws
    func save() throws
}
