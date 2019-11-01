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
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let proteinSlider = SliderTextFieldView(title: "Protein (grams):")
    private let fatSlider = SliderTextFieldView(title: "Fat (grams):")
    private let carbohydrateSlider = SliderTextFieldView(title: "Carbohydrate (grams):")
    private let fiberSlider = SliderTextFieldView(title: "Fiber (grams):")
    
    private let caloriesLabel = UILabel()
    private let percentProteinLabel = UILabel()
    private let percentFatLabel = UILabel()
    private let percentCarbLabel = UILabel()
    private let proteinEnergyRatioLabel = UILabel()
    private let nutritionalVectorLabel = UILabel()
    private let graph = GraphView()
    private let proteinLabel = UILabel()
    private let energyLabel = UILabel()

    private let bag = DisposeBag()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
        setupViews()
        view.backgroundColor = .white
//        containerView.translatesAutoresizingMaskIntoConstraints = false
//        containerView.intr
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
        
        containerView.addSubview(proteinSlider)
        proteinSlider.snp.makeConstraints { make in
            make.top.equalTo(containerView.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
        }
        
        containerView.addSubview(fatSlider)
        fatSlider.snp.makeConstraints { make in
            make.top.equalTo(proteinSlider.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
        }
        
        containerView.addSubview(carbohydrateSlider)
        carbohydrateSlider.snp.makeConstraints { make in
            make.top.equalTo(fatSlider.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
        }
        
        containerView.addSubview(fiberSlider)
        fiberSlider.snp.makeConstraints { make in
            make.top.equalTo(carbohydrateSlider.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
        }
        
        containerView.addSubview(caloriesLabel)
        caloriesLabel.backgroundColor = .red
        caloriesLabel.snp.makeConstraints { make in
            make.top.equalTo(fiberSlider.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        containerView.addSubview(percentProteinLabel)
        percentProteinLabel.backgroundColor = .purple
        percentProteinLabel.snp.makeConstraints { make in
            make.top.equalTo(caloriesLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        containerView.addSubview(percentFatLabel)
        percentFatLabel.backgroundColor = .green
        percentFatLabel.snp.makeConstraints { make in
            make.top.equalTo(percentProteinLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        containerView.addSubview(percentCarbLabel)
        percentCarbLabel.backgroundColor = .orange
        percentCarbLabel.snp.makeConstraints { make in
            make.top.equalTo(percentFatLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        containerView.addSubview(proteinEnergyRatioLabel)
        proteinEnergyRatioLabel.backgroundColor = .cyan
        proteinEnergyRatioLabel.snp.makeConstraints { make in
            make.top.equalTo(percentCarbLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        containerView.addSubview(nutritionalVectorLabel)
        nutritionalVectorLabel.backgroundColor = .magenta
        nutritionalVectorLabel.snp.makeConstraints { make in
            make.top.equalTo(proteinEnergyRatioLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        containerView.addSubview(graph)
        graph.snp.makeConstraints { make in
            make.top.equalTo(nutritionalVectorLabel.snp.bottom)
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
