//
//  TwoLabels.swift
//  Pods-ProteinEnergyRatio
//
//  Created by Mike Gopsill on 02/11/2019.
//

import SnapKit
import UIKit

class TwoLabels: UIView {
    
    private let leftLabel: UILabel
    private let divider = UIView()
    private let rightLabel: UILabel
    
    init(leftLabel: UILabel, rightLabel: UILabel) {
        self.leftLabel = leftLabel
        self.rightLabel = rightLabel
        super.init(frame: CGRect.zero)

        self.addSubview(leftLabel)
        self.addSubview(divider)
        self.addSubview(rightLabel)
        
        divider.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview().offset(40)
            make.width.equalTo(8)
        }
        
        leftLabel.numberOfLines = 0
        leftLabel.textAlignment = .right
        leftLabel.snp.makeConstraints { make in
            make.top.bottom.leading.equalTo(self)
            make.trailing.equalTo(divider.snp.leading)
        }
        
        rightLabel.numberOfLines = 0
        rightLabel.snp.makeConstraints { make in
            make.top.bottom.trailing.equalTo(self)
            make.leading.equalTo(divider.snp.trailing)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
