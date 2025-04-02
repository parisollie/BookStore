//
//  Store.swift
//  BookStore
//
//  Created by Paul Jaime Felix Flores on 27/07/24.
//

import Foundation
import StoreKit

//paso 1.11 Hacemos un Alias,para poder ocuparlo en otros lados
typealias FetchCompleteHandler = (([SKProduct]) -> Void)
typealias PurchasesCompleteHandler = ((SKPaymentTransaction) -> Void)

//V-246,Paso 1.5,hacemos el observaer object
class Store: NSObject, ObservableObject {
    
    //Paso 1.6
    @Published var allBooks = [Books]()
    
    //Paso 1.7,Mandamosa llamar nuestro libro en la parte de configuracion
    private let allIdentifiers = Set([
        "com.paul.BookStore.BlTulip",
        "com.paul.BookStore.Paulihontas",
        "com.paul.BookStore.HassiMen",
        "com.paul.BookStore.FullAcc"
        
    ])
    
    //Paso 1.8,esto sera igual a un array de strings
    private var completedPurchases = [String](){
        //didset con este  vemos el cambio de las variables y sirve para desbloquear el producto.
        didSet {
            //[weak self] in, todo lo que este dentro de nuestro codigo
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                //buscamos los indices que tiene el array
                for index in self.allBooks.indices {
                    //entramos al que es el booleano lock,al momento de que hace la compra del producto
                    self.allBooks[index].lock = !self.completedPurchases.contains(self.allBooks[index].id)
                }
            }
        }
    }
    
    //Paso 1.9
    private var productsRequest: SKProductsRequest?
    private var fetchedProductos = [SKProduct]()
    
    //Paso 1.10 ,mandamosa a llamar los alias que estan hasta arriba
    private var fetchCompleteHandler : FetchCompleteHandler?
    private var purchasesCompleteHandler : PurchasesCompleteHandler?
    

    //V-249,paso 1.14
    override init(){
        super.init()
        //Paso 1.18
        startObservingPayment()
        
        fetchProducts { products in
            self.allBooks = products.map { Books(product: $0) }
        }
    }
    //Paso 1.15, observamos si ya se hizo el pago
    private func startObservingPayment() {
        SKPaymentQueue.default().add(self)
    }
    //Paso 1.16
    private func fetchProducts(_ completion: @escaping FetchCompleteHandler){
        guard self.productsRequest == nil else { return }
        fetchCompleteHandler = completion
        //nos pide un set de strings que es el que hicimos arriba allIdentifiers
        productsRequest = SKProductsRequest(productIdentifiers: allIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
    //Paso 1.17
    private func buy(_ product: SKProduct, completion: @escaping PurchasesCompleteHandler){
        purchasesCompleteHandler = completion
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    
}
//V-247,Paso 1.12 hacemos nuestros delegados
extension Store: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        //detectamos que nuestros productos esten correctos, en cuanto a los identificadores
        let loadedProducts = response.products
        let invalidProductos = response.invalidProductIdentifiers
        
        //hacemos un guard inverso, si esta vacio , los productos no se cargaron
        guard !loadedProducts.isEmpty else{
            print("No se pueden cargar los productos")
            if !invalidProductos.isEmpty {
                print("productos invalidos encontrados: \(invalidProductos)")
            }
            productsRequest = nil
            return
        }
        //ponemos nuestros productos cargados
        fetchedProductos = loadedProducts
        DispatchQueue.main.async {
            self.fetchCompleteHandler?(loadedProducts)
            self.fetchCompleteHandler = nil
            self.productsRequest = nil
        }
        
    }
    
}

//V-248,paso 1.13 extension para saber, como va la compra ?
extension Store : SKPaymentTransactionObserver {
    //[SKPaymentTransaction] array donde estan los pagos
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        //hacemos un For porque tenemos varios productos
        for transaction in transactions {
            var finishTransaction = false
            //swicth para las transacciones
            switch transaction.transactionState {
            //para restaurar la compra
            case .purchased, .restored:
                completedPurchases.append(transaction.payment.productIdentifier)
                finishTransaction = true
            case .failed:
                finishTransaction = true
            //Caso diferido
            case .deferred, .purchasing:
                break
            @unknown default:
                break
            }
            //Si es true
            if finishTransaction {
                //Ponemos la transacción que estamos haciendo
                SKPaymentQueue.default().finishTransaction(transaction)
                DispatchQueue.main.async {
                    self.purchasesCompleteHandler?(transaction)
                    self.purchasesCompleteHandler = nil
                }
            }
        }
    }
}

//paso 1.19
extension Store {
    //función para los identficadores
    func product(for identifier: String) -> SKProduct? {
        return fetchedProductos.first(where: { $0.productIdentifier == identifier })
    }
    
    func purchaseProduct(product: SKProduct){
        startObservingPayment()
        buy(product) { _ in }
    }
    //producto para restaurar la compra es muy importante para que pueda restaurar sus compras
    func restorePurchase(){
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
}







