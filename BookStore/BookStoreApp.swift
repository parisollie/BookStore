//
//  BookStoreApp.swift
//  BookStore
//
//  Created by Paul Jaime Felix Flores on 27/07/24.
//


import SwiftUI

@main
struct BookStoreApp: App {
    //Vid 249
    @StateObject private var store = Store()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            //Propagamos nuestro store
                .environmentObject(store)
        }
    }
}
