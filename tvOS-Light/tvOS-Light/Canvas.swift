//
//  Canvas.swift
//  tvOS-Light
//
//  Created by Denis on 3/19/21.
//

import Foundation
import JavaScriptCore
import UIKit

@objc protocol CanvasExports: JSExport {
    var width: Int {get set}
    var height: Int {get set}
    func getContext(_ contextType: String, _ contextAttributes: JSValue) -> RenderingContext
}

@objc public class Canvas : Element, CanvasExports {
    var w: Int = 0
    var h: Int = 0
    var context2d: RenderingContext2d?
    var domAttached = false

    var width: Int {
        get { return w }
        set {
            w = newValue
            if let c2d = context2d {
                if w != 0 && h != 0 {
                    c2d.updateContext(w, h)
                }
            }
        }
    }
    var height: Int {
        get { return h }
        set {
            h = newValue
            if let c2d = context2d {
                if w != 0 && h != 0 {
                    c2d.updateContext(w, h)
                }
            }
        }
    }

    func getContext(_ contextType: String, _ contextAttributes: JSValue) -> RenderingContext {
        print("context", contextType)
        if context2d == nil {
            context2d = RenderingContext2d(self, width, height)
        }
        return context2d!
    }

}

@objc protocol RenderingContextExports: JSExport {
}

@objc public class RenderingContext : NSObject, RenderingContextExports {
}

@objc protocol RenderingContext2dExports: JSExport {
    var canvas: Canvas {get}
    var fillStyle: JSValue {get set}
    var font: String {get set}
    var globalAlpha: Float {get set}
    var globalCompositeOperation: String {get set}
    var imageSmoothingEnabled: JSValue {get set}
    var lineCap: JSValue {get set}
    var lineDashOffset: JSValue {get set}
    var lineJoin: JSValue {get set}
    var lineWidth: JSValue {get set}
    var miterLimit: JSValue {get set}
    var shadowBlur: Float {get set}
    var shadowColor: String {get set}
    var shadowOffsetX: Float {get set}
    var shadowOffsetY: Float {get set}
    var strokeStyle: JSValue {get set}
    var textAlign: JSValue {get set}
    var textBaseline: JSValue {get set}

    func arc()
    func arcTo(_ x1: Float, _ y1: Float, _ x2: Float, _ y2: Float, _ radius: Float)
    func beginPath()
    func bezierCurveTo()
    func clearRect(_ x: Double, _ y: Double, _ width: Double, _ height: Double)
    func clip(_ rule: String)
    func closePath()
    func createConicGradient()
    func createImageData()
    func createLinearGradient(_ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double) -> CanvasGradient
    func createPattern()
    func createRadialGradient()
    func drawFocusIfNeeded()
    func drawImage(_ image: JSValue, _ sx: Double, _ sy: Double, _ sWidth: Double, _ sHeight: Double, _ dx: Double, _ dy: Double, _ dWidth: Double, _ dHeight: Double)
    func ellipse()
    func fill(_ rule: String?)
    func fillRect(_ x: Double, _ y: Double, _ width: Double, _ height: Double)
    func fillText(_ text: String, _ x: Float, _ y: Float)
    func getContextAttributes()
    func getImageData()
    func getLineDash()
    func getTransform()
    func isPointInPath()
    func isPointInStroke()
    func lineTo(_ x: Float, _ y: Float)
    func measureText(_ text: String) -> NSDictionary
    func moveTo(_ x: Float, _ y: Float)
    func putImageData(_ data: NSDictionary, _ w: Int, _ h: Int)
    func quadraticCurveTo()
    func rect(_ x: Double , _ y: Double, _ width: Double, _ height: Double)
    func restore()
    func rotate()
    func save()
    func scale()
    func setLineDash()
    func setTransform(_ a: JSValue, _ b: Double, _ c: Double, _ d: Double, _ e: Double, _ f: Double)
    func stroke()
    func strokeRect()
    func strokeText()
    func transform(_ a: Double, _ b: Double, _ c: Double, _ d: Double, _ e: Double, _ f: Double)
    func translate(_ x: Double, _ y: Double)
}

@objc public class RenderingContext2d : RenderingContext, RenderingContext2dExports {
    var width: Int
    var height: Int

    weak var _canvas: Canvas?
    var canvas: Canvas {
        return _canvas!
    }

    var currentFont: UIFont
    var context: CGContext
    var didUpdate = true
    var fillColor: UIColor = UIColor.white

