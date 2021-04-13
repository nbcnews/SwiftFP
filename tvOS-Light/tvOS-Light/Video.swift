//
//  Video.swift
//  tvOS-Light
//
//  Created by Denis on 3/23/21.
//

import Foundation
import JavaScriptCore

@objc protocol VideoExports: JSExport {
    var width: Int {get set}
    var height: Int {get set}
    var style: NSDictionary {get}
    var currenTime: Int {get set}
    var muted: Bool {get set}
//loop
//duration
    //videoWidth
    //videoHeight
    //setMediaKeys??

    func setAttribute(_ name: String, _ value: JSValue)
    func getAttribute(_ name: String) -> String?
    func removeAttribute(_ name: String)

    func addEventListener(_ type: String, _ listner: JSValue)
    func removeEventListener(_ type: String, _ listner: JSValue)
    func load()
    func play()
    func pause()
}

@objc public class Video : Element, VideoExports {

    var w: Int = 0
    var h: Int = 0
    var src: String = ""
    
    var width: Int {
        get { return w }
        set { w = newValue }
    }
    var height: Int {
        get { return h }
        set { h = newValue }
    }
    
    dynamic var currenTime: Int = 0
    dynamic var style = NSDictionary()
    var muted: Bool {
        get { return false }
        set {}
    }

    func setAttribute(_ name: String, _ value: JSValue) {
        if name == "id" {
            id = value.toString()
        } else if name == "src" {
            src = value.toString()
        }
    }
    func getAttribute(_ name: String) -> String? {
        if name == "src" {
            return src
        }
        return nil
    }
    func removeAttribute(_ name: String) {
        if name == "src" {
            src = ""
        }
    }

    func load() {

    }
    func play() {

    }
    func pause() {
        
    }
}
