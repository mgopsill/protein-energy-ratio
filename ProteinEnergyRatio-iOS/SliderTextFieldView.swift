//
//  SliderTextFieldView.swift
//  Pods-ProteinEnergyRatio
//
//  Created by Mike Gopsill on 28/10/2019.
//

import RxCocoa
import RxSwift
import UIKit

class SliderTextFieldView: UIView {
    
    let value = BehaviorRelay<Float>(value: 0.0)
    let inputOverride = BehaviorRelay<Float>(value: 0.0)
    
    private let label = UILabel()
    private let slider = UISlider()
    private let textField = UITextField()
    private let bag = DisposeBag()
    
    init(title: String) {
        super.init(frame: CGRect.zero)
        label.text = title
        setupUI()
        bindUI()
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        slider.backgroundColor = .lightGray
        label.backgroundColor = .green
        textField.backgroundColor = .yellow
        slider.maximumValue = 50.0
        slider.minimumValue = 0.0
        label.translatesAutoresizingMaskIntoConstraints = false
        slider.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .decimalPad
        addSubview(label)
        addSubview(slider)
        addSubview(textField)
        
        label.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
        }
        
        slider.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom)
            make.leading.bottom.equalToSuperview()
            make.width.equalToSuperview().inset(50)
        }
        
        textField.snp.makeConstraints { make in
            make.centerY.equalTo(slider.snp.centerY)
            make.trailing.equalToSuperview()
            make.leading.equalTo(slider.snp.trailing)
        }
    }
    
    private func bindUI() {
        func noLessThan(_ a: Float, _ b: Float) -> Float {
            if a == 0 { return b }
            
            if b <= a { return a }
            return b
        }
        
        let sliderInput = slider.rx.value.asObservable()
        let overrideInput = inputOverride.asObservable().withLatestFrom(value) { a, b in return (a, b) }.map(noLessThan)
        
        let (sliderValue, floatValue) = sliderTextFieldViewModel(sliderInput: Observable.merge(sliderInput, overrideInput),
                                                                 textFieldInput: textField.rx.value.asObservable(),
                                                                 inputOverride: inputOverride.asObservable())
        sliderValue.drive(textField.rx.text).disposed(by: bag)
        floatValue.drive(slider.rx.value).disposed(by: bag)
        floatValue.drive(value).disposed(by: bag)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

func sliderTextFieldViewModel(
    sliderInput: Observable<Float>,
    textFieldInput: Observable<String?>,
    inputOverride: Observable<Float>
    ) -> (
    Driver<String>,
    Driver<Float>
    ) {
        
        func nothing<T>(_ element: T) -> T {
            return element
        }
        
        func allowOnlyDecimals(_ string: String) -> String {
            let charset = CharacterSet.punctuationCharacters.union(CharacterSet.decimalDigits).inverted
            var decimalString = string.components(separatedBy: charset).joined()
            if (decimalString.filter { $0 == "."}.count) > 1 {
                decimalString.removeLast()
                return decimalString
            }
            return decimalString
        }
        
        func floatToString(_ float: Float) -> String {
            return String((float * 10).rounded(.toNearestOrEven) / 10)
        }
        
        let restrictedTextFieldInput = textFieldInput
            .compactMap(nothing)
            .map(allowOnlyDecimals)
        
        let sliderInputAsString = sliderInput
            .distinctUntilChanged()
            .map(floatToString)
        
        let textAsFloat = restrictedTextFieldInput
            .map(Float.init)
            .compactMap(nothing)
        
        let floatInputs = [textAsFloat,
                           sliderInput]
        
        let mergedStringOutputs = Observable.merge(restrictedTextFieldInput, sliderInputAsString).asDriver(onErrorJustReturn: "")
        let mergedFloatOutputs = Observable.merge(floatInputs).asDriver(onErrorJustReturn: 0.0)

        return (
            mergedStringOutputs.asDriver(onErrorJustReturn: ""),
            mergedFloatOutputs.asDriver(onErrorJustReturn: 0.0)
        )
}
