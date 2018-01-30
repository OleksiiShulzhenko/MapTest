//
//  UIViewController+AllertController.swift
//  MapTest
//
//  Created by Oleksii Shulzhenko on 29.01.2018.
//  Copyright © 2018 Oleksii Shulzhenko. All rights reserved.
//

import UIKit

extension UIViewController {
    func showError(_ title: String, message: String, okDidPressed: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
            if let ok = okDidPressed {
                ok()
            }
        })
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
    }
}
