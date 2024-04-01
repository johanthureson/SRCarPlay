import Foundation
struct News : Codable {
	let episodes : [Episodes]?

	enum CodingKeys: String, CodingKey {

		case episodes = "episodes"
	}

}
