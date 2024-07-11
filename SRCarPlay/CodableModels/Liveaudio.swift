import Foundation
struct Liveaudio : Codable {
	let id : Int?
	let url : String?
	let statkey : String?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case url = "url"
		case statkey = "statkey"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		url = try values.decodeIfPresent(String.self, forKey: .url)
		statkey = try values.decodeIfPresent(String.self, forKey: .statkey)
	}

}
