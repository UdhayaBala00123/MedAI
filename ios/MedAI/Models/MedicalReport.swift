
import Foundation

struct MedicalReport: Decodable, Identifiable, Sendable {
    let id: Int
    let user_id: Int
    let title: String
    let report_type: String
    let file_url: String
    let report_date: String?
    let uploaded_at: String?
    let status: String

    enum CodingKeys: String, CodingKey {
        case id
        case user_id
        case title
        case report_type
        case file_url
        case report_date
        case uploaded_at
        case status
    }

    nonisolated init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        user_id = try container.decode(Int.self, forKey: .user_id)
        title = try container.decode(String.self, forKey: .title)
        report_type = try container.decode(String.self, forKey: .report_type)
        file_url = try container.decode(String.self, forKey: .file_url)
        report_date = try container.decodeIfPresent(String.self, forKey: .report_date)
        uploaded_at = try container.decodeIfPresent(String.self, forKey: .uploaded_at)
        status = try container.decode(String.self, forKey: .status)
    }
}
