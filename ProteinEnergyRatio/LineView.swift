//
//  LineView.swift
//  PERatio
//
//  Created by Mike Gopsill on 22/05/2020.
//  Copyright © 2020 mgopsill. All rights reserved.
//

import SwiftUI

struct LineView: View {
    let text: String
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Text(text)
                    .padding([.bottom], 16)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
            }
            
            GeometryReader { geometry in
                Path { path in
                    path.move(to: CGPoint(x: 3, y: geometry.size.height / 2))
                    path.addLine(to: CGPoint(x: geometry.size.width - 40, y: geometry.size.height / 2))
                }
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, lineCap: .round))
            }
        }
    }
}

struct LineView_Previews: PreviewProvider {
    static var previews: some View {
        LineView(text: "P:E = 2.0")
    }
}
