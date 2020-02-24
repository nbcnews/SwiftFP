//
//  Data.swift
//  Copyright © 2020 NBC News Digital. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

// swiftlint:disable file_length
typealias TrackingData = [String: [String: String]]
typealias AlternateTeases = [String: URL]

enum TeaseName: String, CaseIterable {
    case aspect1X1 = "ASPECT_1X1"
    case aspect2X1 = "ASPECT_2X1"
}

enum Module: Codable, Identifiable {
    var id: String {
        switch self {
        case .marquee(let marquee):
            return marquee.id
        case .section(let section):
            return section.uid
        case .hero(let hero):
            return hero.item.id
        case .videos(let videos):
            return videos.id
        case .promo(let promo):
            return promo.header ?? "promo"
        case .channels(let channels):
            return channels.id ?? "channels"
        case .web(let web):
            return web.id
        case .unsupported:
            return ""
        }
    }

    enum CodingKeys: String, CodingKey {
        case typename = "type"
    }

    init(from decoder: Decoder) throws {
        do {
            let module = try decoder.container(keyedBy: CodingKeys.self)
            let type = try module.decode(String.self, forKey: .typename)

            switch type {
            case "Marquee":
                self = .marquee(try Marquee(from: decoder))
            case "Hero":
                self = .hero(try HeroModule(from: decoder))
            case "Section":
                self = .section(try SectionModule(from: decoder))
            case "Videos":
                self = .videos(try VideosModule(from: decoder))
            case "Promo":
                self = .promo(try PromoModule(from: decoder))
            case "Channels":
                self = .channels(try ChannelsModule(from: decoder))
            case "Web":
                self = .web(try WebModule(from: decoder))
            default:
                self = .unsupported(type)
            }
        } catch {
            print (error)
            self = .unsupported(error.localizedDescription)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .marquee(let marquee):
            try marquee.encode(to: encoder)
            try container.encode("Marquee", forKey: .typename)
        case .section(let section):
            try section.encode(to: encoder)
            try container.encode("Section", forKey: .typename)
        case .hero(let hero):
            try hero.encode(to: encoder)
            try container.encode("Hero", forKey: .typename)
        case .videos(let videos):
            try videos.encode(to: encoder)
            try container.encode("Videos", forKey: .typename)
        case .promo(let promo):
            try promo.encode(to: encoder)
            try container.encode("Promo", forKey: .typename)
        case .channels(let channels):
            try channels.encode(to: encoder)
            try container.encode("Channels", forKey: .typename)
        case .web(let web):
            try web.encode(to: encoder)
            try container.encode("Web", forKey: .typename)
        case .unsupported(let type):
            try container.encode(type, forKey: .typename)
        }
    }

    case marquee(Marquee)
    case section(SectionModule)
    case hero(HeroModule)
    case videos(VideosModule)
    case promo(PromoModule)
    case channels(ChannelsModule)
    case web(WebModule)
    case unsupported(String)
}

extension Module: Equatable {
    static func == (lhs: Module, rhs: Module) -> Bool {
        switch (lhs, rhs) {
        case (.marquee(let l), .marquee(let r)):
            return l == r
        case (.hero(let l), .hero(let r)):
            return l == r
        case (.section(let l), .section(let r)):
            return l == r
        case (.videos(let l), .videos(let r)):
            return l == r
        case (.promo(let l), .promo(let r)):
            return l == r
        case (.channels(let l), .channels(let r)):
            return l == r
        case (.web(let l), .web(let r)):
            return l == r
        default:
            return false
        }
    }
}

enum ContentItem: Codable {
    enum CodingKeys: String, CodingKey {
        case typename = "type"
    }

    case story(Story)
    case video(Video)
    case slideshow(Slideshow)
    case unsupported(String)

