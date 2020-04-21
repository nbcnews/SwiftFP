//
//  MenuGridView.swift
//
//  Copyright © 2020 NBC News Digital. All rights reserved.
//

import SwiftUI

struct MenuGridView: View {
    @EnvironmentObject var d: Model
    
    var body: some View {

        if let modules = d.model?.channels {
            return AnyView(
                List(modules, id: \.id) { entry in
                    Row(data: entry)
                }
            )
        } else {
            return AnyView(Text("Loading..."))
        }
    }
}

struct Row: View {
    let data: MenuCollectionEntry

    var body: some View {
        switch data {
        case .pages(let cards):
            return AnyView(CardsRow(cards: cards))
        case .playlists(let cards):
            return AnyView(CardsRow(cards: cards))
        case .playlist(let playlist):
            return AnyView(PlaylistRow(playlist: playlist))
        case .videos(let playlist):
            return AnyView(PlaylistRow(playlist: playlist))
        case .playmakerLive(let playlist):
            return AnyView(PlaylistRow(playlist: playlist))
        }
    }
}

struct CardsRow: View {
    let cards: Cards

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(cards.cards, id: \.id) { card in
                    CardFView(card: card)
                }
            }
            .padding([.top, .bottom], 20)
        }
    }
}

struct PlaylistRow: View {
    let playlist: Playlist

    var body: some View {
        ScrollView (.horizontal) {
            HStack {
                ForEach(playlist.videos, id: \.id) { video in
                    VideoButtonView(video: video)
                }
            }
            .padding([.top, .bottom], 40)
        }
    }
}

struct CardView: View {
    let card: Card

    @State private var focused = false

    var body: some View {
        ZStack {
            AimsImage(aimsUrl: card.image)
                .frame(width: 380, height: 200)
            Text(card.title)
                .font(.body)
                .lineLimit(3)
                .foregroundColor(.white)
                .frame(alignment: .center)
        }
        .focusable() { focused in
            self.focused = focused
        }
        .cornerRadius(10)
        .shadow(radius: focused ? 7 : 0)
        .scaleEffect(focused ? 1.1 : 1)
        .animation(.easeInOut(duration: 0.2))
    }
}

struct CardFView: View {
    let card: Card

    @State private var focused = false

    var body: some View {
        FocusView(
            onFocusChange: { focused in
                self.focused = focused
            },
            onTap: { state in
                print ("state", state)
            }) {

            ZStack {
                AimsImage(aimsUrl: self.card.image)
                    .frame(width: 380, height: 200)
                Text(self.card.title)
                    .font(.body)
                    .lineLimit(3)
                    .foregroundColor(.white)
                    .frame(alignment: .center)
            }

            .cornerRadius(10)
            .shadow(radius: self.focused ? 7 : 0)
            .scaleEffect(self.focused ? 1.1 : 1)
            .animation(.easeInOut(duration: 0.2))
        }
        //.frame(width: 380, height: 200)
    }
}

struct VideoView: View {
    let video: xVideo

    @State private var focused = false

    var body: some View {
        ZStack {
            AimsImage(aimsUrl: video.tease!)
                .frame(width: 400, height: 200)
            Text(video.headline)
                .font(.body)
                .lineLimit(3)
                .foregroundColor(.white)
                .frame(width: 320, alignment: .center)
        }
        .focusable() { focused in
            self.focused = focused
        }
        .cornerRadius(10)
        .shadow(radius: focused ? 7 : 0)
        .scaleEffect(focused ? 1.1 : 1)
        .animation(.easeInOut(duration: 0.2))
    }
}

struct VideoButtonView: View {
    let video: xVideo

    @State private var focused = false

    var body: some View {
        Button(action: {
            print ("action! " + self.video.headline)
        }) {
            ZStack {
                AimsImage(aimsUrl: video.tease!)
                    .frame(width: 400, height: 200)
                Text(video.headline)
                    .font(.body)
                    .lineLimit(3)
                    .foregroundColor(.white)
                    .frame(width: 320, alignment: .center)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onPlayPauseCommand {
            print("play/pause")
        }
    }
}


struct MenuGridView_Previews: PreviewProvider {
    static var previews: some View {
        MenuGridView()
    }
}
