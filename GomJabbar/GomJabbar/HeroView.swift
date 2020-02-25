//
//  Hero.swift
//  Copyright © 2019-20 NBC News Digital. All rights reserved.
//

import SwiftUI
import Combine

struct HeroView: View {
    private let model: ContentItem
    init(_ hero: HeroModule) {
        model = hero.item
    }

    @State var focused = false

    var body: AnyView {
        switch model {
        case .story(let story):
            return storyView(story)
        case .video(let video):
            return videoView(video)
        case .slideshow(let slideshow):
            return slideshowView(slideshow)
        case .unsupported:
            return AnyView(EmptyView())
        }
    }

    private func storyView(_ story: Story) -> AnyView {
        AnyView(
            ZStack(alignment: .bottomLeading) {
                aimsImage(url: story.tease)
                    .frame(minWidth: 100, maxWidth: .infinity)

                VStack(alignment: .leading) {
                    HStack(spacing: 16) {
                        if story.label != nil {
                            Text(story.label!)
                                .foregroundColor(.white)
                                .padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4))
                                .background(focused ? Color.red : Color.clear)
                                .offset(x: 0, y: focused ? 0 : -30)
                                .animation(.easeOut).clipped()
                        }
//                        Text(story.published.time()).foregroundColor(.white)
                    }
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 7))
                    .geometry { geometry in
                        let frame = geometry.frame(in: .global)
                        //print ("set focused to", frame.midY > 200 && frame.midY < 600)
                        DispatchQueue.main.async {
                            self.focused = frame.midY > 200 && frame.midY < 600
                        }
                    }

                    if story.author != nil {
                        Text("By " + story.author!)
                            .font(.custom("Consolas", size: 14))
                            .foregroundColor(.white)
                            .padding(EdgeInsets(top: 3, leading: 20, bottom: 0, trailing: 7))
                    }

                    Text(story.headline)
                        .font(.custom("Avenir Next Condensed", size: 23))
                        .fontWeight(.bold)
                        .lineLimit(4)
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 4)
                        .padding(EdgeInsets(top: 5, leading: 20, bottom: 20, trailing: 20))
                }
                .frame(maxWidth: .infinity, alignment: .bottomLeading)
                .padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 0))
                .background(LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.0),
                            Color.black.opacity(0.4),
                            Color.black.opacity(0.6),
                            Color.black.opacity(0.7)]),
                    startPoint: .top, endPoint: .bottom))
            }
            .aspectRatio(1, contentMode: .fit)
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
            .background(Color.red)
        )
    }

    private func videoView(_ video: Video) -> AnyView {
        AnyView(
            ZStack(alignment: .bottomLeading) {
                aimsImage(url: video.tease)
                    .frame(minWidth: 100, maxWidth: .infinity)

                Optional(video.preview) { preview in
                    if self.focused {
                        AVPlayerView(url: preview)
                            .frame(maxWidth: .infinity)
                    }
                }

                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 16) {
                        if video.label != nil {
                            Text(video.label!)
                                .foregroundColor(.white)
                                .padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4))
                                .background(focused ? Color.red : Color.clear)
                                .animation(.easeOut)
                        }
//                        Text(video.published.time()).foregroundColor(.white)
                    }
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 7))
                        .background(GeometryReader { proxy in
                            Color.clear.exe {
                                let frame = proxy.frame(in: .global)
                                //print ("set focused to", frame.midY > 200 && frame.midY < 600)
                                DispatchQueue.main.async {
                                    self.focused = frame.midY > 200 && frame.midY < 600
                                }
                            }
                        })
                    Text(video.headline)
                        .font(.custom("Avenir Next Condensed", size: 23))
                        .fontWeight(.bold)
                        .lineLimit(4)
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 4)
                        .padding(EdgeInsets(top: 5, leading: 20, bottom: 20, trailing: 20))
                    HStack(spacing: 0) {
                        Text(video.duration.formatted())
                            .padding(EdgeInsets(top: 7, leading: 20, bottom: 7, trailing: 20))
                            .frame(height: 40)
                            .foregroundColor(.white)
                            .background(Color.blue)
                        SwiftUI.Image("listenOn")
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .background(Color.red)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .bottomLeading)
                .padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 0))
                .background(LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.0),
                            Color.black.opacity(0.4),
                            Color.black.opacity(0.6),
                            Color.black.opacity(0.7)]),
                    startPoint: .top, endPoint: .bottom))
            }
            .aspectRatio(1, contentMode: .fit)
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
            .background(Color.red)
        )
    }

    private func slideshowView(_ slideshow: Slideshow) -> AnyView {
        AnyView(
        VStack {
            aimsImage(url: slideshow.tease)
            Text(slideshow.headline).lineLimit(4).font(Font.largeTitle)
        }
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
        )
    }

    private func aimsImage(url: URL?) -> some View {
        if let url = url {
            return AnyView(AimsImage(aimsUrl: url).padding(0))
        }

        return AnyView(EmptyView())
    }
}

extension View {
    func geometry(callback: @escaping (GeometryProxy) -> Void) -> some View {
        return background(GeometryReader { proxy in
            Color.clear.exe {
                callback(proxy)
            }
        })
    }

    func exe(cb: () -> ()) -> some View {
        cb()
        return self
    }
}

#if DEBUG
struct HeroView_Previews : PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
        HeroView(
            HeroModule(item:
                .story(Story(id: "story1",
                             published: Date(),
                             headline: "As rivals battle in early states, Bloomberg quietly courts party influencers",
                             tease: URL(string: "https://media2.s-nbcnews.com/i/newscms/2020_07/3206071/200128-mike-bloomberg-se-304p_7be841bc0e8e9fba9e8061adfeec443b.jpg")!,
                             alternateTeases: nil,
                             summary: "Just a preview text. Nothing to see. Nothing at all.",
                             author:  "Shakespear",
                             url: nil,
                             label: "2020 ELECTION",
                             breaking: false,
                             external: false,
                             tracking: nil))))
        HeroView(
            HeroModule(item:
            .video(Video(
                id: "mmvo78520389565",
                headline: "Nightly News Full Broadcast (February 10th)",
                duration: Duration(),// "00:19:04",
                tease: URL(string: "https://media13.s-nbcnews.com/i/MSNBC/Components/Video/202002/nn_tco_equifax_hack_indictment_2000210_1920x1080.jpg")!,
                alternateTeases: nil,
                preview: URL(string: "http://public.vilynx.com/55fadc4335f5f7df602080946ebb4c4c/pro69high.viwindow.mp4?t=1581392118.18061")!,
                published: Date(),//"2020-02-11T02:09:22Z"),
                summary: "U.S. charges four Chinese military hackers with massive Equifax breach, Walmart shootout leaves two officers injured in Arkansas and number of coronavirus cases soars to over 40,000 in China.",
                videoUrl: URL(string: "http://link.theplatform.com/s/rksNhC/1CjgkBGlV0Fz?mbr=true&manifest=m3u&metafile=none")!,
                label: nil,
                breaking: false,
                url: URL(string: "https://www.nbcnews.com/nightly-news-netcast/video/nightly-news-full-broadcast-february-10th-78520389565"),
                associatedPlaylist: nil,
                freeWheel: nil, tracking: nil))))
        }
    }
}
#endif