    init(_ canvas: Canvas, _ width: Int, _ height: Int) {
        self._canvas = canvas
        self.width = width
        self.height = height
        currentFont = UIFont.systemFont(ofSize: 40)

        //CGBitmapContextCreate(
        let width = width == 0 ? 1 : width
        let height = height == 0 ? 1 : height

        context = CGContext(data: nil, width: width, height: height,
                            bitsPerComponent: 8, bytesPerRow: width * 4,
                            space: CGColorSpaceCreateDeviceRGB(),
                            bitmapInfo: CGImageByteOrderInfo.order32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)!
        
//        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 1)
//        context = UIGraphicsGetCurrentContext()!

        print (context.bitmapInfo, CGImageAlphaInfo.premultipliedLast.rawValue,
               CGImageAlphaInfo.premultipliedFirst.rawValue,
               CGImageAlphaInfo.last.rawValue, CGImageAlphaInfo.first.rawValue,
               CGImageByteOrderInfo.order32Little.rawValue)
    }

    func updateContext(_ w: Int, _ h: Int) {
        if w == width && h == height { return }

//        if context == UIGraphicsGetCurrentContext() {
//            UIGraphicsEndImageContext()
//        }

        width = w
        height = h
//        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height <= 0 ? 150 : height), false, 1)
//        context = UIGraphicsGetCurrentContext()!
        context = CGContext(data: nil, width: width, height: height <= 0 ? 150 : height,
                            bitsPerComponent: 8, bytesPerRow: width * 4,
                            space: CGColorSpaceCreateDeviceRGB(),
                            bitmapInfo: CGImageByteOrderInfo.order32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)!
    }

    func getUIImage() -> UIImage? {
        context.flush()
        if let image = context.makeImage() {
            didUpdate = false
            return UIImage(cgImage: image)
        }
        return nil
    }

    dynamic var fillStyle: JSValue = JSValue() {
        didSet {
            print("fillStyle", fillStyle)
            if fillStyle.isString {
                let fillCss = fillStyle.toString()!
                if fillCss.starts(with: "rgba") {
                    let rgbaString = String(fillCss.split(separator: "(")[1].prefix{ $0 != ")" })
                    let rgba = rgbaString.split(separator: ",").map{ Float($0)! }
                    let color = CGColor(red: CGFloat(rgba[0]), green: CGFloat(rgba[1]), blue: CGFloat(rgba[2]), alpha: CGFloat(rgba[3]))
                    context.setFillColor(color)
                    fillColor = UIColor(cgColor: color)
                } else if fillCss == "white" {
                    context.setFillColor(gray: 1, alpha: 1)
                    fillColor = UIColor.white
                }
            } else if fillStyle.isInstance(of: CanvasGradient.self) {
                // ahem. ignore for now
                let gradient = fillStyle.toObjectOf(CanvasGradient.self)! as! CanvasGradient
                print ("gradient", gradient.stops, gradient.start, gradient.end)
                context.setFillColor(gray: 0.3, alpha: 0.1)
            }
        }
    }
    dynamic var font: String = "" {
        didSet {
            print (font.split(separator: " "))
        }
    }
    dynamic var globalAlpha: Float = 1.0 {
        didSet {
            context.setAlpha(CGFloat(globalAlpha))
        }
    }
    dynamic var globalCompositeOperation: String = "source-over" {
        didSet {
            switch globalCompositeOperation {
            case "multiply":
                context.setBlendMode(CGBlendMode.multiply)
            case "copy":
                context.setBlendMode(CGBlendMode.copy)
            case "destination-in":
                context.setBlendMode(CGBlendMode.destinationIn)
            default:
                context.setBlendMode(CGBlendMode.sourceAtop)
            }
        }
    }
    dynamic var imageSmoothingEnabled: JSValue = JSValue() {
        didSet {
            print (imageSmoothingEnabled)
        }
    }
    dynamic var lineCap: JSValue = JSValue() {
        didSet {}
    }
    dynamic var lineDashOffset: JSValue = JSValue() {
        didSet {}
    }
    dynamic var lineJoin: JSValue = JSValue() {
        didSet {}
    }
    dynamic var lineWidth: JSValue = JSValue() {
        didSet {}
    }
    dynamic var miterLimit: JSValue = JSValue() {
        didSet {}
    }
    dynamic var shadowBlur: Float = 0 {
        didSet {
            context.setShadow(offset: CGSize(width: CGFloat(shadowOffsetX), height: CGFloat(shadowOffsetY)), blur: CGFloat(shadowBlur))
        }
    }
    dynamic var shadowColor: String = "" {
        didSet {
            print ("shadow", shadowColor)
        }
    }
    dynamic var shadowOffsetX: Float = 0 {
        didSet {
            context.setShadow(offset: CGSize(width: CGFloat(shadowOffsetX), height: CGFloat(shadowOffsetY)), blur: CGFloat(shadowBlur))
        }
    }
    dynamic var shadowOffsetY: Float = 0 {
        didSet {
            context.setShadow(offset: CGSize(width: CGFloat(shadowOffsetX), height: CGFloat(shadowOffsetY)), blur: CGFloat(shadowBlur))
        }
    }
    dynamic var strokeStyle: JSValue = JSValue() {
        didSet {}
    }
    dynamic var textAlign: JSValue = JSValue() {
        didSet {}
    }
    dynamic var textBaseline: JSValue = JSValue() {
        didSet {

        }
    }


