//
//  newAccountViewController.swift
//  MapTest
//
//  Created by Oleksii Shulzhenko on 28.01.2018.
//  Copyright © 2018 Oleksii Shulzhenko. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class NewAccountViewController: BaseLoginViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.rx.text
            .orEmpty
            .bind(to: viewModel.nameText)
            .disposed(by: disposeBag)
        
        viewModel.isValidNewUser.map { $0 }
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.isValidNewUser.subscribe(onNext: { [weak self](isValid) in
            self?.isEnableLable.text = isValid ? "Enabled" : "Not Enabled"
            self?.isEnableLable.textColor = isValid ? .green : .red
        }).disposed(by: disposeBag)
    }
    
    @IBAction func loginButtonAction(_ sender: UIButton) {
        FirebaseAPI.instance.newUser(withEmail: viewModel.emailText.value, password: viewModel.passwordText.value, name: viewModel.nameText.value) { [weak self](success, errorString) in
            guard let strongSelf = self else {return}
            if !success {
                strongSelf.showError("Error", message: errorString, okDidPressed: {})
            } else {
                if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewControllerID") as? MapViewController {
                    if let navController = strongSelf.navigationController {
                        navController.pushViewController(viewController, animated: true)
                        strongSelf.nameTextField.text      = ""
                        strongSelf.passwordTextField.text  = ""
                        strongSelf.emailTectField.text     = ""
                    }
                }
            }
        }
    }
}