    init(from decoder: Decoder) throws {
        do {
            let item = try decoder.container(keyedBy: CodingKeys.self)
            let type = try item.decode(String.self, forKey: .typename)

            switch type {
            case "article":
                self = .story(try Story(from: decoder))
            case "video":
                self = .video(try Video(from: decoder))
            case "slideshow":
                self = .slideshow(try Slideshow(from: decoder))
            default:
                self = .unsupported("unsupported type: \(type)")
            }
        } catch {
            print (error)
            self = .unsupported(error.localizedDescription)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .story(let story):
            try story.encode(to: encoder)
            try container.encode("article", forKey: .typename)
        case .video(let video):
            try video.encode(to: encoder)
            try container.encode("video", forKey: .typename)
        case .slideshow(let slideshow):
            try slideshow.encode(to: encoder)
            try container.encode("slideshow", forKey: .typename)
        case .unsupported(let type):
            try container.encode(type, forKey: .typename)
        }
    }
}

extension ContentItem: Identifiable {
    var id: String {
        switch self {
        case .story(let story):
            return story.id
        case .video(let video):
            return video.id
        case .slideshow(let slideshow):
            return slideshow.id
        case .unsupported:
            return ""
        }
    }
}

extension ContentItem: Equatable {
    static func == (lhs: ContentItem, rhs: ContentItem) -> Bool {
        switch (lhs, rhs) {
        case (.story(let l), .story(let r)):
            return l == r
        case (.video(let l), .video(let r)):
            return l == r
        case (.slideshow(let l), .slideshow(let r)):
            return l == r
        default:
            return false
        }
    }
}

struct Duration: Codable {
    var isLive: Bool
    var timeInterval: TimeInterval?

    init(from decoder: Decoder) throws {
        do {
            let durationString = try decoder.singleValueContainer().decode(String.self)
            if durationString.lowercased() == "live" {
                self.isLive = true
                self.timeInterval = nil
            } else {
                self.isLive = false
                self.timeInterval = 600
            }
        } catch {
            print(error)
            self.isLive = false
            self.timeInterval = nil
        }
    }

    init() {
        isLive = true
    }
}

