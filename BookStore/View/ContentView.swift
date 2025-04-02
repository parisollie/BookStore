//
//  ContentView.swift
//  BookStore
//
//  Created by Paul Jaime Felix Flores on 27/07/24.
//

import SwiftUI
import StoreKit

struct ContentView: View {
    //Vid 250, traemos el environment object
    @EnvironmentObject private var store: Store
    
    var body: some View {
        //Vid 250
        NavigationView {
            ZStack {
                // 🔹 Fondo con degradado
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all) // Asegura que el degradado cubra toda la pantalla
                
                List(store.allBooks, id: \.self) { book in
                    //Vid 250 Hacemos un group para intercambiar el libro
                    Group {
                        if !book.lock {
                            NavigationLink(destination: BookView()) {
                                BookRowView(book: book) {}
                            }
                        } else {
                            BookRowView(book: book) {
                                //Vid 250, Llamamos las últimas funciones cuando se compró la compra
                                if let product = store.product(for: book.id) {
                                    store.purchaseProduct(product: product)
                                }
                            }
                        }
                    }
                    .listRowBackground(Color.clear) // 🔹 Hace que cada fila sea transparente
                }
                .scrollContentBackground(.hidden) // 🔹 Oculta el fondo de la lista, permitiendo que se vea el degradado
                .navigationTitle("Book Store")
                .toolbar {
                    //Vid 250, restauramos la compra
                    Button("Restaurar compra") {
                        store.restorePurchase()
                    }
                    // 🔹 Cambiamos el color de la letra a blanco
                    .foregroundColor(.white)
                }
            }
        }
    }
}



#Preview {
    // 1. Crear instancia mock de Store
    let mockStore = Store()
    
    // 2. Configurar datos de prueba (mock SKProduct)
    let mockProduct1 = {
        let p = SKProduct()
        p.setValue("com.paul.BookStore.BlTulip", forKey: "productIdentifier")
        p.setValue("Libro Bloqueado", forKey: "localizedTitle")
        p.setValue("Descripción libro bloqueado", forKey: "localizedDescription")
        p.setValue(NSDecimalNumber(string: "4.99"), forKey: "price")
        p.setValue(Locale.current, forKey: "priceLocale")
        return p
    }()
    
    let mockProduct2 = {
        let p = SKProduct()
        p.setValue("com.paul.BookStore.Paulihontas", forKey: "productIdentifier")
        p.setValue("Libro Desbloqueado", forKey: "localizedTitle")
        p.setValue("Descripción libro desbloqueado", forKey: "localizedDescription")
        p.setValue(NSDecimalNumber(string: "0.00"), forKey: "price")
        p.setValue(Locale.current, forKey: "priceLocale")
        return p
    }()
    
    // 3. Crear libros de prueba
    mockStore.allBooks = [
        Books(product: mockProduct1, lock: true),  // Libro bloqueado
        Books(product: mockProduct2, lock: false)  // Libro desbloqueado
    ]
    
    // 4. Crear la vista con el environment object
    let view = ContentView()
        .environmentObject(mockStore)
    
    return view
}
