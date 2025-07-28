import Network
import Combine

@MainActor
final class NetworkStatusService: ObservableObject {
    static let shared = NetworkStatusService()

    @Published var isOffline: Bool = false

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOffline = path.status != .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}

