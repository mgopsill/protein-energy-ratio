//
//  GraphView.swift
//  Pods-ProteinEnergyRatio
//
//  Created by Mike Gopsill on 29/10/2019.
//

import RxRelay
import RxSwift
import UIKit

class GraphView: UIView {
    
    private let bag = DisposeBag()
    private var cont = UIView()
    
    let rotationAngle = BehaviorRelay<Float>(value: 0)
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = .green
        
        let leftBorder = UIView(frame: CGRect.zero)
        addSubview(leftBorder)
        leftBorder.backgroundColor = .purple
        leftBorder.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(3)
        }
        
        let rigthBorder = UIView(frame: CGRect.zero)
        addSubview(rigthBorder)
        rigthBorder.backgroundColor = .purple
        rigthBorder.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(3)
        }
        
        
        rotationAngle.asDriver(onErrorJustReturn: 0).drive(onNext: { float in
            self.transform(float: float)
        }).disposed(by: bag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func transform(float: Float) {
        cont.transform = CGAffineTransform(rotationAngle: CGFloat(Double(-float) * Double.pi/180))
    }
    
    func update() {
        addSubview(cont)
        
        cont.snp.makeConstraints { make in
            make.trailing.top.equalToSuperview()
            make.width.height.equalToSuperview().multipliedBy(2)
        }
        
        let arrow = UIView(frame: CGRect.zero)
        cont.addSubview(arrow)
        arrow.backgroundColor = .blue
        arrow.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.height.equalTo(4)
            make.width.equalTo(frame.width)
        }
    }
}
