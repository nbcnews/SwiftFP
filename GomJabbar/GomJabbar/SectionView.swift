//
//  Section.swift
//  Copyright © 2019-20 NBC News Digital. All rights reserved.
//

import SwiftUI
import Combine

struct SectionView: View {
    private let section: SectionModule
    init(_ section: SectionModule) {
        self.section = section
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(section.header ?? "No header")
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(section.items.enumerated()), id: \.1.id) { i, item in
//                ForEach(section.items) { item in
                     self.row(item)
                }
            }
        }
    }

    func row(_ item: ContentItem) -> some View {
        switch item {
        case .story(let story):
            return storyView(story)
        case .video(let video):
            return videoView(video)
        case .slideshow(let slideshow):
            return slideshowView(slideshow)
        case .unsupported:
            fatalError()
        }
    }

    func storyView(_ story: Story) -> AnyView {
        AnyView(
            VStack(alignment: .leading,  spacing: 0) {
                Optional(story.tease) { tease in
                    ZStack(alignment: .bottomLeading) {
                        AimsImage(aimsUrl: tease)
                            .aspectRatio(2, contentMode: .fit)

                        Text(story.label!)
                            .foregroundColor(.blue)
                            .padding(10)
                            .background(Color.white)
                    }
                }.background(Color.orange)
                Text(story.headline)
                    .font(.custom("Avenir Next Condensed", size: 23))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .lineLimit(5)
                    .padding(.top, 10)
            }
            .padding(20)
            .background(Color.yellow)
        )
    }
    func videoView(_ video: Video) -> AnyView {
        AnyView(
        Text(video.headline).multilineTextAlignment(.leading).lineLimit(5)
        )
    }
    func slideshowView(_ slideshow: Slideshow) -> AnyView {
        AnyView(
        Text(slideshow.headline).multilineTextAlignment(.leading).lineLimit(5)
        )
    }
}
