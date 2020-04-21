//
//  Loader.swift
//  Copyright © 2017-2020 NBC News Digital. All rights reserved.
//

import SwiftUI
import Combine

public enum LoadError: Error {
    case server(code: Int)
    case decoding(DecodingError)
    case network(Error)
    case badResponse(message: String)

    var debugDescription: String {
        switch self {
        case .server(let code):
            return "server returned \(code)"
        case .decoding(let error):
            return error.context.debugDescription
        case .network(let error):
            return error.localizedDescription
        case .badResponse(let message):
            return message
        }
    }

    var code: Int {
        switch self {
        case .server(let code):
            return code
        case .decoding:
            return 1
        case .network(let error):
            return (error as NSError).code
        case .badResponse:
            return 0
        }
    }
}

extension DecodingError {
    var context: DecodingError.Context {
        switch self {
        case .keyNotFound(_, let context):
            return context
        case .dataCorrupted(let context):
            return context
        case .typeMismatch(_, let context):
            return context
        case .valueNotFound(_, let context):
            return context
        @unknown default:
            return DecodingError.Context(codingPath: [], debugDescription: "unknown DecodingError")
        }
    }
}

public struct ArgumentError: Error {
    public init(message: String) {
        self.message = message
    }

    let message: String
}

public struct HttpEntity {
    let etag: String
    let lastModified: String
}

public enum DataResult<T> {
    case success(T)
    case error(LoadError)
}

public enum DataResultWithEntity<T> {
    case success(T, HttpEntity?)
    case success304
    case error(LoadError)
}

public enum ImageResult {
    case success(UIImage, Bool)
    case error(LoadError)
}

private func dataResult<T>(_ callback: @escaping (_ result: DataResult<T>) -> Void) -> (_ result: DataResultWithEntity<T>) -> Void {
    return { result in
        switch result {
        case .success(let r, _):
            callback(.success(r))
        case .success304:
            callback(.error(.server(code: 304)))
        case .error(let error):
            callback(.error(error))
        }
    }
}

public class Loader {
    public typealias ImageDownloadCallback = (_ result: ImageResult) -> Void

    // Unique user id to be sent as custom header with all requests made by loader
    public static var uid: String?

    static let decoder = { () -> JSONDecoder in
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    public class func load<T: Decodable>(
        url: URL,
        background: Bool = false,
        callback: @escaping (_ result: DataResult<T>) -> Void) {

        Loader.load(url: url, callback: dataResult(callback))
    }

    public class func load<T: Decodable>(
        url: URL,
        background: Bool = false,
        entity: HttpEntity? = nil,
        callback: @escaping (_ result: DataResultWithEntity<T>) -> Void) {

        let session = URLSession.shared
        var req = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData)
        req.addValue("application/json", forHTTPHeaderField: "Accept")

        if let entity = entity {
            req.addValue(entity.lastModified, forHTTPHeaderField: "If-Modified-Since")
            req.addValue(entity.etag, forHTTPHeaderField: "If-None-Match")
        }

        if background {
            req.networkServiceType = .background
        }

        if let uid = Loader.uid {
            req.addValue(uid, forHTTPHeaderField:"uid")
        }

        let task = session.dataTask(with: req) { data, response, error in
            handleHttpResponse(data: data, response: response, error: error, callback: callback)
        }

        task.resume()
    }

     class func handleHttpResponse<T:Decodable>(
        data: Data?, response: URLResponse?, error: Error?,
        callback: @escaping (_ result: DataResultWithEntity<T>) -> Void) {

        if let error = error {
            callback(.error(.network(error)))
            return
        }

        guard let response = response as? HTTPURLResponse else {
            callback(.error(.badResponse(message: "response is not HTTPURLResponse")))
            return
        }
        guard response.statusCode != 304 else {
            callback(.success304)
            return
        }
        guard response.statusCode == 200 else {
            callback(.error(.server(code: response.statusCode)))
            return
        }
        guard let data = data else {
            callback(.error(.badResponse(message: "data unavailable")))
            return
        }

        do {
            let object = try decoder.decode(T.self, from: data)
            if let etag = response.allHeaderFields["Etag"] as? String,
                let lmod = response.allHeaderFields["Last-Modified"] as? String {
                callback(.success(object, HttpEntity(etag: etag, lastModified: lmod)))
            }
            else {
                callback(.success(object, nil))
            }
        } catch let error as DecodingError {
            callback(.error(.decoding(error)))
        } catch {
            callback(.error(.badResponse(message: "unexpected exception")))
        }
    }

    public class func downloadImage(from url: URL,
                                    completion:@escaping ImageDownloadCallback) -> URLSessionDataTask? {

        let session = URLSession.shared
        var req = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
        if let cached = session.configuration.urlCache?.cachedResponse(for: req) {
            if let image = UIImage(data: cached.data, scale: UIScreen.main.scale) {
                completion(.success(image, true))
                return nil
            }
        }

        req.cachePolicy = .reloadIgnoringLocalCacheData
        let task = session.dataTask(with: req) { data, response, error in

            if let error = error as NSError? {
                guard error.code != NSURLErrorCancelled else {
                    return
                }

                completion(.error(.network(error)))
                return
            }

            guard let response = response as? HTTPURLResponse else {
                completion(.error(.badResponse(message: "response is not HTTPURLResponse")))
                return
            }

            guard response.statusCode == 200 else {
                completion(.error(.server(code: response.statusCode)))
                return
            }

            guard let data = data else {
                completion(.error(.badResponse(message: "data unavailable")))
                return
            }

            if let image = UIImage(data: data, scale: UIScreen.main.scale) {
                completion(.success(image, false))
            }
            else {
                completion(.error(.badResponse(message: "bad image data")))
            }
        }

        task.resume()
        return task
    }
}

class ImageLoader: ObservableObject {

    @Published var downloadedImage: UIImage?
    var fromCache = false
    var task: URLSessionDataTask?

    func load(url: URL) {

        task = Loader.downloadImage(from: url) { result in
            switch result {
            case .success(let image, let isCached):
                DispatchQueue.main.async {
                    self.fromCache = isCached
                    self.downloadedImage = image
                }
                //print ("loaded \(url.path) from Cache \(isCached)")
            case .error(let error):
                print (error, url)
            }
            self.task = nil
        }
    }
}

