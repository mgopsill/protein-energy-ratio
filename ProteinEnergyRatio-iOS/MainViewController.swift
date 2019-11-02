//
//  MainViewController.swift
//  ProteinEnergyRatio
//
//  Created by Mike Gopsill on 11/09/2019.
//  Copyright © 2019 mgopsill. All rights reserved.
//
//: A UIKit based Playground for presenting user interface

import RxCocoa
import RxSwift
import SnapKit
import UIKit

public class MainViewController: UIViewController {
    
    private let inset = 10.0
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let proteinSlider = SliderTextFieldView(title: "Protein (grams):")
    private let fatSlider = SliderTextFieldView(title: "Fat (grams):")
    private let carbohydrateSlider = SliderTextFieldView(title: "Carbohydrate (grams):")
    private let fiberSlider = SliderTextFieldView(title: "Fiber (grams):")
    
    private lazy var slidersContainerView: SlidersContainerView = {
        return  SlidersContainerView(views: [proteinSlider, fatSlider, carbohydrateSlider, fiberSlider])
    }()
    
    private let caloriesLabel = UILabel()
    private let percentProteinLabel = UILabel()
    private let percentFatLabel = UILabel()
    private let percentCarbLabel = UILabel()
    private let proteinEnergyRatioLabel = UILabel()
    private let nutritionalVectorLabel = UILabel()
    private let labelContainerView = UIStackView()
    
    private let graph = GraphView()
    private let proteinLabel = UILabel()
    private let energyLabel = UILabel()

    private let bag = DisposeBag()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
        setupViews()
        view.backgroundColor = .white
        title = "P:E"
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.keyboardDismissMode = .onDrag
        scrollView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        scrollView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.height.width.equalToSuperview()
            make.bottom.equalToSuperview().priority(.low)
        }
        
        containerView.addSubview(slidersContainerView)
        slidersContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(inset*2)
            make.leading.trailing.equalToSuperview().inset(inset)
        }

        containerView.addSubview(labelContainerView)
        labelContainerView.snp.makeConstraints { make in
            make.top.equalTo(slidersContainerView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(inset*2)
        }
        
        labelContainerView.axis = .vertical
        labelContainerView.spacing = 15
        
        labelContainerView.addArrangedSubview(caloriesLabel)
        caloriesLabel.backgroundColor = .cyan

        labelContainerView.addArrangedSubview(percentProteinLabel)
        percentProteinLabel.backgroundColor = .cyan

        labelContainerView.addArrangedSubview(percentFatLabel)
        percentFatLabel.backgroundColor = .cyan

        labelContainerView.addArrangedSubview(percentCarbLabel)
        percentCarbLabel.backgroundColor = .cyan

        labelContainerView.addArrangedSubview(proteinEnergyRatioLabel)
        proteinEnergyRatioLabel.backgroundColor = .cyan

        labelContainerView.addArrangedSubview(nutritionalVectorLabel)
        nutritionalVectorLabel.backgroundColor = .cyan

        containerView.addSubview(graph)
        graph.snp.makeConstraints { make in
            make.top.equalTo(labelContainerView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(view.snp.width).multipliedBy(0.8)
        }
        view.layoutIfNeeded()
        graph.update()
        
        containerView.addSubview(energyLabel)
        energyLabel.text = "ENERGY"
        energyLabel.snp.makeConstraints { make in
            make.top.equalTo(graph.snp.bottom).offset(4)
            make.centerX.equalTo(graph)
        }
        
        containerView.addSubview(proteinLabel)
        proteinLabel.text = "PROTEIN"
        proteinLabel.transform = CGAffineTransform(rotationAngle: CGFloat(Double(-90) * Double.pi/180))
        proteinLabel.snp.makeConstraints { make in
            make.centerY.equalTo(graph)
            make.centerX.equalTo((graph).snp.leading).inset((-proteinLabel.intrinsicContentSize.height / 2) - 4)
        }
        
        view.layoutIfNeeded()
    }
    
    func bindUI() {
        let (caloriesLabelValue,
            percentProteinLabelValue,
            percentFatLabelValue,
            percentCarbLabelValue,
            proteinRatioValue,
            nutritionalVectorValue,
            carbNotLessThanFiberValue) =
            mainViewModel(proteinSliderInput: proteinSlider.value.asObservable(),
                          fatSliderInput: fatSlider.value.asObservable(),
                          carbohydrateSliderInput: carbohydrateSlider.value.asObservable(),
                          fiberSliderInput: fiberSlider.value.asObservable())
        caloriesLabelValue.map { "Cals: \(String($0)) "}.drive(caloriesLabel.rx.text).disposed(by: bag)
        percentProteinLabelValue.map { "Protein percent: \(String($0)) "}.drive(percentProteinLabel.rx.text).disposed(by: bag)
        percentFatLabelValue.map { "Fat percent: \(String($0)) "}.drive(percentFatLabel.rx.text).disposed(by: bag)
        percentCarbLabelValue.map { "Carb percent: \(String($0)) "}.drive(percentCarbLabel.rx.text).disposed(by: bag)
        proteinRatioValue.map { "P:E: \(String($0)) "}.drive(proteinEnergyRatioLabel.rx.text).disposed(by: bag)
        nutritionalVectorValue.map { "Nutritional Vector: \(String($0)) "}.drive(nutritionalVectorLabel.rx.text).disposed(by: bag)
        Driver.combineLatest(nutritionalVectorValue, proteinRatioValue).drive(graph.rotationAngle).disposed(by: bag)
        carbNotLessThanFiberValue.drive(carbohydrateSlider.inputOverride).disposed(by: bag)
    }
    
    public override func viewDidLayoutSubviews() {
        self.scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: containerView.subviews.heightForAllSubViews)
    }
}

