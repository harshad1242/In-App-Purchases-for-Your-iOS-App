//
//  ContentView.swift
//  PlantsCare
//
//  Created by Harshad Vaghela on 23/06/24.
//
import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var store: Store
    
    @AppStorage(Persistence.consumablesCountKey) var consumableCount: Int = 0
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                Form {
                    Section(header: Text("You have")
                        .font(.headline)
                        .foregroundColor(.primary)) {
                            HStack(spacing: 20) {
                                ProductView(icon: "👤", quantity: "\(store.purchasedNonConsumables.count)")
                                ProductView(icon: "🍅", quantity: "\(consumableCount)")
                                ProductView(icon: "🪴", quantity: "\(store.purchasedSubscriptions.count)")
                              //  ProductView(icon: "👘", quantity: "\(store.purchasedNonConsumables.count)")
                                ProductView(icon: "🥻", quantity: "\(store.purchasedNonRenewables.count)")
                               // ProductView(icon: "🦸", quantity: "\(store.purchasedSubscriptions.count)")
                               // ProductView(icon: "🪱", quantity: "0")
                            }
                            .padding(.vertical)
                        }
                    
                    Section(header: Text("To buy")
                        .font(.headline)
                        .foregroundColor(.primary)) {
                            ForEach(store.products, id: \.self) { product in
                                HStack {
                                    Text(product.displayName)
                                        .font(.body)
                                    Spacer()
                                    Button(action: {
                                        Task {
                                            try await store.purchase(product)
                                        }
                                        
                                        // Here is going to be purchasing action...
                                    }) {
                                        Text(product.displayPrice)
                                            .font(.body)
                                            .padding(.horizontal)
                                            .padding(.vertical, 5)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    
                    Button("Restore purchases") {
                        Task {
                            try await store.restore()
                        }
                    }
                    NavigationLink("Support", destination: SupportView())
                }
                .navigationTitle("Store")
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

struct ProductView: View {
    var icon: String
    var quantity: String
    
    var body: some View {
        VStack {
            Text(icon)
                .font(.largeTitle)
            if !quantity.isEmpty {
                Text(quantity)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(Store())
    }
}
