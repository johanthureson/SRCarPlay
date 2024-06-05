import Foundation

struct ChannelsResponse: Codable {
    let channels: [Channel]
}

struct Channel: Codable, Identifiable {
    let image : String?
    let imagetemplate : String?
    let color : String?
    let tagline : String?
    let siteurl : String?
    let liveaudio : Liveaudio?
    let scheduleurl : String?
    let channeltype : String?
    let xmltvid : String?
    let id : Int?
    let name : String?

    enum CodingKeys: String, CodingKey {

        case image = "image"
        case imagetemplate = "imagetemplate"
        case color = "color"
        case tagline = "tagline"
        case siteurl = "siteurl"
        case liveaudio = "liveaudio"
        case scheduleurl = "scheduleurl"
        case channeltype = "channeltype"
        case xmltvid = "xmltvid"
        case id = "id"
        case name = "name"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        image = try values.decodeIfPresent(String.self, forKey: .image)
        imagetemplate = try values.decodeIfPresent(String.self, forKey: .imagetemplate)
        color = try values.decodeIfPresent(String.self, forKey: .color)
        tagline = try values.decodeIfPresent(String.self, forKey: .tagline)
        siteurl = try values.decodeIfPresent(String.self, forKey: .siteurl)
        liveaudio = try values.decodeIfPresent(Liveaudio.self, forKey: .liveaudio)
        scheduleurl = try values.decodeIfPresent(String.self, forKey: .scheduleurl)
        channeltype = try values.decodeIfPresent(String.self, forKey: .channeltype)
        xmltvid = try values.decodeIfPresent(String.self, forKey: .xmltvid)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
    }

}

