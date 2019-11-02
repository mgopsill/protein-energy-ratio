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
        for view in views {
            addArrangedSubview(view)
            addArrangedSubview(SeperatorView())
        }
    }
}


class SeperatorView: UIView {
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: frame)
        backgroundColor = .lightGray
        heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