    func arc() {

    }

    func arcTo(_ x1: Float, _ y1: Float, _ x2: Float, _ y2: Float, _ radius: Float) {
        context.addArc(
            tangent1End: CGPoint(x: CGFloat(x1), y: CGFloat(y1)),
            tangent2End: CGPoint(x: CGFloat(x2), y: CGFloat(y2)),
            radius: CGFloat(radius))
    }

    func beginPath() {
        context.beginPath()
    }

    func bezierCurveTo() {

    }

    func clearRect(_ x: Double, _ y: Double, _ width: Double, _ height: Double) {
        context.clear(CGRect(x: x, y: y, width: width, height: height))
        didUpdate = true
    }

    func clip(_ rule: String) {
        context.clip()
    }

    func closePath() {
        context.closePath()
    }

    func createConicGradient() {

    }

    func createImageData() {

    }

    func createLinearGradient(_ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double) -> CanvasGradient {
        return CanvasGradient(CGPoint(x: CGFloat(x0), y: CGFloat(y0)), CGPoint(x: CGFloat(x1), y: CGFloat(y1)))
    }

    func createPattern() {

    }

    func createRadialGradient() {

    }
    
    func drawFocusIfNeeded() {
        
    }

    func drawImage(_ source: JSValue, _ sx: Double, _ sy: Double, _ sWidth: Double, _ sHeight: Double, _ dx: Double, _ dy: Double, _ dWidth: Double, _ dHeight: Double) {
        if height == 1080 {
            print (dx, dy)
        }
        if source.isInstance(of: Canvas.self) {
            let canvas = source.toObjectOf(Canvas.self) as! Canvas
            guard let cgImage = canvas.context2d?.context.makeImage() else { return }
            context.draw(cgImage, in: CGRect(x: dx, y: dy, width: dWidth, height: dHeight))
        } else if source.isInstance(of: Image.self) {
            let img = source.toObjectOf(Image.self) as! Image
            guard let cgImage = img.image?.cgImage else { return }
            context.draw(cgImage, in: CGRect(x: dx, y: dy, width: dWidth, height: dHeight))
        } else {
            print ("huu?")
        }
        didUpdate = true
    }

    func ellipse() {

    }

    func fill(_ rule: String?) {
        if let rule = rule, rule == "evenodd" {
            context.fillPath(using: CGPathFillRule.evenOdd)
        } else {
            context.fillPath()
        }
        didUpdate = true
    }

    func fillRect(_ x: Double, _ y: Double, _ width: Double, _ height: Double) {
        context.fill(CGRect(x: x, y: y, width: width, height: height))
        didUpdate = true
    }

    func fillText(_ text: String, _ x: Float, _ y: Float) {
        print(text, x, y)
        UIGraphicsPushContext(context)
        let string = NSAttributedString(string: text, attributes: [.font: currentFont, .foregroundColor: fillColor])
        string.draw(at: CGPoint(x: CGFloat(x), y: CGFloat(y)))
        UIGraphicsPopContext()
        didUpdate = true
    }

    func getContextAttributes() {

    }

    func getImageData() {

    }

    func getLineDash() {

    }

    func getTransform() {

    }

    func isPointInPath() {

    }

    func isPointInStroke() {

    }

    func lineTo(_ x: Float, _ y: Float) {
        context.addLine(to: CGPoint(x: CGFloat(x), y: CGFloat(y)))
    }

    func measureText(_ text: String) -> NSDictionary {
        let d = NSMutableDictionary()
        let size = text.size(withAttributes: [.font: currentFont])
        d["width"] = size.width
        d["height"] = size.height
        return d
    }

    func moveTo(_ x: Float, _ y: Float) {
        context.move(to: CGPoint(x: CGFloat(x), y: CGFloat(y)))
    }

