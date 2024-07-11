import Foundation
struct Broadcastfiles : Codable {
	let duration : Int?
	let publishdateutc : String?
	let id : Int?
	let url : String?
	let statkey : String?

	enum CodingKeys: String, CodingKey {

		case duration = "duration"
		case publishdateutc = "publishdateutc"
		case id = "id"
		case url = "url"
		case statkey = "statkey"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		duration = try values.decodeIfPresent(Int.self, forKey: .duration)
		publishdateutc = try values.decodeIfPresent(String.self, forKey: .publishdateutc)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		url = try values.decodeIfPresent(String.self, forKey: .url)
		statkey = try values.decodeIfPresent(String.self, forKey: .statkey)
	}

}
