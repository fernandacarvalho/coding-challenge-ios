//
//  Test+MoisesTesting.swift
//  world-peek-iosTests
//
//  Created by Fernanda Carvalho on 28/04/26.
//

import Testing
import Foundation

extension Test {
    class MoisesTesting {

        private struct LeakTracker {
            let objectType: String
            let sourceLocation: SourceLocation
            let ref: () -> AnyObject?
        }

        private var leakTrackers: [LeakTracker] = []

        deinit {
            if !Thread.isMainThread {
                DispatchQueue.main.sync {}
            }
            checkForMemoryLeaks()
        }

        func trackForMemoryLeaks(
            _ objects: [AnyObject],
            sourceLocation: SourceLocation = #_sourceLocation
        ) {
            for object in objects {
                weak var weakRef = object

                leakTrackers.append(LeakTracker(
                    objectType: String(describing: type(of: object)),
                    sourceLocation: sourceLocation,
                    ref: { weakRef }
                ))
            }
        }

        private func checkForMemoryLeaks() {
            for tracker in leakTrackers {
                if tracker.ref() != nil {
                    Issue.record(
                        "Memory leak detectado: \(tracker.objectType) não foi desalocado.",
                        sourceLocation: tracker.sourceLocation
                    )
                }
            }
        }
    }
}
