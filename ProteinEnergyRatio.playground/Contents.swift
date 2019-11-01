//: A UIKit based Playground for presenting user interface
  
import PlaygroundSupport
import ProteinEnergyRatio_iOS
import RxCocoa
import RxSwift
import SnapKit
import UIKit


class ViewController: UIViewController {
    
    var label: UILabel = UILabel()
    var fixedView: UIView = UIView()
    var slider: UISlider = UISlider()
    
    override func viewDidLoad() {
        view.backgroundColor = .white

        view.addSubview(fixedView)
        fixedView.backgroundColor = .red
        fixedView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        view.addSubview(label)
        label.text = "How about"
        label.snp.makeConstraints { make in
            make.centerY.equalTo(fixedView)
            print(label.intrinsicContentSize.height)
            make.centerX.equalTo(fixedView.snp.leading).inset(-label.intrinsicContentSize.height / 2)
        }
        
        view.addSubview(slider)
        slider.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(80)
        }
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTransform()
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        updateTransform()
    }
    
    private func updateTransform() {
//        var transform = CGAffineTransform.identity
//        let labelSize = label.bounds.size
//        transform = transform.translatedBy(x: -labelSize.width / 2, y: labelSize.height / 2)
//        transform = transform.rotated(by: -CGFloat(slider.value) * CGFloat.pi / 2)
//        transform = transform.translatedBy(x: labelSize.width / 2, y: -labelSize.height / 2)
//        label.transform = transform
//
        label.transform = CGAffineTransform(rotationAngle: CGFloat(Double(-90) * Double.pi/180))

    }
    
}

// Present the view controller in the Live View window
let viewController = ViewController()
//viewController.preferredContentSize = CGSize(width: 768, height: 1024)
PlaygroundPage.current.liveView = viewController

