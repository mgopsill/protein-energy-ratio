//: A UIKit based Playground for presenting user interface
  
import PlaygroundSupport
import ProteinEnergyRatio_iOS
import RxCocoa
import RxSwift
import SnapKit
import UIKit


class VC: UIViewController {
    let graphView = GraphView()
    let slider = UISlider()

    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(graphView)
        graphView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.width.equalTo(350)
        }
        
        view.addSubview(slider)
        slider.maximumValue = 90
        slider.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        slider.rx.value.map(Int.init).asDriver(onErrorJustReturn: 0).drive(graphView.rotationAngle)
        graphView.update()
    }
}

class GraphView: UIView {
    
    private let bag = DisposeBag()
    private var cont = UIView()
    
    let rotationAngle = BehaviorRelay<Int>(value: 80)
    
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
        
        
        rotationAngle.asDriver(onErrorJustReturn: 0).drive(onNext: { int in
            self.transform(int: int)
        }).disposed(by: bag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func transform(int: Int) {
        cont.transform = CGAffineTransform(rotationAngle: CGFloat(Double(-int) * Double.pi/180))
    }
    
    func update() {
        cont = UIView(frame: CGRect(x: -frame.width, y: 0, width: frame.width * 2, height: frame.width * 2))
        cont.backgroundColor = .red
        addSubview(cont)
        
        //        cont.snp.makeConstraints { make in
        //            make.trailing.top.equalToSuperview()
        //            make.width.height.equalToSuperview().multipliedBy(2)
        //        }
        
        let arrow = UIView(frame: CGRect.zero)
        cont.addSubview(arrow)
        arrow.backgroundColor = .black
        arrow.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.height.equalTo(4)
            make.width.equalTo(frame.width)
        }
    }
}

// Present the view controller in the Live View window
let viewController = VC()
//viewController.preferredContentSize = CGSize(width: 768, height: 1024)
PlaygroundPage.current.liveView = viewController

