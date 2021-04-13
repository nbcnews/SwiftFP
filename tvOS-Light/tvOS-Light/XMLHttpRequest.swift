//
//  XMLHttpRequest.swift
//  tvOS-Light
//
//  Created by Denis on 3/24/21.
//

import Foundation
import JavaScriptCore

@objc protocol XMLHttpRequestExports: JSExport {
    func open(_ method: String, _ url: String, _ async: NSNumber?, _ user: String?, _ password: String?)
    func send(_ body: NSObject)
    func setRequestHeader(_ header: String, _ value: String)
    func getAllResponseHeaders() -> String?
    func getResponseHeader(_ name: String) -> String?

    var onreadystatechange: JSValue? {get set}
    var readyState: NSNumber { get }
    var status: NSNumber { get }
    var responseText: String? {get}
    var statusText: String? {get}
    var responseType: String {get set}
    var response: NSObject? {get}

    subscript(_ key: String) -> NSObject? { get}
    var onabort: JSValue? {get set}
    var onerror: JSValue? {get set}
    var onload: JSValue? {get set}
    var onloadstart: JSValue? {get set}
    var onloadend: JSValue? {get set}
    var onprogress: JSValue? {get set}

    init()
}

@objc public class XMLHttpRequest : EventTarget, XMLHttpRequestExports {
    subscript(key: String) -> NSObject? {
        return nil
    }
    enum State: NSNumber {
        case UNSENT             = 0
        case OPENED             = 1
        case HEADERS_RECEIVED   = 2
        case LOADING            = 3
        case DONE               = 4
    }

    dynamic var responseText: String?
    dynamic var statusText: String?
    dynamic var onreadystatechange: JSValue?
    dynamic var readyState: NSNumber = 0
    dynamic var status: NSNumber = 0
    dynamic var responseType: String = ""
    dynamic var response: NSObject?

    dynamic var onabort: JSValue?
    dynamic var onerror: JSValue?
    dynamic var onload: JSValue?
    dynamic var onloadstart: JSValue?
    dynamic var onloadend: JSValue?
    dynamic var onprogress: JSValue?

    private var method: String = "Get"
    private var url: String = ""
    private var headers = [(String, String)]()
    private var urlResponce: HTTPURLResponse?

    required public override init() {
       // print("XH init")
    }
    func open(_ method: String, _ url: String, _ async: NSNumber? = nil, _ user: String? = nil, _ password: String? = nil) {
        print (method, url)
        self.method = method
        self.url = url
        readyState = State.OPENED.rawValue
        onreadystatechange?.call(withArguments: [])
    }

    func setRequestHeader(_ header: String, _ value: String) {
        print(header)
        headers.append((header, value))
    }
    func getResponseHeader(_ name: String) -> String? {
        guard let response = urlResponce else { return nil }
        return response.value(forHTTPHeaderField: name)
    }
    func getAllResponseHeaders() -> String? {
        guard let response = urlResponce else { return nil }
        let headers = response.allHeaderFields.map { v in
            "\(v.key): \(v.value)\n\r"
        }.joined()
        return headers
    }

    func send(_ body: NSObject) {
        if url.starts(with: "./") {
            let parts = url.split(whereSeparator: {$0 == "/" || $0 == "."}).suffix(2)
            let path = Bundle.main.path(forResource: String(parts[0]), ofType: String(parts[1]))
            let text = try! String(contentsOf: URL(fileURLWithPath: path!), encoding: .utf8)
            responseText = text
            status = 200
            readyState = State.DONE.rawValue
            onreadystatechange?.call(withArguments: [])
        } else {
            loadUrl()
        }
    }

    private func loadUrl() {
        let session = URLSession.shared
        var req = URLRequest(
            url: URL(string: url)!,
            cachePolicy: .reloadIgnoringLocalCacheData)

        for header in headers {
            req.addValue(header.1, forHTTPHeaderField: header.0)
        }

        readyState = State.LOADING.rawValue
        onreadystatechange?.call(withArguments: [])
        let task = session.dataTask(with: req) { data, response, error in
            self.handleHttpResponse(data: data, response: response, error: error)

            self.readyState = State.DONE.rawValue
            self.onreadystatechange?.call(withArguments: [])
            self.onload?.call(withArguments: [])
            self.onloadend?.call(withArguments: [])
        }

        task.resume()
    }

    func handleHttpResponse(
        data: Data?, response: URLResponse?, error: Error?) {


        if let error = error {
            onerror?.call(withArguments: [])
            return
        }
        guard let response = response as? HTTPURLResponse else {
            onerror?.call(withArguments: [])
            return
        }
        urlResponce = response
        guard response.statusCode != 304 else {
            status = 304
            return
        }
        guard response.statusCode == 200 else {
            status = NSNumber(value: response.statusCode)
            return
        }
        guard let data = data else {
            return
        }

        status = 200

        switch responseType {
        case "arraybuffer":
            self.response = data as NSObject
        case "json":
            do {
                self.response = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSObject
            } catch {
                self.response = nil
            }
        case "", "text": fallthrough
        default:
            print ("loaded content", response.url)
            self.response = String(data: data, encoding: .utf8) as NSObject?
            responseText = String(data: data, encoding: .utf8)
        }
    }
}
