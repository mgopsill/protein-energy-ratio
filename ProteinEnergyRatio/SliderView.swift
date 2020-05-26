//
//  SliderView.swift
//  PERatio
//
//  Created by Mike Gopsill on 17/05/2020.
//  Copyright © 2020 mgopsill. All rights reserved.
//

import Combine
import SwiftUI

struct SliderView: View {
    let title: String
    @Binding var value: Float
    
    private let range: ClosedRange<Float> = 0.0...50.0
    @State private var borderThickness: CGFloat = 0
    @State private var backgroundColor: Color = Color("customBackgroundColor")
    
    var body: some View {
        VStack(alignment:.leading) {
            Text(title)
            HStack {
                Slider(value: $value, in: range, step: 0.1)
                CustomTextField(placeHolder: "0.0", value: $value, onEditChanged: { bool in
                    withAnimation {
                        if bool {
                            self.borderThickness = 1
                            self.backgroundColor = Color("customTextFieldHighlight")
                        } else {
                            self.borderThickness = 0
                            self.backgroundColor = Color("customBackgroundColor")
                        }
                    }
                })
                    .padding(6)
                    .background(backgroundColor)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .frame(width: 60)
                    .cornerRadius(10.0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10.0)
                            .stroke(Color.blue, lineWidth: borderThickness)
                )
            }
        }.padding()
    }
}

struct SliderView_Previews: PreviewProvider {
    static var previews: some View {
        SliderView(title: "Title", value: .constant(5.0))
    }
}

extension Float {
    func round(to places: Float) -> Float {
        return ((self * 10).rounded(.toNearestOrEven) / 10)
    }
}
