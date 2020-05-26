//
//  LabelsView.swift
//  PERatio
//
//  Created by Mike Gopsill on 18/05/2020.
//  Copyright © 2020 mgopsill. All rights reserved.
//

import SwiftUI

struct LabelsView: View {
    let calories: Int
    let proteinPercent: Int
    let fatPercent: Int
    let carbPercent: Int
    let proteinEnergy: Float
    let vector: Float
    
    var body: some View {
        VStack(spacing: 15.0) {
            LabelView(figure: String(calories), label: "Calories:", emoticon: "🍽")
            LabelView(figure: "\(proteinPercent)%", label: "Protein percent:", emoticon: "💪")
            LabelView(figure: "\(fatPercent)%", label: "Fat percent:", emoticon: "🧈")
            LabelView(figure: "\(carbPercent)%", label: "Carb percent:", emoticon: "🍚")
            LabelView(figure: "\(numberFormatter.string(for: proteinEnergy))", label: "Protein:Energy:", emoticon: "📈")
            LabelView(figure: "\(numberFormatter.string(for: vector))", label: "Nutrional Vector °:", emoticon: "🧭")
        }
        .padding()
        .padding([.top, .bottom], 10.0)
        .background(Color("customLabelsBackground"))
        .cornerRadius(20)
    }
}

struct LabelsView_Previews: PreviewProvider {
    static var previews: some View {
        LabelsView(calories: 4,
                   proteinPercent: 3,
                   fatPercent: 2,
                   carbPercent: 1,
                   proteinEnergy: 2.0,
                   vector: 2.0)
    }
}

struct ContentView_Previews_2: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
