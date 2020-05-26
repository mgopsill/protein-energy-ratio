//
//  CustomTextField.swift
//  PERatio
//
//  Created by Mike Gopsill on 24/05/2020.
//  Copyright © 2020 mgopsill. All rights reserved.
//

import Combine
import SwiftUI
import UIKit


struct CustomTextField: UIViewRepresentable {
    
    let placeHolder: String
    @Binding var value: Float
    let onEditChanged: ((Bool) -> Void)?
    
    let textField = UITextField()
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextField {
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: textField.frame.size.width, height: 30)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: context.coordinator, action: #selector(Coordinator.done))
        toolbar.setItems([flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()
        textField.inputAccessoryView = toolbar
        textField.keyboardType = .decimalPad
        textField.textAlignment = .center
        textField.delegate = context.coordinator
        textField.placeholder = placeHolder
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = numberFormatter.string(from: NSNumber(value: value))
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var customTextField: CustomTextField
        
        init(_ customTextField: CustomTextField) {
            self.customTextField = customTextField
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            customTextField.onEditChanged?(true)
        }
        
        func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
            customTextField.onEditChanged?(false)
            let number = numberFormatter.number(from: textField.text ?? "") ?? 0
            customTextField.value = Float(truncating: number)
        }
        
        @objc func done() {
            customTextField.textField.endEditing(false)
        }
    }
}
