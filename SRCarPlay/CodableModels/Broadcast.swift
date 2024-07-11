import Foundation
struct Broadcast : Codable {
	let availablestoputc : String?
	let playlist : Playlist?
	let broadcastfiles : [Broadcastfiles]?

	enum CodingKeys: String, CodingKey {

		case availablestoputc = "availablestoputc"
		case playlist = "playlist"
		case broadcastfiles = "broadcastfiles"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		availablestoputc = try values.decodeIfPresent(String.self, forKey: .availablestoputc)
		playlist = try values.decodeIfPresent(Playlist.self, forKey: .playlist)
		broadcastfiles = try values.decodeIfPresent([Broadcastfiles].self, forKey: .broadcastfiles)
	}

}
