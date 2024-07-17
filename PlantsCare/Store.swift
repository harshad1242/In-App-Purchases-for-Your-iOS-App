//
//  Store.swift
//  PlantsCare
//
//  Created by Harshad Vaghela on 30/06/24.
//

import StoreKit
class Store: ObservableObject {
    
    private var productIDs = ["member","tomato","Tournament_Streaming","membership.elite","membership.pro"]
    
    @Published var entitlements = [Transaction]()
    
    @Published var purchasedSubscriptions = Set<Product>()
    @Published var purchasedNonConsumables = Set<Product>()
    @Published var purchasedNonRenewables = Set<Product>() // new line
    @Published var purchasedConsumables = [Product]()
    
    @Published var products = [Product]()
    var transacitonListener: Task<Void, Error>?
    var tournamentEndDate: Date = {
      var components = DateComponents()
      components.year = 2033
      components.month = 2
      components.day = 1
      return Calendar.current.date(from: components)!
    }()
    
    init() {
        transacitonListener = listenForTransactions()
        Task {
            await requestProducts()
            await updateCurrentEntitlements()
        }
    }
    
    // 6:
    @MainActor
    func requestProducts() async {
        do {
            // 7:
            products = try await Product.products(for: productIDs)
        } catch {
            // 8:
            print(error)
        }
    }
    
    @MainActor
    func purchase(_ product: Product) async throws -> Transaction?{
      // 1:
      let result = try await product.purchase()
      switch result {
        // 2:
        case .success(.verified(let transaction)):
          // 3:
          self.addPurchased(product)
            // 4:
          await transaction.finish()
          return transaction
        default:
          return nil
      }
    }
    
    @MainActor
     func restore() async throws {
      try await AppStore.sync()
    }
    
    func listenForTransactions() -> Task < Void, Error > {
      // 1:
      return Task.detached {
        // 2:
          for await result in Transaction.updates {
             await self.handle(transactionVerification: result)
        }
      }
    }
    
    @MainActor
    @discardableResult
    private func handle(transactionVerification result: VerificationResult<Transaction>) async -> Transaction? {
        switch result {
        case let .verified(transaction):
            guard let product = self.products.first(where: { $0.id == transaction.productID}) else { return transaction }
            
            guard !transaction.isUpgraded else { return nil }
            
            self.addPurchased(product)
            
            await transaction.finish()
            
            return transaction
        default:
            return nil
        }
    }
    
   /* @MainActor
    private func handle(transactionVerification result: VerificationResult <Transaction> ) async {
      switch result {
        case let.verified(transaction):
         
          guard let product = self.products.first(where: {
            $0.id == transaction.productID
          })
          else {
            return
          }
          guard !transaction.isUpgraded else { return  }
          self.addPurchased(product)
          
          await transaction.finish()
        default:
          return
      }
    }*/
    
    private func updateCurrentEntitlements() async {
        
        for await result in Transaction.currentEntitlements {
            if let transaction = await self.handle(transactionVerification: result) {
                entitlements.append(transaction)
            }
            
        }
    }
    
    private func addPurchased(_ product: Product) {
      switch product.type {
       case .consumable:
         purchasedConsumables.append(product)
          Persistence.increaseConsumablesCount()
      case .nonRenewable:
       if Date() <= tournamentEndDate {
       purchasedNonRenewables.insert(product)
      }
      case .autoRenewable:
       purchasedSubscriptions.insert(product)
          
       case .nonConsumable:
        purchasedNonConsumables.insert(product)
       default:
       return
      }
    }
}

import Foundation
class Persistence {
 static let consumablesCountKey = "consumablesCount"
 private static let storage = UserDefaults()
    
 static func increaseConsumablesCount() {
    let currentValue = storage.integer(forKey: Persistence.consumablesCountKey)
        storage.set(currentValue + 1, forKey: Persistence.consumablesCountKey)
    }
}
