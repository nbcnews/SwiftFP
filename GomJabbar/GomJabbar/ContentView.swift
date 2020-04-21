//
//  ContentView.swift
//  Copyright © 2020 NBC News Digital. All rights reserved.
//

import SwiftUI

enum Tab {
    case home
    case watch
    case listen
}

struct ContentView: View {
    @State private var selection = Tab.home
 
    var body: some View {
        TabView(selection: $selection) {
            BentoView()
            .tabItem {
                VStack {
                    if selection == .home {
                        Image("homeOn")
                    } else {
                        Image("homeOff")
                    }
                }
            }
            .tag(Tab.home)

            Text("Second View")
                .font(.title)
                .tabItem {
                    if selection == .watch {
                        Image("watchOn")
                    } else {
                        Image("watchOff")
                    }
                }
            .tag(Tab.watch)

            Text("wooff")
                .tabItem {
                    if selection == .listen {
                        Image("listenOn")
                    } else {
                        Image("listenOff")
                    }
                }

            .tag(Tab.listen)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
