//
//  BentoView.swift
//  Copyright © 2020 NBC News Digital. All rights reserved.
//

import SwiftUI

struct BentoView : View {
    @EnvironmentObject var d: Model

    var body: some View {
        if let modules = d.model?.modules {
            return AnyView(BentoScrollView(modules))
        } else {
            return AnyView(Text("Loading..."))
        }
    }
}

struct BentoScrollView: View {
    var mods: [Module]
    init(_ mods: [Module]) {
        self.mods = mods
    }

    var body: some View {
        ScrollView {
            ForEach(mods) { module in
                ModuleView(module).id(module.id)
            }
        }
    }
}

struct ModuleView: View, Codable {
    let module: Module

    init(_ mod: Module) {
        self.module = mod
    }

    var body: some View {
        switch module {
        case .section(let section):
            return AnyView(SectionView(section))
        case .hero(let hero):
            return AnyView(HeroView(hero))
        case .promo(let promo):
            return AnyView(PromoView(promo))
        case .videos(let videos):
            return AnyView(VideosView(videos))
        case .channels(let channels):
            return AnyView(ChannelsView(channels))
        default:
            return AnyView(NopeView())
        }
    }
}

struct PromoView: View {
    private let model: PromoModule
    init(_ model: PromoModule) {
        self.model = model
    }

    var body: some View {
        Text("Promo \(model.header ?? "")")
    }
}

struct VideosView: View {
    private let model: VideosModule
    init(_ model: VideosModule) {
        self.model = model
    }

    var body: some View {
        Text("Videos")
    }
}

struct ChannelsView: View {
    private let model: ChannelsModule
    init(_ model: ChannelsModule) {
        self.model = model
    }

    var body: some View {
        Text("Channels")
    }
}

struct NopeView: View {
    var body: some View {
        Text("Unsupported Module")
    }
}
