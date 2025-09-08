//
//  frontendApp.swift
//  frontend
//
//  Created by Marcel Dietl on 08.09.25.
//

import SwiftUI

@main
struct frontendApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .preferredColorScheme(.dark)
        }
    }
}
