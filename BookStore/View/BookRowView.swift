//
//  BookRowView.swift
//  BookStore
//
//  Created by Paul F on 01/04/25.
//

import SwiftUI
import StoreKit

struct BookRowView: View {
    let book : Books
    //Vid 250,accion para nuesto boton
    let action : () -> Void
    
    var body: some View{
        HStack{
            VStack(alignment: .leading){
                Text(book.title)
                    .font(.title)
                    .bold()
                Text(book.description)
                    .font(.subheadline)
                    .bold()
            }
            Spacer()
            if let price = book.price, book.lock {
                Button(action: action){
                    Text(price)
                }
            }
        }
    }
}


#Preview {
    // Simulamos un SKProduct para la preview (parámetros obligatorios)
    let mockProduct = SKProduct()
    mockProduct.setValue("com.paul.BookStore.BlTulip", forKey: "productIdentifier")
    mockProduct.setValue("El Tulipán Negro", forKey: "localizedTitle")
    mockProduct.setValue("Una aventura histórica", forKey: "localizedDescription")
    mockProduct.setValue(NSDecimalNumber(string: "1.99"), forKey: "price")
    mockProduct.setValue(Locale(identifier: "es_MX"), forKey: "priceLocale")
    
    // Creamos el Book con el constructor real
    let sampleBook = Books(product: mockProduct, lock: true)
    
    return BookRowView(
        book: sampleBook,
        action: { print("Botón de compra pulsado") }
    )
    .padding()
}






