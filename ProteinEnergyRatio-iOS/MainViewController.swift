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
    
    private let proteinSlider = SliderTextFieldView(title: "Protein (grams):")
    private let fatSlider = SliderTextFieldView(title: "Fat (grams):")
    private let carbohydrateSlider = SliderTextFieldView(title: "Carbohydrate (grams):")
    private let fiberSlider = SliderTextFieldView(title: "Fiber (grams):")
    
    private let caloriesLabel = UILabel()
    private let percentProteinLabel = UILabel()
    private let percentFatLabel = UILabel()
    private let percentCarbLabel = UILabel()
    private let proteinEnergyRatioLabel = UILabel()

    private let bag = DisposeBag()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindUI()
        view.backgroundColor = .white
    }
    
    private func setupViews() {
        view.addSubview(proteinSlider)
        proteinSlider.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
        }
        
        view.addSubview(fatSlider)
        fatSlider.snp.makeConstraints { make in
            make.top.equalTo(proteinSlider.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
        }
        
        view.addSubview(carbohydrateSlider)
        carbohydrateSlider.snp.makeConstraints { make in
            make.top.equalTo(fatSlider.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
        }
        
        view.addSubview(fiberSlider)
        fiberSlider.snp.makeConstraints { make in
            make.top.equalTo(carbohydrateSlider.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
        }
        
        view.addSubview(caloriesLabel)
        caloriesLabel.backgroundColor = .red
        caloriesLabel.snp.makeConstraints { make in
            make.top.equalTo(fiberSlider.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        view.addSubview(percentProteinLabel)
        percentProteinLabel.backgroundColor = .purple
        percentProteinLabel.snp.makeConstraints { make in
            make.top.equalTo(caloriesLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        view.addSubview(percentFatLabel)
        percentFatLabel.backgroundColor = .green
        percentFatLabel.snp.makeConstraints { make in
            make.top.equalTo(percentProteinLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        view.addSubview(percentCarbLabel)
        percentCarbLabel.backgroundColor = .orange
        percentCarbLabel.snp.makeConstraints { make in
            make.top.equalTo(percentFatLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        view.addSubview(proteinEnergyRatioLabel)
        proteinEnergyRatioLabel.backgroundColor = .cyan
        proteinEnergyRatioLabel.snp.makeConstraints { make in
            make.top.equalTo(percentCarbLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
    }
    
    func bindUI() {
        let (caloriesLabelValue,
            percentProteinLabelValue,
            percentFatLabelValue,
            percentCarbLabelValue,
            proteinRatioValue) =
            mainViewModel(proteinSliderInput: proteinSlider.value.asObservable(),
                          fatSliderInput: fatSlider.value.asObservable(),
                          carbohydrateSliderInput: carbohydrateSlider.value.asObservable(),
                          fiberSliderInput: fiberSlider.value.asObservable())
        caloriesLabelValue.map { "Cals: \(String($0)) "}.drive(caloriesLabel.rx.text).disposed(by: bag)
        percentProteinLabelValue.map { "Protein percent: \(String($0)) "}.drive(percentProteinLabel.rx.text).disposed(by: bag)
        percentFatLabelValue.map { "Fat percent: \(String($0)) "}.drive(percentFatLabel.rx.text).disposed(by: bag)
        percentCarbLabelValue.map { "Carb percent: \(String($0)) "}.drive(percentCarbLabel.rx.text).disposed(by: bag)
        proteinRatioValue.map { "P:E \(String($0)) "}.drive(proteinEnergyRatioLabel.rx.text).disposed(by: bag)

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
            let returnValue = (ratio * 10).rounded(.toNearestOrEven) / 10
            return returnValue > 0 ? returnValue : 0
        }
        
        let proteinCalories = proteinSliderInput.map(proteinAsCalories).debug("proteincals")
        let fatCalories = fatSliderInput.map(fatAsCalories)
        let carbohydrateCalories = Observable.combineLatest(carbohydrateSliderInput, fiberSliderInput).map(carbsMinusFiber)
        
        let caloriesDriver = Observable.combineLatest(proteinCalories, fatCalories, carbohydrateCalories).map(sum).asDriver(onErrorJustReturn: 0)
        let percentProteinDriver = Observable.combineLatest(caloriesDriver.asObservable().map(Float.init), proteinCalories.map(Float.init)).map(percent).asDriver(onErrorJustReturn: 0)
        let percentFatDriver = Observable.combineLatest(caloriesDriver.asObservable().map(Float.init), fatCalories.map(Float.init)).map(percent).asDriver(onErrorJustReturn: 0)
        let percentCarbDriver = Observable.combineLatest(caloriesDriver.asObservable().map(Float.init), carbohydrateCalories.map(Float.init)).map(percent).asDriver(onErrorJustReturn: 0)
        let proteinRatioDriver = Observable.combineLatest(proteinSliderInput, fatSliderInput, carbohydrateSliderInput, fiberSliderInput).map(ratio).asDriver(onErrorJustReturn: 0)
        
        
//        var ratio = fixNum(protein / (fat + carbohydrates - fiber));
//
//        ratio = Math.round(ratio * 100) / 100;
//
//        var nutritionalVector = Math.atan(ratio)*180/Math.PI;
//
//        nutritionalVector = Math.round(nutritionalVector * 10) / 10;

        // TODO: NVector
        // TODO: Fiber vs carb slider logic
        return (
            caloriesDriver,
            percentProteinDriver,
            percentFatDriver,
            percentCarbDriver,
            proteinRatioDriver
        )
}
