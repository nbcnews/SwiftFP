//
//  RawPixels.swift
//

import Foundation
import UIKit
import CoreGraphics

func imageFromPixelValuesARGB(pixelValues: [UInt8], width: Int, height: Int) -> CGImage?
{
    var imageRef: CGImage?
    let colorSpaceRef = CGColorSpaceCreateDeviceRGB()

    let bitsPerComponent = 8
    let bytesPerPixel = 4
    let bitsPerPixel = bytesPerPixel * bitsPerComponent
    let bytesPerRow = bytesPerPixel * width
    let totalBytes = height * bytesPerRow

    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue)
//        .union([])

    let provider = CGDataProvider(dataInfo: nil, data: pixelValues, size: totalBytes) { _,_,_ in }
    imageRef = CGImage(
        width: width,
        height: height,
        bitsPerComponent: bitsPerComponent,
        bitsPerPixel: bitsPerPixel,
        bytesPerRow: bytesPerRow,
        space: colorSpaceRef,
        bitmapInfo: bitmapInfo,
        provider: provider!,
        decode: nil,
        shouldInterpolate: false,
        intent: CGColorRenderingIntent.defaultIntent)

    return imageRef
}

//func pixelValuesFromImage(imageRef: CGImage) -> ([UInt8]?, width: Int, height: Int)
//{
//    var width = 0
//    var height = 0
//    var pixelValues: [UInt8]?
//
//        width = imageRef.width
//        height = imageRef.height
//        let bitsPerComponent = imageRef.bitsPerComponent
//        let bytesPerRow = imageRef.bytesPerRow
//        let totalBytes = height * bytesPerRow
//
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        var buffer = [UInt8](repeating: 0, count: totalBytes)
//        let contextRef = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: 0)
//
////        let contextRef = CGContext(data: mutablePointer, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: 0)
//        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height))
//        contextRef?.draw(imageRef, in: rect)
////    Array<UInt8>(contextRef!.data?.bindMemory(to: UInt8.self, capacity: totalBytes))
////        let bufferPointer = UnsafeBufferPointer<UInt8>(start: mutablePointer, count: totalBytes)
//        pixelValues = Array<UInt8>(bufferPointer)
//
//    return (pixelValues, width, height)
//}
