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
        title = "Protein : Energy"
    }
    
    private func setupViews() {
        navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        navigationController?.navigationBar.layer.shadowRadius = 4.0
        navigationController?.navigationBar.layer.shadowOpacity = 0.5
        navigationController?.navigationBar.layer.masksToBounds = false
        navigationController?.navigationBar.backgroundColor = UIColor(red: 100/256, green: 224/256, blue: 255/256, alpha: 1)
        navigationController?.navigationBar.barTintColor = UIColor(red: 100/256, green: 224/256, blue: 255/256, alpha: 1)
        navigationController?.navigationBar.prefersLargeTitles = true
        
        UIApplication.shared.statusBarUIView?.backgroundColor = UIColor(red: 100/256, green: 224/256, blue: 255/256, alpha: 1)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        
        view.addSubview(scrollView)
        scrollView.delaysContentTouches = false
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
        
        let calories = LabelsView(leftText: "Calories:", rightText: "🍽", centralLabel: caloriesLabel)
        labelContainerView.addArrangedSubview(calories)
        
        let protein = LabelsView(leftText: "Protein percent:", rightText: "💪", centralLabel: percentProteinLabel)
        labelContainerView.addArrangedSubview(protein)

        let fat = LabelsView(leftText: "Fat percent:", rightText: "🧀", centralLabel: percentFatLabel)
        labelContainerView.addArrangedSubview(fat)

        let carb = LabelsView(leftText: "Carb percent:", rightText: "🍚", centralLabel: percentCarbLabel)
        labelContainerView.addArrangedSubview(carb)
        
        let pe = LabelsView(leftText: "Protein:Energy:", rightText: "📈", centralLabel: proteinEnergyRatioLabel)
        labelContainerView.addArrangedSubview(pe)

        let nut = LabelsView(leftText: "Nutrional Vector °:", rightText: "🧭", centralLabel: nutritionalVectorLabel)
        labelContainerView.addArrangedSubview(nut)

        let x = SeperatorView()
        containerView.addArrangedSubview(x)
        
        let graphContainerView = GraphContainerView(height: view.frame.width * 0.8)
        graphContainerView.addSubview(graph)
        containerView.addArrangedSubview(graphContainerView)
        graph.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.width.equalTo(view.snp.width).multipliedBy(0.7)
        }
        
        let labelContainerBackgroundView = UIView()
        labelContainerBackgroundView.backgroundColor = UIColor(red: 100/256, green: 224/256, blue: 255/256, alpha: 1)
        labelContainerBackgroundView.layer.cornerRadius = 10
        labelContainerView.addSubview(labelContainerBackgroundView)
        labelContainerBackgroundView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view)
            make.top.equalTo(slidersContainerView.snp.bottom)
            make.bottom.equalTo(x.snp.top)
        }
        labelContainerView.sendSubviewToBack(labelContainerBackgroundView)
        
        let footerLabel = UILabel()
        footerLabel.text = "Protein : Energy Ratio"
        footerLabel.font = UIFont.systemFont(ofSize: 8, weight: .thin)
        footerLabel.textColor = .gray
        footerLabel.textAlignment = .center
        containerView.addArrangedSubview(footerLabel)
    }
    
    @objc func endEditing() {
        self.view.endEditing(true)
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
