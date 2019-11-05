//: A UIKit based Playground for presenting user interface
  
import PlaygroundSupport
import ProteinEnergyRatio_iOS
import RxCocoa
import RxSwift
import SnapKit
import UIKit



class ViewController: UIViewController {
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    let topLabel: UILabel = {
        let label = UILabel()
        label.text = "Top Label"
        return label
    }()
    
    let containerView = CustomView()
    
    let bottomLabel: UILabel = {
        let label = UILabel()
        label.text = "Bottom Label"
        return label
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = .yellow
        
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.distribution = .fillProportionally
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.width.equalToSuperview()
            make.bottom.equalToSuperview().priority(.low)
        }
        
        let containedView = UIView()
        containedView.backgroundColor = .green
        let graphView = GraphView()
        
        containerView.addSubview(graphView)
        graphView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.width.equalTo(100)
        }
        
        stackView.addArrangedSubview(topLabel)
        stackView.addArrangedSubview(bottomLabel)
        
        for i in 0...5 {
            let labelOne = UILabel()
            labelOne.text = "1 \(i)"
            labelOne.backgroundColor = .red
            stackView.addArrangedSubview(labelOne)
            let labelTwo = UILabel()
            labelTwo.text = "2 \(i)"
            labelTwo.backgroundColor = .purple
            stackView.addArrangedSubview(labelTwo)
        }
        

        stackView.addArrangedSubview(containerView)

    }
}

class CustomView: UIView {
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 2, height: 700)
    }
}


// Present the view controller in the Live View window
let viewController = ViewController()
//viewController.preferredContentSize = CGSize(width: 768, height: 1024)
PlaygroundPage.current.liveView = viewController
