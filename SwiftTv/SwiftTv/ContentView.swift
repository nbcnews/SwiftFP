//
//  ContentView.swift
//  SwiftTv
//
//  Created by Denis on 3/27/20.
//  Copyright © 2020 NBC News Digital. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = 0
    @State private var menuVisible = true

    var body: some View {
        ZStack {
            AVPlayerView(url: URL(string: "https://link.theplatform.com/s/rksNhC/gqnA9UQHehXi?mbr=true&manifest=m3u&metafile=none")!)
                .frame(width: 1920, height: 1080)
                .blur(radius: menuVisible ? 7 : 0)
                .focusable(!self.menuVisible)
                .onExitCommand(perform: {
                    print ("aha!")
                })

            if menuVisible {
                Color(hue: 0, saturation: 0, brightness: 0.9, opacity: 0.5)

                TabView(selection: $selection) {
                    MenuGridView()
                        .font(.title)
                        .tabItem {
                            HStack {
                                Image("first")
                                Text("News")
                            }
                        }
                        .tag(0)
                    Text("Today View")
                        .font(.title)
                        .tabItem {
                            HStack {
                                Image("second")
                                Text("Today")
                            }
                        }
                        .tag(1)
                    Text("Msnbc View")
                    .font(.title)
                    .tabItem {
                        HStack {
                            Image("second")
                            Text("Msnbc")
                        }
                    }
                    .tag(2)
                    Text("Search View")
                    .font(.title)
                    .tabItem {
                        HStack {
                            Image("second")
                            Text("Search")
                        }
                    }
                    .tag(3)
                    Text("Settings View")
                    .font(.title)
                    .tabItem {
                        HStack {
                            Image("second")
                            Text("Settings")
                        }
                    }
                    .tag(4)
                }
                .padding(20)
            }
        }
        .focusable()
        .onExitCommand(perform: {
            self.menuVisible.toggle()
        })
        //.frame(width: 1920, height: 1080)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
