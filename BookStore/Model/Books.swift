//
//  Books.swift
//  BookStore
//
//  Created by Paul Jaime Felix Flores on 27/07/24.
//


import Foundation
import StoreKit

//V-245,paso 1.0,Creamos nuestra estructura ,para poder ver nuestro catalogo
struct Books: Hashable {
    
    let id : String
    let title : String
    let description : String
    var lock : Bool
    //Opcional porque puede haber productos gratuitos
    var price : String?
    let locale : Locale
    
    //Paso 1.3,para el precio del string y para cambiar el formato
    lazy var formatter : NumberFormatter = {
        let nf = NumberFormatter()
        //ponemos el estilo que le queremos dar , osea el estilo moneda
        nf.numberStyle = .currency
        nf.locale = locale
        return nf
    }()
    
    //Paso 1.2, hacemos nuestro constructor y ponemos nuestro parametro Product
    //que viene de SKProduct storekit product de donde tenemos los datos
    init(product: SKProduct, lock: Bool = true){
        
        self.id = product.productIdentifier
        self.title = product.localizedTitle
        self.description = product.localizedDescription
        self.lock = lock
        self.locale = product.priceLocale
        //Paso 1.4,formato para  que nos salga en moneda
        if lock {
            self.price = formatter.string(from: product.price)
        }
        
    }
    
}


