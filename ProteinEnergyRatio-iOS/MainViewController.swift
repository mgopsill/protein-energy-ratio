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

    }
    
    func bindUI() {
        let (caloriesLabelValue, percentProteinLabelValue) = mainViewModel(proteinSliderInput: proteinSlider.value.asObservable(),
                                                                           fatSliderInput: fatSlider.value.asObservable(),
                                                                           carbohydrateSliderInput: carbohydrateSlider.value.asObservable(),
                                                                           fiberSliderInput: fiberSlider.value.asObservable())
        caloriesLabelValue.drive(caloriesLabel.rx.text).disposed(by: bag)
        percentProteinLabelValue.drive(percentProteinLabel.rx.text).disposed(by: bag)
    }
}

func mainViewModel(
    proteinSliderInput: Observable<Float>,
    fatSliderInput: Observable<Float>,
    carbohydrateSliderInput: Observable<Float>,
    fiberSliderInput: Observable<Float>
    ) -> (
    Driver<String>,
    Driver<String>

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
        
        func sum(_ a: Int, _ b: Int, _ c: Int) -> String {
            return "Calories: \(a + b + c)"
        }
        
        let proteinCalories = proteinSliderInput.map(proteinAsCalories).debug("proteinCals")
        let fatCalories = fatSliderInput.map(fatAsCalories).debug("fatCals")
        let carbohydrateCalories = Observable.combineLatest(carbohydrateSliderInput, fiberSliderInput).map(carbsMinusFiber).debug("carbcals")
        
        let caloriesDriver = Observable.combineLatest(proteinCalories, fatCalories, carbohydrateCalories).map(sum).asDriver(onErrorJustReturn: "")
        
            

        return (
            caloriesDriver,
            Driver<String>.just("Test 2")
        )
}
