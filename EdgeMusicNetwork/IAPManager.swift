//
//  IAPManager.swift
//  Jack
//
//  Created by Andrey Chernukha on 9/29/15.
//  Copyright © 2015 Brian Parker. All rights reserved.
//

import UIKit
import StoreKit


//let kBuyBasicFreeMembership : String = "com.edgemusic.freesubscriptionid"
let kBuyPremiumMembership : String = "com.music.item"
let kBuyAutoPremiumMembership : String = "com.automusic.item"


let kIdentifierKey : String = "identifier"

class IAPManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver
{
    var products : [SKProduct]? = nil
    
     static var instance : IAPManager = IAPManager()
   func initialize(){
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        
        self.getProducts()
   }
   func getProducts()
   {
    
    if SKPaymentQueue.canMakePayments(){
        let productIdentifiers : NSSet = NSSet(objects:kBuyAutoPremiumMembership)
        let productsRequest : SKProductsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
   }
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse)
    {
       if response.invalidProductIdentifiers.count > 0
       {
//          return
          //abort()
        NSLog("Log")
       }
        
       products = response.products

    }
    
    func buyProduct(index : Int )
    {
        let payment : SKPayment = SKPayment(product: (products![index]))
        SKPaymentQueue.defaultQueue().addPayment(payment)
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    func restoreProduct(){
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
    {
        for transaction in transactions
        {
            switch transaction.transactionState
            {
              case .Purchased:
                  productPurchased("Purchased");
                  SKPaymentQueue.defaultQueue().finishTransaction(transaction)
              case .Failed:
                  productPurchased("Failed") ;
                  SKPaymentQueue.defaultQueue().finishTransaction(transaction)
              case .Restored: print("Restored") ;
                  productPurchased("Restored")
                  SKPaymentQueue.defaultQueue().finishTransaction(transaction)
              case .Purchasing:
                print("Purchasing")
              case .Deferred:
                productPurchased("Deferred")
                print("Deferred")
            }
        }
        
    }
    
    func productPurchased(purchaseType : String)
    {
        let useInfo:NSDictionary = NSDictionary(object: purchaseType, forKey: "Type")
        
        let notification = NSNotification(name: "ItemPurchaseNotification", object: self, userInfo: useInfo as [NSObject : AnyObject])
        NSNotificationCenter.defaultCenter().postNotification(notification)
        
    }
    
    func transactionFailed(error : NSError?)
    {
        let message : String = error == nil ? "Unknown error" : error!.localizedDescription
        let alert : UIAlertView = UIAlertView(title: "Transaction failed", message: message, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
}
