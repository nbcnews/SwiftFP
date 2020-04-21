//
//  Model.swift
//  Copyright © 2020 NBC News Digital. All rights reserved.
//

import SwiftUI
import Combine

class Model: ObservableObject {
    private let  m = MenuLoader()
    @Published var model: Channels?
    var loadTimer: Cancellable?
    var timer: Timer!

    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.load()
        }

        load()
    }

    func load() {
        loadTimer = m.load()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(" Das Error! Nein!", error)
                }
            }, receiveValue: { model in
                self.model = model
            })
    }
}