    func putImageData(_ data: NSDictionary, _ w: Int, _ h: Int) {
        // render into context
        print (data)
        if let ptr = context.data {
            ptr.storeBytes(of: [255,255,255,255], as: [UInt8].self)
        }
//        print (data["data"])
        didUpdate = true
    }

    func quadraticCurveTo() {

    }

    func rect(_ x: Double , _ y: Double, _ width: Double, _ height: Double) {
        context.addRect(CGRect(x: x, y: y, width: width, height: height))
    }

    func restore() {
        context.restoreGState()
    }

    func rotate() {

    }

    func save() {
        context.saveGState()
    }

    func scale() {

    }

    func setLineDash() {

    }

    func setTransform(_ a: JSValue, _ b: Double, _ c: Double, _ d: Double, _ e: Double, _ f: Double) {
        //let f = Double(height) - f
        let dx = CGFloat(e) - context.ctm.tx
        let dy = CGFloat(f) - context.ctm.ty
        context.translateBy(x: CGFloat(dx), y: CGFloat(dy))
    }

    func stroke() {

    }

    func strokeRect() {

    }

    func strokeText() {

    }

    func transform(_ a: Double, _ b: Double, _ c: Double, _ d: Double, _ e: Double, _ f: Double) {

    }

    func translate(_ x: Double, _ y: Double) {
        context.translateBy(x: CGFloat(x), y: CGFloat(y))
    }

}

@objc protocol ImageDataExports: JSExport {
//    init(_ data: JSValue, _ width: Int, _ height: NSNumber?)
    var width: Int {get}
    var height: Int {get}
    var data: [UInt8] {get}
}

@objc public class ImageData : NSObject, ImageDataExports {
    dynamic var width: Int = 0
    dynamic var height: Int = 0
    dynamic var data: [UInt8] = []
}

@objc protocol ImageExports: JSExport {
    var width: Int {get set}
    var height: Int {get set}
    var src: String? {get set}
    var onerror: JSValue? {get set}
    var onload: JSValue? {get set}
    
    init(_ w: Int, _ h: Int)
    func removeAttribute(_ name: String)
}
@objc public class Image : Element, ImageExports {

    var image: UIImage?

    required init(_ w: Int, _ h: Int) {
        width = w
        height = h
    }

    required public init() {
        width = 0
        height = 0
    }

    dynamic var onload: JSValue?
    dynamic var onerror: JSValue?
    
    dynamic var src: String? {
        didSet {
            if src != nil {
                load()
            }
        }
    }

    dynamic var width: Int
    dynamic var height: Int

    func removeAttribute(_ name: String) {
        // release image?
        if name == "src" {

        }
    }

    deinit {
        print("deinit")
    }
    func load() {
        if src!.starts(with: "./") || src!.starts(with: "/") {
            loadFromBundle()
        } else {
            loadFromUrl()
        }
    }

    func loadFromBundle() {
        let parts = Array(src!.split(whereSeparator: {$0 == "/" || $0 == "."}).suffix(2))
        let path = Bundle.main.path(forResource: String(parts[0]), ofType: String(parts[1]))
        image = UIImage(contentsOfFile: path!)
        if image != nil {
            width = Int(image!.size.width)
            height = Int(image!.size.height)
            onload?.call(withArguments: [])
        } else {
            onerror?.call(withArguments: [])
        }
    }

    func loadFromUrl() {
        let session = URLSession.shared
        let req = URLRequest(
            url: URL(string: src!)!,
            cachePolicy: .reloadIgnoringLocalCacheData)
        let task = session.dataTask(with: req) { data, response, error in
            self.handleHttpResponse(data: data, response: response, error: error)
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
        guard response.statusCode == 200 else {
            onerror?.call(withArguments: [])
            return
        }
        guard let data = data else {
            onerror?.call(withArguments: [])
            return
        }

        print ("loaded image", response.url)
        image = UIImage(data: data)

        if image != nil {
            width = Int(image!.size.width)
            height = Int(image!.size.height)
            onload?.call(withArguments: [])
        }
    }
}


@objc protocol CanvasGradientExports: JSExport {
    func addColorStop(_ offset: Double, _ color: String)
}

@objc public class CanvasGradient : Element, CanvasGradientExports {
    var stops = [(Double,String)]()
    var start: CGPoint
    var end: CGPoint

    init(_ start: CGPoint, _ end: CGPoint) {
        self.start = start
        self.end = end
    }

    required public init() {
        fatalError("init() has not been implemented")
    }

    func addColorStop(_ offset: Double, _ color: String) {
        stops.append((offset, color))
    }
}
