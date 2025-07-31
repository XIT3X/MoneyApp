//
//  MoneyProApp.swift
//  Money Pro
//
//  Created by Marco Comizzoli on 21/07/25.
//

import SwiftUI

@main
struct MoneyProApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
