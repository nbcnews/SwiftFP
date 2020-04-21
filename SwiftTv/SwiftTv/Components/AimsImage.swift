//
//  AimsImage.swift
//  GomJabbar
//
//  Created by Denis on 2/21/20.
//  Copyright © 2020 NBC News Digital. All rights reserved.
//

import SwiftUI

struct AimsImage: View {

    let aimsUrl: URL

    init(aimsUrl: URL) {
        self.aimsUrl = aimsUrl
    }

    var body: some View {
        Color.clear.overlay(
            GeometryReader { geometry in
                URLImage(url: self.aimsUrl.aimsUrl(for: geometry.size, cropMode: 5, quality: 80),
                         placeholder: Color.gray)
            })
    }
}

struct URLImage<V: View>: View {

    @ObservedObject private var imageLoader = ImageLoader()

    let placeholder: V

    init(url: URL?, placeholder: V) {
        self.placeholder = placeholder
        if let url = url {
            self.imageLoader.load(url: url)
        }
    }

    var body: some View {
        if let uiImage = imageLoader.downloadedImage {
            return AnyView(
                Image(uiImage: uiImage)
                .frame(maxWidth: .infinity, maxHeight: .infinity))
        } else {
            return AnyView(placeholder)
        }
    }
}

extension URL {
    public func aimsUrl(for size: CGSize, cropMode: Int, quality: Int) -> URL? {
        guard size.width > 1 && size.height > 1 else { return nil }

        //print ("aims for \(path) at \(size.width), \(size.height)")
        let ext = self.pathExtension.lowercased()
        guard self.path.lowercased().starts(with: "/i/"),
            ext == "jpg" || ext == "jpeg" || ext == "png" || ext == "gif" else {
                return nil
        }

        let s = self.absoluteString.lowercased().replacingOccurrences(of: "/i/", with: "/j/")
        let w = Int(size.width * UIScreen.main.scale)
        let h = Int(size.height * UIScreen.main.scale)

        if ext == "png" {
            return URL(string: s.replacingOccurrences(of: ".png", with: ".png,\(w);\(h);7;87;\(cropMode).jpg"))
        }

        if ext == "gif" {
            return URL(string: s.replacingOccurrences(of: ".gif", with: ".gif,\(w);\(h);7;\(quality);\(cropMode).jpg"))
        }

        if ext == "jpeg" {
            return URL(string: s.replacingOccurrences(of: ".jpeg", with: ".jpeg,\(w);\(h);7;\(quality);\(cropMode).jpeg"))
        }

        return URL(string: s.replacingOccurrences(of: ".jpg", with: ".\(w);\(h);7;\(quality);\(cropMode).jpg"))
    }
}
