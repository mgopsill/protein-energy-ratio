//
//  LabelsView.swift
//  ProteinEnergyRatio
//
//  Created by Mike Gopsill on 02/11/2019.
//

import SnapKit
import UIKit

final class LabelsView: UIStackView {
    
    private let leftLabel = UILabel()
    private let rightLabel = UILabel()

    private let centralLabel: UILabel
    
    init(leftText: String, rightText: String, centralLabel: UILabel) {
        leftLabel.text = leftText
        leftLabel.font = UIFont.boldSystemFont(ofSize: 16)
        rightLabel.text = rightText
        centralLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        centralLabel.textAlignment = .left
        rightLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        self.centralLabel = centralLabel
        
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        distribution = .fill
        translatesAutoresizingMaskIntoConstraints = false
        spacing = UIStackView.spacingUseSystem
        isLayoutMarginsRelativeArrangement = true
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        addArrangedSubview(leftLabel)
        addArrangedSubview(centralLabel)
        addArrangedSubview(rightLabel)
    }
}   
