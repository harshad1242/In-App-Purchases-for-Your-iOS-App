//
//  SupportView.swift
//  PlantsCare
//
//  Created by Harshad Vaghela on 23/06/24.
//

import SwiftUI
import StoreKit

struct SupportView: View {
    
    @State var isManageSubscriptionsSheetPresented: Bool = false
    
    @State var isOfferCodeRedepmtionPresented: Bool = false
    
    var body: some View {
      
            Form {
                Button("Subscription management") {
                    showManageSubscriptionSheet()
                }
                Button("Redeem code") {
                    showOfferCodeRedemption()
                }
                NavigationLink("Request a refund") {
                    RefundView()
                }
            }
            .manageSubscriptionsSheet(isPresented: $isManageSubscriptionsSheetPresented)
        
    }
    
    func showManageSubscriptionSheet() {
        isManageSubscriptionsSheetPresented = true
    }
    
    func showOfferCodeRedemption() {
        isOfferCodeRedepmtionPresented = true
    }
    
}

struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        SupportView()
    }
}
