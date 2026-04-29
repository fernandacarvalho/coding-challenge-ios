//
//  NavigationGate.swift
//  world-peek-ios
//
//  Created by Fernanda Carvalho on 28/04/26.
//

import Foundation

actor NavigationGate {

    private var isNavigating = false

    func tryEnter() -> Bool {
        guard !isNavigating else {
            return false
        }

        isNavigating = true
        return true
    }

    func leave() {
        isNavigating = false
    }
}
