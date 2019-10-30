//: A UIKit based Playground for presenting user interface
  
import PlaygroundSupport
import ProteinEnergyRatio_iOS
import RxCocoa
import RxSwift
import SnapKit
import UIKit


// Present the view controller in the Live View window
let viewController = MainViewController()
//viewController.preferredContentSize = CGSize(width: 768, height: 1024)
PlaygroundPage.current.liveView = viewController

