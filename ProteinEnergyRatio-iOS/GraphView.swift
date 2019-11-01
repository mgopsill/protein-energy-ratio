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
    private let arrowLabel = UILabel()
    
    let rotationAngle = BehaviorRelay<(Float, Float)>(value: (0, 0))
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = .clear
        rotationAngle.asDriver(onErrorJustReturn: (0, 0)).drive(onNext: { angle, ratio in
            self.transform(float: angle)
            let ratioRounded = (ratio * 10).rounded(.toNearestOrEven) / 10
            self.arrowLabel.text = "P:E = \(ratioRounded)"
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
        
        arrowLabel.text = "P:E"
        arrowLabel.font = UIFont.boldSystemFont(ofSize: 8)
        cont.addSubview(arrowLabel)
        arrowLabel.snp.makeConstraints { make in
            make.trailing.equalTo(arrow.snp.trailing).inset(6)
            make.bottom.equalTo(arrow.snp.bottom).inset(6)
        }
        
        UIGraphicsBeginImageContext(self.frame.size)
        UIImage(named: "graphBackGround")?.draw(in: bounds)
        
        if let image = UIGraphicsGetImageFromCurrentImageContext(){
            UIGraphicsEndImageContext()
            backgroundColor = UIColor(patternImage: image)
        }else{
            UIGraphicsEndImageContext()
            debugPrint("Image not available")
        }
    }
}
