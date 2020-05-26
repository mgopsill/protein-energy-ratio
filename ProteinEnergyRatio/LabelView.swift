//
//  LabelView.swift
//  PERatio
//
//  Created by Mike Gopsill on 22/05/2020.
//  Copyright © 2020 mgopsill. All rights reserved.
//

import SwiftUI

struct LabelView: View {
    let figure: String
    let label: String
    let emoticon: String
    
    var body: some View {
        HStack {
            Text(label).fontWeight(.bold)
            Spacer()
            Text("\(figure)  \(emoticon)")
        }
        .padding([.leading, .trailing])
    }
}

struct LabelView_Previews: PreviewProvider {
    static var previews: some View {
        LabelView(figure: "2.0", label: "Label", emoticon: "🤞")
    }
}
