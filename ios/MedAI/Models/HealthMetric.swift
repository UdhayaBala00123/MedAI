import Foundation

struct HealthMetric: Decodable, Identifiable {
    let id: Int
    let user_id: Int?
    let metric_type: String
    let value: Double
    let unit: String
    let recorded_at: String?
    let source: String?
}
