import Foundation
struct Episodes : Codable, Identifiable, Hashable {
    
    // Conformance to Equatable
    static func == (lhs: Episodes, rhs: Episodes) -> Bool {
        lhs.id ?? 0 == rhs.id ?? 1
    }
    // Conformance to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

	let id : Int?
	let title : String?
	let description : String?
	let url : String?
	let program : Program?
	let audiopreference : String?
	let audiopriority : String?
	let audiopresentation : String?
	let publishdateutc : String?
	let imageurl : String?
	let imageurltemplate : String?
	let photographer : String?
	let broadcast : Broadcast?
	let broadcasttime : Broadcasttime?
	let downloadpodfile : Downloadpodfile?
	let relatedepisodes : [String]?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case title = "title"
		case description = "description"
		case url = "url"
		case program = "program"
		case audiopreference = "audiopreference"
		case audiopriority = "audiopriority"
		case audiopresentation = "audiopresentation"
		case publishdateutc = "publishdateutc"
		case imageurl = "imageurl"
		case imageurltemplate = "imageurltemplate"
		case photographer = "photographer"
		case broadcast = "broadcast"
		case broadcasttime = "broadcasttime"
		case downloadpodfile = "downloadpodfile"
		case relatedepisodes = "relatedepisodes"
	}

    init() {
        id = 0
        title = nil
        description = nil
        url = nil
        program = nil
        audiopreference = nil
        audiopriority = nil
        audiopresentation = nil
        publishdateutc = nil
        imageurl = nil
        imageurltemplate = nil
        photographer = nil
        broadcast = nil
        broadcasttime = nil
        downloadpodfile = nil
        relatedepisodes = nil
    }
    
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		title = try values.decodeIfPresent(String.self, forKey: .title)
		description = try values.decodeIfPresent(String.self, forKey: .description)
		url = try values.decodeIfPresent(String.self, forKey: .url)
		program = try values.decodeIfPresent(Program.self, forKey: .program)
		audiopreference = try values.decodeIfPresent(String.self, forKey: .audiopreference)
		audiopriority = try values.decodeIfPresent(String.self, forKey: .audiopriority)
		audiopresentation = try values.decodeIfPresent(String.self, forKey: .audiopresentation)
		publishdateutc = try values.decodeIfPresent(String.self, forKey: .publishdateutc)
		imageurl = try values.decodeIfPresent(String.self, forKey: .imageurl)
		imageurltemplate = try values.decodeIfPresent(String.self, forKey: .imageurltemplate)
		photographer = try values.decodeIfPresent(String.self, forKey: .photographer)
		broadcast = try values.decodeIfPresent(Broadcast.self, forKey: .broadcast)
		broadcasttime = try values.decodeIfPresent(Broadcasttime.self, forKey: .broadcasttime)
		downloadpodfile = try values.decodeIfPresent(Downloadpodfile.self, forKey: .downloadpodfile)
		relatedepisodes = try values.decodeIfPresent([String].self, forKey: .relatedepisodes)
	}
    
    // Custom initializer for mock data
    init(mockID: Int) {
        id = mockID
        title = "Title"
        description = "Description"
        url = nil
        program = nil
        audiopreference = nil
        audiopriority = nil
        audiopresentation = nil
        publishdateutc = nil
        imageurl = nil
        imageurltemplate = nil
        photographer = nil
        broadcast = nil
        broadcasttime = nil
        downloadpodfile = nil
        relatedepisodes = nil
    }

}
