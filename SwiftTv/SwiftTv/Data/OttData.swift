//
//  OttData.swift
//
//  Copyright © 2020 NBC News Digital. All rights reserved.
//

import Combine
import SwiftUI

struct Channels: Decodable, Identifiable {
    let id: String
    let type: String
    let title: String
    let brand: String
    let channels: [MenuCollectionEntry]
}

struct Cards: Codable, Identifiable {
    let id: String
    let title: String
    let cards: [Card]
}

struct Card: Codable, Identifiable {
    let id: String
    let title: String
    let image: URL
    let tagline: String = ""
}

struct Playlist: Codable, Identifiable {
    let id: String
    let title: String
    let isLive: Bool
    let image: URL
    let description: String?
    let duration: String
    let videos: [xVideo]
}

struct xVideo: Codable, Identifiable {
    let id: String
    let guid: String
    let advertiserID: String
    let brand: String
    let videoType: String
    let url: URL? = nil
    let headline: String
    let published: Date
    let duration: Duration
    let tease: URL?
    let summary: String?
    let preview: URL?
    let videoUrl: URL
    let tracking: TrackingData?
}


enum MenuCollectionEntry: Decodable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case typename = "type"
    }

    case playlist(Playlist)
    case videos(Playlist)
    case playmakerLive(Playlist)
    case playlists(Cards)
    case pages(Cards)

    init(from decoder: Decoder) throws {
        let item = try decoder.container(keyedBy: CodingKeys.self)
        let type = try item.decode(String.self, forKey: .typename)

        switch type {
        case "playlist":
            self = .playlist(try Playlist(from: decoder))
        case "playmakerLive":
            self = .playmakerLive(try Playlist(from: decoder))
        case "videos":
            self = .videos(try Playlist(from: decoder))
        case "playlists":
            self = .playlists(try Cards(from: decoder))
        case "pages":
            self = .pages(try Cards(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .typename, in: item,
                debugDescription: "Invalid type value: " + type)
        }
    }

    var id: String {
        switch self {
        case .playlist(let playlist):
            return playlist.id
        case .videos(let playlist):
            return playlist.id
        case .playmakerLive(let playlist):
            return playlist.id
        case .playlists(let cards):
            return cards.id
        case .pages(let cards):
            return cards.id
        }
    }
}
