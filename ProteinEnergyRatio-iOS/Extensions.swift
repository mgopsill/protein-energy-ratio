//
//  Extensions.swift
//  ProteinEnergyRatio-iOS
//
//  Created by Mike Gopsill on 30/10/2019.
//  Copyright © 2019 mgopsill. All rights reserved.
//

import Foundation

extension UITextField {
    func addDoneToolbar() -> UIBarButtonItem {
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: frame.size.width, height: 30)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: nil, action: nil)
        toolbar.setItems([flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()
        self.inputAccessoryView = toolbar
        return doneButton
    }
}
