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

extension UIApplication {
    var statusBarUIView: UIView? {
        if #available(iOS 13.0, *) {
            let tag = 38482
            let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
            
            if let statusBar = keyWindow?.viewWithTag(tag) {
                return statusBar
            } else {
                guard let statusBarFrame = keyWindow?.windowScene?.statusBarManager?.statusBarFrame else { return nil }
                let statusBarView = UIView(frame: statusBarFrame)
                statusBarView.tag = tag
                keyWindow?.addSubview(statusBarView)
                return statusBarView
            }
        } else if responds(to: Selector(("statusBar"))) {
            return value(forKey: "statusBar") as? UIView
        } else {
            return nil
        }
    }
}
