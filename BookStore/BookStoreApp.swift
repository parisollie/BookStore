//
//  BookStoreApp.swift
//  BookStore
//
//  Created by Paul Jaime Felix Flores on 27/07/24.
//


import SwiftUI

@main
struct BookStoreApp: App {
    //Paso 1.20
    @StateObject private var store = Store()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                //Paso 1.21,Propagamos nuestro store
                .environmentObject(store)
        }
    }
}
