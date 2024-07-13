//
//  PlantsCareApp.swift
//  PlantsCare
//
//  Created by Harshad Vaghela on 23/06/24.
//

import SwiftUI

@main
struct PlantsCareApp: App {
    @StateObject var store = Store()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                
        }
    }
}



