//
//  MacroSliderContainerView.swift
//  PERatio
//
//  Created by Mike Gopsill on 18/05/2020.
//  Copyright © 2020 mgopsill. All rights reserved.
//

import SwiftUI

struct MacroSliderContainerView: View {
    @Binding var gramsOfProtein: Float
    @Binding var gramsOfFat: Float
    @Binding var gramsOfCarb: Float
    @Binding var gramsOfFiber: Float

    let proteinText = "Protein (grams):"
    let fatText = "Fat (grams):"
    let carbText = "Carbohydrate (grams):"
    let fiberText = "Fiber (grams):"

    var body: some View {
        VStack {
            SliderView(title: proteinText, value: $gramsOfProtein)
            Divider()
            SliderView(title: fatText, value: $gramsOfFat)
            Divider()
            SliderView(title: carbText, value: $gramsOfCarb)
            Divider()
            SliderView(title: fiberText, value: $gramsOfFiber)
        }
    }    
}

struct MacroSliderContainerView_Previews: PreviewProvider {
    static var previews: some View {
        return MacroSliderContainerView(gramsOfProtein: .constant(5.0),
                                        gramsOfFat: .constant(5.0),
                                        gramsOfCarb: .constant(5.0),
                                        gramsOfFiber: .constant(5.0))
    }
}
