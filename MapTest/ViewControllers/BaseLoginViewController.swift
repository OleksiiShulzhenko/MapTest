//
//  BaseLoginViewController.swift
//  MapTest
//
//  Created by Oleksii Shulzhenko on 28.01.2018.
//  Copyright © 2018 Oleksii Shulzhenko. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class BaseLoginViewController: UIViewController {
    
    @IBOutlet weak var scrollableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailTextFieldTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTectField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var isEnableLable: UILabel!
    
    let disposeBag = DisposeBag()
    
    let viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTectField.rx.text
            .orEmpty
            .bind(to: viewModel.emailText)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text
            .orEmpty
            .bind(to: viewModel.passwordText)
            .disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        emailTextFieldTopConstraint.constant = self.view.frame.height / 3
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func keyboardWillShow(notification:NSNotification){
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        scrollableViewHeightConstraint.constant = self.view.frame.height + keyboardFrame.height
        scrollView.layoutIfNeeded()
        
//        var contentInset:UIEdgeInsets = self.scrollView.contentInset
//        contentInset.bottom = delta
//        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        
        scrollableViewHeightConstraint.constant = self.view.frame.height
        scrollView.layoutIfNeeded()
    }
}

