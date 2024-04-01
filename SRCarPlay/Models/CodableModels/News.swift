import Foundation
struct News : Codable {
	let episodes : [Episodes]?

	enum CodingKeys: String, CodingKey {

		case episodes = "episodes"
	}
    
    
//
//	init(from decoder: Decoder) throws {
//		let values = try decoder.container(keyedBy: CodingKeys.self)
//		episodes = try values.decodeIfPresent([Episodes].self, forKey: .episodes)
//	}

}