extension Duration {
    func formatted() -> String {
        if isLive {
            return "LIVE"
        }

        guard let timeInterval = self.timeInterval else {
            return ""
        }

        let interval = Int(timeInterval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct Video: Codable {
    let id: String
    let headline: String
    let duration: Duration
    let tease: URL?
    let alternateTeases: AlternateTeases?
    let preview: URL?
    let published: Date
    let summary: String?
    let videoUrl: URL
    let label: String?
    let breaking: Bool?
    let url: URL?
    let associatedPlaylist: String?
    let freeWheel: Freewheel?
    let tracking: TrackingData?
}

struct Freewheel: Codable {
    var fileName: String
    var target: [String: String]
}

extension Video: Equatable {
    static func == (lh: Video, rh: Video) -> Bool {
        return lh.id == rh.id &&
               lh.published == rh.published
    }
}

struct Story: Codable {
    var id: String
    var published: Date
    var headline: String
    var tease: URL?
    let alternateTeases: AlternateTeases?
    var summary: String?
    let author: String?
    var url: URL?
    var label: String?
    var breaking: Bool?
    var external: Bool?
    var tracking: TrackingData?
}

extension Story: Equatable {
    static func == (lh: Story, rh: Story) -> Bool {
        return lh.id == rh.id &&
            lh.published == rh.published &&
            lh.headline == rh.headline
    }
}

struct Slideshow: Codable {
    var id: String
    var published: Date
    var headline: String
    var tease: URL?
    let alternateTeases: AlternateTeases?
    var summary: String?
    var images: [ImageInfo]
    var label: String?
    var breaking: Bool?
    var tracking: TrackingData?
}

extension Slideshow: Equatable {
    static func == (lh: Slideshow, rh: Slideshow) -> Bool {
        return lh.id == rh.id &&
            lh.published == rh.published
    }
}

struct ImageInfo: Codable {
    var id: String
    var published: Date
    var url: URL?
    var width: Float?
    var height: Float?
    var headline: String?
    var caption: String?
    var copyright: String?
    var graphicContent: Bool?
}

struct HeroModule: Codable {
    var item: ContentItem
}

extension HeroModule: Equatable {
    static func == (lhs: HeroModule, rhs: HeroModule) -> Bool {
        return lhs.item == rhs.item
    }
}

struct SectionModule: Codable {
    let id: String
    let header: String?
    let subHeader: String?
    let items: [ContentItem]
    let tease: URL?
    let showMore: Bool?

    var uid: String {
        items.map{$0.id}.joined()
    }
}

extension SectionModule: Equatable {
    static func == (lhs: SectionModule, rhs: SectionModule) -> Bool {
        return lhs.id == rhs.id &&
            lhs.header == rhs.header &&
            lhs.items == rhs.items
    }
}

struct VideosModule: Codable {
    var id: String
    var header: String?
    var videos: [Video]
}

extension VideosModule: Equatable {
    static func == (lhs: VideosModule, rhs: VideosModule) -> Bool {
        return lhs.header == rhs.header &&
            lhs.videos == rhs.videos
    }
}

struct PromoModule: Codable {
    var header: String?
    var items: [ContentItem]
}

extension PromoModule: Equatable {
    static func == (lhs: PromoModule, rhs: PromoModule) -> Bool {
        return lhs.header == rhs.header &&
            lhs.items == rhs.items
    }
}

struct Section: Codable {
    var id: String
    var header: String
    var tease: URL
}

extension Section: Equatable {
    static func == (lhs: Section, rhs: Section) -> Bool {
        return lhs.header == rhs.header &&
            lhs.id == rhs.id &&
            lhs.tease == rhs.tease
    }
}

struct WebModule: Codable {
    var id: String
    var url: URL
}

extension WebModule: Equatable {
    static func == (lhs: WebModule, rhs: WebModule) -> Bool {
        return lhs.id == rhs.id &&
        lhs.url == rhs.url
    }
}

struct ChannelsModule: Codable {
    var header: String?
    var id: String?
    var items: [Section]
}

extension ChannelsModule: Equatable {
    static func == (lhs: ChannelsModule, rhs: ChannelsModule) -> Bool {
        return lhs.header == rhs.header &&
            lhs.id == rhs.id &&
            lhs.items == rhs.items
    }
}

struct MarqueeItem: Codable {
    var headline: String
    var video: Video?
    var url: URL?
}

extension MarqueeItem: Equatable {
    static func == (lhs: MarqueeItem, rhs: MarqueeItem) -> Bool {
        return lhs.headline == rhs.headline &&
            lhs.video == rhs.video &&
            lhs.url == rhs.url
    }
}

struct Marquee: Codable {
    var id: String
    var type: String?
    var dateModified: Date?
    var items: [MarqueeItem]
}

extension Marquee: Equatable {
    static func == (lhs: Marquee, rhs: Marquee) -> Bool {
        return lhs.id == rhs.id
    }
}

class HomeLoader {

    struct Model: Decodable {
        private enum CodingKeys: String, CodingKey {
            case tracking
            case modules = "data"
        }

        var modules: [Module] = []
        var tracking: TrackingData?
    }

    private var entity: HttpEntity?
    private var lastUpdate = Date.distantPast

    public let coverURL: URL = URL(string: "https://mobileapi.nbcnews.com/v2/curation/mobile/news/cover")!
    public var path: URL = URL(string: "/")!

    init() {
        path = coverURL
    }

    func load() -> AnyPublisher<Model, Error> {
        let isValidModule = { (module: Module) -> Bool in
            switch module {
            case .unsupported:
                return false
            default:
                return true
            }
        }

        return Future<Model, Error> { callback in
            Loader.load(url: self.path, entity: self.entity) { (result: DataResultWithEntity<Model>) in
                switch result {
                case .success(var data, let entity):
                    data.modules = data.modules.filter(isValidModule)
                    self.lastUpdate = Date()
                    self.entity = entity
                    callback(.success(data))
                case .error(let error):
                    callback(.failure(error))
                case .success304:
                    break
                }
            }
        }.eraseToAnyPublisher()
    }
}
