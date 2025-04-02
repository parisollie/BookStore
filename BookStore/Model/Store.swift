//
//  Store.swift
//  BookStore
//
//  Created by Paul Jaime Felix Flores on 27/07/24.
//


//Vid 246, Swift File

import Foundation
import StoreKit
//Vid 246, Hacemos un Alias
typealias FetchCompleteHandler = (([SKProduct]) -> Void)
typealias PurchasesCompleteHandler = ((SKPaymentTransaction) -> Void)

//Vid 246,hacemos el observaer object
class Store: NSObject, ObservableObject {
    
    @Published var allBooks = [Books]()
    //Mandamosa llamar nuestro libro en la parte de configuracion
    private let allIdentifiers = Set([
        "com.paul.BookStore.BlTulip",
        "com.paul.BookStore.Paulihontas",
        "com.paul.BookStore.HassiMen",
        "com.paul.BookStore.FullAcc"
        
    ])
    //Vid 246,esto sera igual a un array de strings
    private var completedPurchases = [String](){
        //Vid 246,didset vemos el cambio de las variables y sirve para desbloquear el producto
        didSet {
            //Vid 246 [weak self] in, todo lo que este dentro de nuestro codigo
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                //Vid 246, buscamos los indices que tiene el array
                for index in self.allBooks.indices {
                    //Vid 246, entramos al que es el booleano lock,al momento de que hace la compa el producto
                    self.allBooks[index].lock = !self.completedPurchases.contains(self.allBooks[index].id)
                }
            }
        }
    }
    
    //Vid 246
    private var productsRequest: SKProductsRequest?
    private var fetchedProductos = [SKProduct]()
    //Vid 246,mandamosa a llamar los alias que estan hasta arriba
    private var fetchCompleteHandler : FetchCompleteHandler?
    private var purchasesCompleteHandler : PurchasesCompleteHandler?
    

    //Vid 249
    override init(){
        super.init()
        startObservingPayment()
        //Vid 249
        fetchProducts { products in
            self.allBooks = products.map { Books(product: $0) }
        }
    }
    //Vid 249, observamos si ya se hizo el pago
    private func startObservingPayment() {
        SKPaymentQueue.default().add(self)
    }
    //Vid 249,
    private func fetchProducts(_ completion: @escaping FetchCompleteHandler){
        guard self.productsRequest == nil else { return }
        fetchCompleteHandler = completion
        //Vid 249, nos pide un set de strings que es el que hicimos arriba allIdentifiers
        productsRequest = SKProductsRequest(productIdentifiers: allIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
    //Vid 249,
    private func buy(_ product: SKProduct, completion: @escaping PurchasesCompleteHandler){
        purchasesCompleteHandler = completion
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    
}
//Vid 247, hacemos nuestros delegados
extension Store: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        //Vid 247, detectamos que nuestros productos esten correctos, en cuanto a los identificadores
        let loadedProducts = response.products
        let invalidProductos = response.invalidProductIdentifiers
        //Vid 247, hacemos un guard inverso, si esta vacio , los productos no se cargaron
        guard !loadedProducts.isEmpty else{
            print("No se pueden cargar los productos")
            if !invalidProductos.isEmpty {
                print("productos invalidos encontrados: \(invalidProductos)")
            }
            productsRequest = nil
            return
        }
        //Vid 247,ponemos nuestros productos cargados
        fetchedProductos = loadedProducts
        DispatchQueue.main.async {
            self.fetchCompleteHandler?(loadedProducts)
            self.fetchCompleteHandler = nil
            self.productsRequest = nil
        }
        
    }
    
}
//Vid 248, extension para saber, como va la compra ?
extension Store : SKPaymentTransactionObserver {
    //Vid 248, [SKPaymentTransaction] array donde estan los pagos
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        //Vid 248, hacemos un For porque tenemos varios productos
        for transaction in transactions {
            var finishTransaction = false
            //Vid 248, swicth para las transacciones
            switch transaction.transactionState {
            //Vid 248 ,para restaurar la compra
            case .purchased, .restored:
                completedPurchases.append(transaction.payment.productIdentifier)
                finishTransaction = true
            case .failed:
                finishTransaction = true
            //Vid 248 Caso diferido
            case .deferred, .purchasing:
                break
            @unknown default:
                break
            }
            //Vid 248
            if finishTransaction {
                //Ponemos la transaccion que estamos haciendo 
                SKPaymentQueue.default().finishTransaction(transaction)
                DispatchQueue.main.async {
                    self.purchasesCompleteHandler?(transaction)
                    self.purchasesCompleteHandler = nil
                }
            }
            
        }
        
    }
    
}

//Vid 249
extension Store {
    //Vid 249, funcion para los identficadores 
    func product(for identifier: String) -> SKProduct? {
        return fetchedProductos.first(where: { $0.productIdentifier == identifier })
    }
    
    func purchaseProduct(product: SKProduct){
        startObservingPayment()
        buy(product) { _ in }
    }
    //Vid 249, producto para restaurar la compra 
    func restorePurchase(){
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
}






