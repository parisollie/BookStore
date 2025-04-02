//
//  BookRowView.swift
//  BookStore
//
//  Created by Paul F on 01/04/25.
//

import SwiftUI
import StoreKit

struct BookRowView: View {
    let book: Books
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(book.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            Spacer()
            if let price = book.price, book.lock {
                Button(action: action) {
                    Text(price)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
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






