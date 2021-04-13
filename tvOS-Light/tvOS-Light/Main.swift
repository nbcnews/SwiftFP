//
//  Main.swift
//  tvOS-Light
//
//  Created by Denis on 3/18/21.
//

import Foundation
import JavaScriptCore
import OpenGLES
import SwiftUI

class Main: ObservableObject {
    var jsc: JSContext
    var listners = Dictionary<String, JSValue>()
    var window = WindowObj()
    var document = Document()
    var timer: Timer?
    var image: UIImage?
    var canvas: Canvas?

    init() {
        jsc = JSContext()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "RenderCanvas"), object: nil, queue: nil) { n in
            self.canvas = n.userInfo?["canvas"] as? Canvas
        }

        jsc.exceptionHandler = { context, exception in
            if let exception = exception {
                print(context, exception.toString()!, exception)
            }
        }

        jsc.setObject(document, forKeyedSubscript: "document" as NSString)
        jsc.setObject(window, forKeyedSubscript: "window" as NSString)
        jsc.setObject(Console(), forKeyedSubscript: "console" as NSString)
        jsc.setObject(XMLHttpRequest.self, forKeyedSubscript: "XMLHttpRequest" as NSString)
        jsc.setObject(Image.self, forKeyedSubscript: "Image" as NSString)
        //jsc.setObject(Element.self, forKeyedSubscript: "Element" as NSString) //wrong Element?

        evalScript("url")
        evalScript("fetch")

        let path = Bundle.main.path(forResource: "startApp", ofType: "js")
        let code = try! String(contentsOf: URL(fileURLWithPath: path!), encoding: .utf8)

        jsc.evaluateScript("""
            var requestAnimationFrame = window.requestAnimationFrame.bind(window)
            var cancelAnimationFrame = window.cancelAnimationFrame.bind(window)
            var addEventListener = window.addEventListener.bind(window)
            var removeEventListener = window.removeEventListener.bind(window)
            var setTimeout = window.setTimeout.bind(window)
            var clearTimeout = window.clearTimeout.bind(window)
            var setInterval = window.setInterval.bind(window)
            var clearInterval = window.clearInterval.bind(window)
            var URLSearchParams = window.URLSearchParams
            var URL = window.URL
            window.fetch = fetch
            window.Date = Date
            window.XMLHttpRequest = XMLHttpRequest
            class ImageData {
                constructor(data, w, h) {
                    if (typeof data === 'number') {
                        this.data = Uint8ClampedArray.from([0,0,0,0])
                        this.width = data
                        this.height = w
                    } else {
                        this.data = data
                        this.width = w
                        this.height = h ? h : data.length / w
                    }
                }
            }
            document.fonts = {
                add: (font) => { console.log('addfont', font) },
                check: (font, extra) => { console.log('checkfont', font, extra); return true },
                load: (font, extra) => { return new Promise((resolve, reject) => {
                    resolve(true)
                })}
            }
            class FontFace {
                constructor(family, url, desc) {
                    console.log('new FontFace', family, url)
                    this.family = family
                    this.url = url
                    this.desc = desc
                }
                load() {}
            }
            Object.defineProperty(document.location, 'hash', {
              set: function(url) { window.setHash(url); },
              get: function() { return window.getHash(); }
            })
            """)
        jsc.evaluateScript("XMLHttpRequest.UNSENT=0;XMLHttpRequest.OPENED=1;XMLHttpRequest.HEADERS_RECEIVED=2;XMLHttpRequest.LOADING=3;XMLHttpRequest.DONE=4;")
        jsc.evaluateScript("let navigator = {userAgent: \"JavaScriptCore tvOS\"}")
        jsc.evaluateScript(code, withSourceURL: URL(string: "local://startApp.js"))

        startAnimationTimer()
    }

    func evalScript(_ name: String) {
        let path = Bundle.main.path(forResource: name, ofType: "js")
        let code = try! String(contentsOf: URL(fileURLWithPath: path!), encoding: .utf8)
        jsc.evaluateScript(code)
    }

    func startAnimationTimer() {
        if timer != nil { return }
        timer = Timer.scheduledTimer(withTimeInterval: 0.017, repeats: true) { timer in
            if let canvas = self.canvas, let context = canvas.context2d  {
                if context.didUpdate {
                    self.objectWillChange.send()
                    self.image = context.getUIImage()
                }
            }
            self.window.callAnimationFrameCallbacks()
        }
    }

}

