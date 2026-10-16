
import Foundation

final class HealthMetricService {

    static let shared = HealthMetricService()

    private init() {}

    // MARK: - Fetch Health Metrics

    func fetchMetrics() async throws -> [HealthMetric] {
        try await APIService.shared.request(
            "/api/health/metrics",
            authenticated: true
        )
    }
}
