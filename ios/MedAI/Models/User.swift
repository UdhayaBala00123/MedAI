
import Foundation

struct User: Decodable {
    let id: Int
    let email: String
    let full_name: String?
}
