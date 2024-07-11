import Foundation
struct Broadcasttime : Codable {
	let starttimeutc : String?
	let endtimeutc : String?

	enum CodingKeys: String, CodingKey {

		case starttimeutc = "starttimeutc"
		case endtimeutc = "endtimeutc"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		starttimeutc = try values.decodeIfPresent(String.self, forKey: .starttimeutc)
		endtimeutc = try values.decodeIfPresent(String.self, forKey: .endtimeutc)
	}

}
