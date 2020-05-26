//
//  GraphView.swift
//  PERatio
//
//  Created by Mike Gopsill on 22/05/2020.
//  Copyright © 2020 mgopsill. All rights reserved.
//

import SwiftUI

struct GraphView: View {
    let degrees: Float
    let ratio: Float
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Text("Protein")
                    .fontWeight(.light)
                    .foregroundColor(.gray)
                    .font(Font.footnote)
                    .rotationEffect(Angle(degrees: 270))
                    .offset(x: -40, y: geometry.size.height / 2)
                LineView(text: "P:E = \(numberFormatter.string(for: self.ratio))")
                    .offset(x: 0, y: geometry.size.height / 2)
                    .rotationEffect(Angle(degrees: Double(0 - self.degrees)), anchor: .bottomLeading)
                Text("Energy")
                    .fontWeight(.light)
                    .foregroundColor(.gray)
                    .font(Font.footnote)
                    .offset(x: geometry.size.width / 2.5, y: geometry.size.height + 20)
            }
        }
        .background(Image("graphBackGround").resizable().cornerRadius(10.0))
        .scaledToFit()
        .padding(40.0)
    }
}


struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        GraphView(degrees: 20, ratio: 1.2)
    }
}
