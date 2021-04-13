//
//  ContentView.swift
//  tvOS-Light
//
//  Created by Denis on 3/18/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject
    var main = Main()

    var body: some View {
        ZStack {
            Text("Hello, world!")
                .padding()

            Optional(main.image) { image in
                SwiftUI.Image(uiImage: image)
                    //.background(Color.clear)
                    .frame(width: 1920, height: 1080)
                    //.blendMode(BlendMode.normal)
            }.frame(width: 1920, height: 1080)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
