//
//  LoginViewModel.swift
//  MapTest
//
//  Created by Oleksii Shulzhenko on 28.01.2018.
//  Copyright © 2018 Oleksii Shulzhenko. All rights reserved.
//

import Foundation
import RxSwift

struct LoginViewModel {
    
    let emailText    = Variable<String>("")
    let passwordText = Variable<String>("")
    let nameText     = Variable<String>("")
    
    let isValidLogin:   Observable<Bool>
    let isValidNewUser: Observable<Bool>
    
    init() {
        isValidLogin = Observable.combineLatest(self.emailText.asObservable(), self.passwordText.asObservable())
        { (email, password) in
            return email.count > 0
                && password.count > 0
        }
        
        isValidNewUser = Observable.combineLatest(self.emailText.asObservable(), self.passwordText.asObservable(), self.nameText.asObservable())
        { (email, password, name) in
            return email.count > 0
                && password.count > 0 && name.count > 0
        }
    }
}