@objc protocol EventTargetExports: JSExport {
    func addEventListener(_ type: String, _ listner: JSValue)
    func removeEventListener(_ type: String, _ listner: JSValue)
}

@objc public class EventTarget : NSObject, EventTargetExports {
    var listners = Dictionary<String, JSValue>()

    func addEventListener(_ type: String, _ listner: JSValue) {
        print ("addListner", self.debugDescription, type)
        self.listners[type] = listner
    }

    func removeEventListener(_ type: String, _ listner: JSValue) {
        self.listners.removeValue(forKey: type)
    }
}

@objc protocol WindowExports: JSExport {
    //subscript(_ key: String) -> NSObject? { get }
    var location: Location {get}
    var innerHeight: Int {get}
    var innerWidth: Int {get}

    func requestAnimationFrame(_ callback: JSValue) -> Int
    func cancelAnimationFrame(_ request: Int)

    func setTimeout(_ callback: JSValue, _ timeout: Int, _ arg1: JSValue, _ arg2: JSValue) -> Int
    func clearTimeout(_ id: Int)
    func setInterval(_ callback: JSValue, _ timeout: Int, _ arg1: JSValue, _ arg2: JSValue) -> Int
    func clearInterval(_ id: Int)

    func setHash(_ hash: String)
    func getHash() -> String
}
@objc public class WindowObj : EventTarget, WindowExports {

    private var animationFrames = Dictionary<Int, JSValue>()
    private var timers = Dictionary<Int, Timer>()
    private var _hash: String = ""

    dynamic var location = Location()
    dynamic let innerWidth = 1920
    dynamic let innerHeight = 1080

    func setHash(_ hash: String) {
        _hash = hash
        let cb = listners["hashchange"]
        cb?.call(withArguments: [])
    }
    func getHash() -> String {
        return _hash
    }

    func requestAnimationFrame(_ callback: JSValue) -> Int {
        let request = Int.random(in: 1..<100000)
        animationFrames[request] = callback
        return request
    }
    func cancelAnimationFrame(_ request: Int) {
        animationFrames.removeValue(forKey: request)
    }
    func callAnimationFrameCallbacks() {
        guard animationFrames.count > 0 else { return }
        let frametime = Date().timeIntervalSinceReferenceDate * 1000
        let callbacks = Array(animationFrames.values)//copy
        animationFrames.removeAll()
        callbacks.forEach{$0.call(withArguments: [frametime])}
    }

    func setTimeout(_ callback: JSValue, _ timeout: Int, _ arg1: JSValue, _ arg2: JSValue) -> Int {
        let id = Int.random(in: 1..<100000)
        if timeout == 0 {
            DispatchQueue.main.async {
                callback.call(withArguments: [arg1, arg2])
            }
            return 1
        }
        
        let timer = Timer.scheduledTimer(withTimeInterval: Double(timeout)/1000, repeats: false) { _ in
            self.timers.removeValue(forKey: id)
            callback.call(withArguments: [arg1, arg2])
        }
        timers[id] = timer
        return id
    }

    func clearTimeout(_ id: Int) {
        if let timer = timers[id] {
            timer.invalidate()
            timers.removeValue(forKey: id)
        }
    }

    func setInterval(_ callback: JSValue, _ timeout: Int, _ arg1: JSValue, _ arg2: JSValue) -> Int {
        let id = Int.random(in: 1..<100000)
        let timer = Timer.scheduledTimer(withTimeInterval: Double(timeout)/1000, repeats: true) { _ in
            callback.call(withArguments: [arg1, arg2])
        }
        timers[id] = timer
        return id
    }

    func clearInterval(_ id: Int) {
        clearTimeout(id)
    }

}

@objc protocol DocumentExports: JSExport {
    var body: Body {get}
    var head: Body {get}
    var location: Location {get}

    func createElement(_ tag: String) -> Element
}

@objc public class Document : Element, DocumentExports {
    dynamic var body: Body
    dynamic var head: Body
    dynamic var location: Location

    required init() {
        self.body = Body()
        self.head = Body()
        self.location = Location()
    }

    func createElement(_ tag: String) -> Element {
        print ("createElement", tag)
        if tag == "script" {
            return Script()
        }
        if tag == "style" {
            return Style()
        }
        if tag == "input" {
            return Input()
        }
        if tag == "canvas" {
            return Canvas()
        }
        if tag == "image" {
            return Image(0, 0)
        }
        if tag == "video" {
            return Video()
        }

        return Element()
    }
}

