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
        textField.textAlignment = .center
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.cornerRadius = 4.0
        addSubview(label)
        addSubview(slider)
        addSubview(textField)
        
        label.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
        }
        
        slider.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom)
            make.leading.bottom.equalToSuperview()
            make.width.equalToSuperview().inset(40)
        }
        
        textField.snp.makeConstraints { make in
            make.centerY.equalTo(slider.snp.centerY)
            make.trailing.equalToSuperview()
            make.leading.equalTo(slider.snp.trailing).offset(10)
            make.height.equalTo(slider)
        }
        
        textField.addDoneToolbar().rx.tap.bind { self.endEditing(true) }.disposed(by: bag)
    }
    
    private func bindUI() {
        func noLessThan(_ a: Float, _ b: Float) -> Float {
            if a == 0 { return b }
            
            if b <= a { return a }
            return b
        }
        
        let sliderInput = slider.rx.value.asObservable().withLatestFrom(inputOverride) { a, b in return (b, a) }.map(noLessThan)
        let overrideInput = inputOverride.asObservable().withLatestFrom(value) { a, b in return (a, b) }.map(noLessThan)
        
        let (sliderValue, floatValue) = sliderTextFieldViewModel(sliderInput: Observable.merge(sliderInput, overrideInput),
                                                                 textFieldInput: textField.rx.value.asObservable(),
                                                                 inputOverride: inputOverride.asObservable(),
                                                                 textFieldEndEditing: textField.rx.controlEvent(.editingDidEnd).asObservable())
        sliderValue.drive(textField.rx.text).disposed(by: bag)
        floatValue.drive(slider.rx.value).disposed(by: bag)
        floatValue.drive(value).disposed(by: bag)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

func sliderTextFieldViewModel(
    sliderInput: Observable<Float>,
    textFieldInput: Observable<String?>,
    inputOverride: Observable<Float>,
    textFieldEndEditing: Observable<()>
    ) -> (
    Driver<String>,
    Driver<Float>
    ) {
        
        func noLessThan(_ a: Float, _ b: Float) -> Float {
            if a == 0 { return b }
            
            if b <= a { return a }
            return b
        }
        
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
        
        let textInput = textAsFloat.withLatestFrom(inputOverride) { a, b in return (a, b) }.map(noLessThan)
        let notLowerThanOverrideFloat = textFieldEndEditing.withLatestFrom(textInput)
        let notLowerThanOverrideString = notLowerThanOverrideFloat.map(floatToString)
        
        let floatInputs = [textInput,
                           sliderInput,
                           notLowerThanOverrideFloat]
        let textInputs = [restrictedTextFieldInput,
                          sliderInputAsString,
                          notLowerThanOverrideString]
        
        let mergedStringOutputs = Observable.merge(textInputs).asDriver(onErrorJustReturn: "")
        let mergedFloatOutputs = Observable.merge(floatInputs).asDriver(onErrorJustReturn: 0.0)
    
        return (
            mergedStringOutputs.asDriver(onErrorJustReturn: ""),
            mergedFloatOutputs.asDriver(onErrorJustReturn: 0.0)
        )
}
