import Foundation
struct Downloadpodfile : Codable {
	let title : String?
	let description : String?
	let filesizeinbytes : Int?
	let program : Program?
	let duration : Int?
	let publishdateutc : String?
	let id : Int?
	let url : String?
	let statkey : String?

	enum CodingKeys: String, CodingKey {

		case title = "title"
		case description = "description"
		case filesizeinbytes = "filesizeinbytes"
		case program = "program"
		case duration = "duration"
		case publishdateutc = "publishdateutc"
		case id = "id"
		case url = "url"
		case statkey = "statkey"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		title = try values.decodeIfPresent(String.self, forKey: .title)
		description = try values.decodeIfPresent(String.self, forKey: .description)
		filesizeinbytes = try values.decodeIfPresent(Int.self, forKey: .filesizeinbytes)
		program = try values.decodeIfPresent(Program.self, forKey: .program)
		duration = try values.decodeIfPresent(Int.self, forKey: .duration)
		publishdateutc = try values.decodeIfPresent(String.self, forKey: .publishdateutc)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		url = try values.decodeIfPresent(String.self, forKey: .url)
		statkey = try values.decodeIfPresent(String.self, forKey: .statkey)
	}

}