extension Array where Element: UIView {
    var heightForAllSubViews: CGFloat {
        return self.map { $0.frame.height }.reduce(0, +)
    }
}

func mainViewModel(
    proteinSliderInput: Observable<Float>,
    fatSliderInput: Observable<Float>,
    carbohydrateSliderInput: Observable<Float>,
    fiberSliderInput: Observable<Float>
    ) -> (
    Driver<Int>,
    Driver<Int>,
    Driver<Int>,
    Driver<Int>,
    Driver<Float>,
    Driver<Float>,
    Driver<Float>
    ) {
        
        func proteinAsCalories(_ float: Float) -> Int {
            return Int(float * 4)
        }
        
        func fatAsCalories(_ float: Float) -> Int {
            return Int(float * 9)
        }
        
        func carbsMinusFiber(_ a: Float, _ b: Float) -> Int {
            return Int(a - b) * 4
        }
        
        func sum(_ a: Int, _ b: Int, _ c: Int) -> Int {
            return a + b + c
        }
        
        func percent(_ a: Float, _ b: Float) -> Int {
            guard a > 0 && b > 0 else { return 0 }
            return Int((b / a) * 100)
        }
        
        func ratio(_ protein: Float, _ fat: Float, _ carbohydrates: Float, _ fiber: Float) -> Float {
            let ratio = protein / (fat + carbohydrates - fiber)
            let returnValue = (ratio * 100).rounded(.toNearestOrEven) / 100
            return returnValue > 0 ? returnValue : 0
        }
        
        func vector(_ ratio: Float) -> Float {
            let vector = atan(ratio) * 180 / Float.pi
            return (vector * 100).rounded(.toNearestOrEven) / 100
        }

        let carbNotLessThanFiberDriver = fiberSliderInput.asDriver(onErrorJustReturn: 0)
        
        let proteinCalories = proteinSliderInput.map(proteinAsCalories)
        let fatCalories = fatSliderInput.map(fatAsCalories)
        let carbohydrateCalories = Observable.combineLatest(carbohydrateSliderInput, fiberSliderInput).map(carbsMinusFiber)
        
        let caloriesDriver = Observable.combineLatest(proteinCalories, fatCalories, carbohydrateCalories).map(sum).asDriver(onErrorJustReturn: 0)
        let percentProteinDriver = Observable.combineLatest(caloriesDriver.asObservable().map(Float.init), proteinCalories.map(Float.init)).map(percent).asDriver(onErrorJustReturn: 0)
        let percentFatDriver = Observable.combineLatest(caloriesDriver.asObservable().map(Float.init), fatCalories.map(Float.init)).map(percent).asDriver(onErrorJustReturn: 0)
        let percentCarbDriver = Observable.combineLatest(caloriesDriver.asObservable().map(Float.init), carbohydrateCalories.map(Float.init)).map(percent).asDriver(onErrorJustReturn: 0)
        let proteinRatioDriver = Observable.combineLatest(proteinSliderInput, fatSliderInput, carbohydrateSliderInput, fiberSliderInput).map(ratio).asDriver(onErrorJustReturn: 0)
        
        let nutritonalVectorDriver = proteinRatioDriver.asObservable().map(vector).asDriver(onErrorJustReturn: 0)

        return (
            caloriesDriver,
            percentProteinDriver,
            percentFatDriver,
            percentCarbDriver,
            proteinRatioDriver,
            nutritonalVectorDriver,
            carbNotLessThanFiberDriver
        )
}
