//
//  PlayerView.swift
//  Copyright © 2020 NBC News Digital. All rights reserved.
//

import SwiftUI
import AVFoundation

struct AVPlayerView: UIViewRepresentable {
    let url: URL

    func updateUIView(_ uiView: UIView, context: Context) {
    }

    func makeUIView(context: Context) -> UIView {
        return AVPlayerUIView(self.url)
    }

}

class AVPlayerUIView: UIView {
    init(_ url: URL) {
        super.init(frame: .zero)

        playerLayer.videoGravity = .resizeAspectFill

//        let player = AVPlayer(url: url)
//        player.isMuted = true
//        playerLayer.player = player
//        player.play()

        // setup looping playback
        let player = AVQueuePlayer()
        player.isMuted = true
        playerLayer.player = player
        playerLooper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(url: url)) //AVPlayerItem(url: url))
        player.play()
    }

    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    private var playerLooper: AVPlayerLooper?

    private var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
