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

//enum Module: Codable, Identifiable {
//    var id: String {
//        switch self {
//        case .marquee(let marquee):
//            return marquee.id
//        case .section(let section):
//            return section.uid
//        case .hero(let hero):
//            return hero.item.id
//        case .videos(let videos):
//            return videos.id
//        case .promo(let promo):
//            return promo.header ?? "promo"
//        case .channels(let channels):
//            return channels.id ?? "channels"
//        case .web(let web):
//            return web.id
//        case .unsupported:
//            return ""
//        }
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case typename = "type"
//    }
//
//    init(from decoder: Decoder) throws {
//        do {
//            let module = try decoder.container(keyedBy: CodingKeys.self)
//            let type = try module.decode(String.self, forKey: .typename)
//
//            switch type {
//            case "Marquee":
//                self = .marquee(try Marquee(from: decoder))
//            case "Hero":
//                self = .hero(try HeroModule(from: decoder))
//            case "Section":
//                self = .section(try SectionModule(from: decoder))
//            case "Videos":
//                self = .videos(try VideosModule(from: decoder))
//            case "Promo":
//                self = .promo(try PromoModule(from: decoder))
//            case "Channels":
//                self = .channels(try ChannelsModule(from: decoder))
//            case "Web":
//                self = .web(try WebModule(from: decoder))
//            default:
//                self = .unsupported(type)
//            }
//        } catch {
//            print (error)
//            self = .unsupported(error.localizedDescription)
//        }
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        switch self {
//        case .marquee(let marquee):
//            try marquee.encode(to: encoder)
//            try container.encode("Marquee", forKey: .typename)
//        case .section(let section):
//            try section.encode(to: encoder)
//            try container.encode("Section", forKey: .typename)
//        case .hero(let hero):
//            try hero.encode(to: encoder)
//            try container.encode("Hero", forKey: .typename)
//        case .videos(let videos):
//            try videos.encode(to: encoder)
//            try container.encode("Videos", forKey: .typename)
//        case .promo(let promo):
//            try promo.encode(to: encoder)
//            try container.encode("Promo", forKey: .typename)
//        case .channels(let channels):
//            try channels.encode(to: encoder)
//            try container.encode("Channels", forKey: .typename)
//        case .web(let web):
//            try web.encode(to: encoder)
//            try container.encode("Web", forKey: .typename)
//        case .unsupported(let type):
//            try container.encode(type, forKey: .typename)
//        }
//    }
//
//    case marquee(Marquee)
//    case section(SectionModule)
//    case hero(HeroModule)
//    case videos(VideosModule)
//    case promo(PromoModule)
//    case channels(ChannelsModule)
//    case web(WebModule)
//    case unsupported(String)
//}


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


struct Freewheel: Codable {
    var fileName: String
    var target: [String: String]
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



class MenuLoader {

    private var entity: HttpEntity?
    private var lastUpdate = Date.distantPast

    public let coverURL: URL = URL(string: "https://ottapi.nbcnews.com/ott/news/cover")!
    public var path: URL = URL(string: "/")!

    init() {
        path = coverURL
    }

    func load() -> AnyPublisher<Channels, Error> {
        return Future<Channels, Error> { callback in
            Loader.load(url: self.path, entity: self.entity) { (result: DataResultWithEntity<Channels>) in
                switch result {
                case .success(let data, let entity):
                    //data.channels = data.channels.flatMap()
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
