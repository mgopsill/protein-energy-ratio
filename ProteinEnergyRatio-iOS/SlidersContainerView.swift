//
//  SlidersContainerView.swift
//  ProteinEnergyRatio-iOS
//
//  Created by Mike Gopsill on 01/11/2019.
//  Copyright © 2019 mgopsill. All rights reserved.
//

import Foundation
import SnapKit

class SlidersContainerView: UIStackView {
    
    private let views: [UIView]
    
    init(views: [UIView]) {
        self.views = views
        super.init(frame: CGRect.zero)
        axis = .vertical
        spacing = 20
        setupViews()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        for (index, view) in views.enumerated() {
            addArrangedSubview(view)
            if index == views.count-1 {
                addArrangedSubview(SeperatorView(backgroundColor: .clear))
            } else {
                addArrangedSubview(SeperatorView())
            }
        }
    }
}


class SeperatorView: UIView {
    init(frame: CGRect = CGRect.zero, backgroundColor: UIColor = .lightGray) {
        super.init(frame: frame)
        self.backgroundColor = backgroundColor
        heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
