//
//  GraphView.swift
//  Pods-ProteinEnergyRatio
//
//  Created by Mike Gopsill on 29/10/2019.
//

import RxRelay
import RxSwift
import UIKit

public class GraphView: UIView {
    
    private let bag = DisposeBag()
    private var cont = UIView()
    private let arrowLabel = UILabel()
    private let proteinLabel = UILabel()
    private let energyLabel = UILabel()
    
    let rotationAngle = BehaviorRelay<(Float, Float)>(value: (0, 0))
    
    public init() {
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
    
    public func transform(float: Float) {
        cont.transform = CGAffineTransform(rotationAngle: CGFloat(Double(-float) * Double.pi/180))
    }
    
    public func update() {
        let image = UIImage(named: "graphBackGround")
        let imageView = UIImageView(image: image)
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        addSubview(cont)
        
        cont.snp.makeConstraints { make in
            make.trailing.top.equalToSuperview()
            make.width.height.equalToSuperview().multipliedBy(2)
        }
        cont.backgroundColor = .clear
        
        let arrow = UIView(frame: CGRect.zero)
        cont.addSubview(arrow)
        arrow.backgroundColor = .blue
        arrow.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.height.equalTo(2)
            make.width.equalTo(self.snp.width)
        }
        
        arrowLabel.text = "P:E"
        arrowLabel.font = UIFont.boldSystemFont(ofSize: 8)
        cont.addSubview(arrowLabel)
        arrowLabel.snp.makeConstraints { make in
            make.trailing.equalTo(arrow.snp.trailing).inset(6)
            make.bottom.equalTo(arrow.snp.bottom).inset(3)
        }
        
        addSubview(energyLabel)
        energyLabel.text = "ENERGY"
        energyLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.bottom).offset(4)
            make.centerX.equalTo(self)
        }
        
        addSubview(proteinLabel)
        proteinLabel.text = "PROTEIN"
        proteinLabel.transform = CGAffineTransform(rotationAngle: CGFloat(Double(-90) * Double.pi/180))
        proteinLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.centerX.equalTo((self).snp.leading).inset((-proteinLabel.intrinsicContentSize.height / 2) - 4)
        }
    }
}
