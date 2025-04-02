//
//  Books.swift
//  BookStore
//
//  Created by Paul Jaime Felix Flores on 27/07/24.
//


import Foundation
import StoreKit
//Vid 245,Swift File
//Creamos nuestra estructura ,para poder ver nuestro catalogo
struct Books: Hashable {
    let id : String
    let title : String
    let description : String
    var lock : Bool
    //Opcional porque puede haber productos gratuitos
    var price : String?
    let locale : Locale
    
    //Vid 245 , precio del string ,para cambiar el formato
    lazy var formatter : NumberFormatter = {
        let nf = NumberFormatter()
        //Vid 245,ponemos el estilo que le queremos dar , osea el estilo moneda
        nf.numberStyle = .currency
        nf.locale = locale
        return nf
    }()
    //Vid 245, hacemos nuestro contrustor y ponemos nuestro parametro Product
    //que viene de SKProduct atorkit product de donde tenemos los datos
    init(product: SKProduct, lock: Bool = true){
        
        self.id = product.productIdentifier
        self.title = product.localizedTitle
        self.description = product.localizedDescription
        self.lock = lock
        self.locale = product.priceLocale
        //Vid 245, formatoa que nos salga en moneda 
        if lock {
            self.price = formatter.string(from: product.price)
        }
        
    }
    
}