@objc protocol LocationExports: JSExport {
    var ancestorOrigins: String {get}
    var href: String {get set}
    var `protocol`: String {get}
    var host: String {get}
    var hostname: String {get}
    var port: String {get}
    var pathname: String {get}
    var search: String {get}
    //var hash: String {get set}
    var origin: String {get}

    func assign(_ url: String)
    func reload()
    func replace(_ url: String)
    func toString() -> String
}
@objc public class Location : NSObject, LocationExports {
    dynamic var ancestorOrigins: String = ""
    var href: String {
        get { return "http://local/"}
        set { print(newValue) }
    }
    dynamic var `protocol`: String = "http"
    dynamic var host: String = "local"
    dynamic var hostname: String = "local"
    dynamic var port: String = ""
    dynamic var pathname: String = ""
    dynamic var search: String = ""
//    dynamic public var hash: String
    dynamic var origin: String = ""

    //public override dynamic var `hash`: String

    func assign(_ url: String) {
    }

    func reload() {
    }

    func replace(_ url: String) {
    }

    func toString() -> String {
        return ""
    }
}

@objc public class Body : Element {
    override func appendChild(_ child: Element) {
        children.append(child)
        // if child is script... got to load
        if child is Script {
            (child as! Script).load()
        }
        if child is Canvas {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RenderCanvas"), object: child, userInfo: ["canvas": child])
        }
    }
}

@objc protocol ElementExports: JSExport {
    var id: String {get set}
    var tag: String {get}

    func appendChild(_ child: Element)
    func getElementById(_ id: String) -> Element?
    func getElementsByTagName(_ tag: String) -> [Element]

    init()
}

@objc public class Element : EventTarget, ElementExports {
    var tag: String { "" }

    var children = [Element]()

    dynamic var id = ""

    required public override init() {

    }

    func getElementById(_ id: String) -> Element? {
        return children.first(where: {$0.id == id})
    }

    func getElementsByTagName(_ tag: String) -> [Element] {
        return children.filter{$0.tag == tag}
    }

    func appendChild(_ child: Element) {
        children.append(child)
    }

    func remove() {
        
    }
}

@objc protocol StyleSheetExports: JSExport {
    func insertRule(_ rule: String)
}
@objc public class StyleSheet : NSObject, StyleSheetExports {
    var rules = [String]()
    func insertRule(_ rule: String) {
        rules.append(rule)
    }
}

@objc protocol StyleExports: JSExport {
    var sheet: StyleSheet {get}
}
@objc public class Style : Element, StyleExports {
    override var tag: String { "style" }
    dynamic var sheet = StyleSheet()
}

@objc protocol ScriptExports: JSExport {
    var onload: JSValue? {get set}
    var src: String? {get set}
}
@objc public class Script : Element, ScriptExports {
    dynamic var onload: JSValue?
    dynamic var src: String?

    override var tag: String { "script" }

    func load() {
        if let url = src, !url.isEmpty {
            if url.starts(with: "./") {
                let parts = Array(url.split(whereSeparator: {$0 == "/" || $0 == "."}).suffix(2))
                let path = Bundle.main.path(forResource: String(parts[0]), ofType: String(parts[1]))
                let code = try! String(contentsOf: URL(fileURLWithPath: path!), encoding: .utf8)
                JSContext.current().evaluateScript(code)
                onload?.call(withArguments: [])
            }
        }
    }
}

@objc protocol InputExports: JSExport {
    var type: String? {get set}
    var value: String? {get set}
    func checkValidity() -> Bool
}
@objc public class Input : Element, InputExports {
    dynamic var type: String?
    dynamic var value: String?

    func checkValidity() -> Bool {
        return true
    }
}

@objc protocol ConsoleExports: JSExport {
    func log(_ v: JSValue, _ v1: JSValue, _ v2: JSValue)
    func time(_ v: String)
    func warn(_ v: String)
    func error(_ v: JSValue, _ v1: JSValue, _ v2: JSValue)
}

@objc public class Console : NSObject, ConsoleExports {
    func log(_ v: JSValue, _ v1: JSValue, _ v2: JSValue) {
        if !v2.isUndefined {
            print(v, v1, v2)
        } else if (!v1.isUndefined) {
            print(v, v1)
        } else if (!v.isUndefined) {
            print(v)
        }
    }
    func warn(_ v: String) {
        print(v)
    }

    func time(_ v: String) {
        print("time", v)
    }

    func error(_ v: JSValue, _ v1: JSValue, _ v2: JSValue) {
        log(v, v1, v2)
    }
}

