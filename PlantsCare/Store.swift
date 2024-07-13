//
//  Store.swift
//  PlantsCare
//
//  Created by Harshad Vaghela on 30/06/24.
//

import StoreKit
class Store: ObservableObject {
    
    private var productIDs = ["member"]
    @Published var purchasedNonConsumables = Set<Product>()
    @Published var products = [Product]()
    var transacitonListener: Task<Void, Error>?
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
      let result =
        try await product.purchase()
      switch result {
        // 2:
        case .success(.verified(let transaction)):
          // 3:
          purchasedNonConsumables.insert(product)
            // 4:
          await transaction.finish()
          return transaction
        default:
          return nil
      }
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
    private func handle(transactionVerification result: VerificationResult <Transaction> ) async {
      switch result {
        case let.verified(transaction):
          guard
          let product = self.products.first(where: {
            $0.id == transaction.productID
          })
          else {
            return
          }
          self.purchasedNonConsumables.insert(product)
          await transaction.finish()
        default:
          return
      }
    }
    
    private func updateCurrentEntitlements() async {
      for await result in Transaction.currentEntitlements {
        await self.handle(transactionVerification: result)
            }
        }
}
