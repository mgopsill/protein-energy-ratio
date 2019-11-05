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
    private let containerView = UIStackView()
    
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
        
        containerView.axis = .vertical
        containerView.spacing = 30
        scrollView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.width.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().priority(.low)
        }
        
        containerView.addArrangedSubview(slidersContainerView)

        containerView.addArrangedSubview(labelContainerView)
        
        labelContainerView.axis = .vertical
        labelContainerView.spacing = 15
        
        let caloriesLeft = UILabel()
        caloriesLeft.text = "Calories:"
        caloriesLeft.font = UIFont.boldSystemFont(ofSize: 16)
        let calories = TwoLabels(leftLabel: caloriesLeft, rightLabel: caloriesLabel)
        
        labelContainerView.addArrangedSubview(calories)
        
        let proteinLeft = UILabel()
        proteinLeft.text = "Protein percent:"
        proteinLeft.font = UIFont.boldSystemFont(ofSize: 16)
        let protein = TwoLabels(leftLabel: proteinLeft, rightLabel: percentProteinLabel)
        
        labelContainerView.addArrangedSubview(protein)

        let fatLeft = UILabel()
        fatLeft.text = "Fat percent:"
        fatLeft.font = UIFont.boldSystemFont(ofSize: 16)
        let fat = TwoLabels(leftLabel: fatLeft, rightLabel: percentFatLabel)
        
        labelContainerView.addArrangedSubview(fat)

        let carbLeft = UILabel()
        carbLeft.text = "Carb percent:"
        carbLeft.font = UIFont.boldSystemFont(ofSize: 16)
        let carb = TwoLabels(leftLabel: carbLeft, rightLabel: percentCarbLabel)
        
        labelContainerView.addArrangedSubview(carb)
        
        let peLeft = UILabel()
        peLeft.text = "Protein:Energy:"
        peLeft.font = UIFont.boldSystemFont(ofSize: 16)
        let pe = TwoLabels(leftLabel: peLeft, rightLabel: proteinEnergyRatioLabel)
        
        labelContainerView.addArrangedSubview(pe)

        let nutLeft = UILabel()
        nutLeft.text = "Nutrional Vector Angle:"
        nutLeft.font = UIFont.boldSystemFont(ofSize: 16)
        let nut = TwoLabels(leftLabel: nutLeft, rightLabel: nutritionalVectorLabel)
        
        labelContainerView.addArrangedSubview(nut)

        let graphContainerView = GraphContainerView(height: view.frame.width)
        graphContainerView.addSubview(graph)
        containerView.addArrangedSubview(graphContainerView)
        graph.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.width.equalTo(view.snp.width).multipliedBy(0.8)
        }
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
        caloriesLabelValue.map { "\(String($0))"}.drive(caloriesLabel.rx.text).disposed(by: bag)
        percentProteinLabelValue.map { "\(String($0))%"}.drive(percentProteinLabel.rx.text).disposed(by: bag)
        percentFatLabelValue.map { "\(String($0))%"}.drive(percentFatLabel.rx.text).disposed(by: bag)
        percentCarbLabelValue.map { "\(String($0))%"}.drive(percentCarbLabel.rx.text).disposed(by: bag)
        proteinRatioValue.map { "\(String($0))"}.drive(proteinEnergyRatioLabel.rx.text).disposed(by: bag)
        nutritionalVectorValue.map { "\(String($0))"}.drive(nutritionalVectorLabel.rx.text).disposed(by: bag)
        Driver.combineLatest(nutritionalVectorValue, proteinRatioValue).drive(graph.rotationAngle).disposed(by: bag)
        carbNotLessThanFiberValue.drive(carbohydrateSlider.inputOverride).disposed(by: bag)
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
