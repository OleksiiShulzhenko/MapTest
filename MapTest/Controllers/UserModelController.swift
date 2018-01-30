//
//  UserModelController.swift
//  MapTest
//
//  Created by Oleksii Shulzhenko on 29.01.2018.
//  Copyright © 2018 Oleksii Shulzhenko. All rights reserved.
//

import Foundation
import RxSwift

class UserModelController {
    
    static let share = UserModelController()
    
    let userViewModels = Variable<[UserModel]>([])
    
    func retriveUsers(completionBlock: @escaping (_ success: Bool) -> ()) {
        FirebaseAPI.instance.getUsers { [weak self](users) in
            guard let strongSelf = self else {completionBlock(false); return}
            strongSelf.userViewModels.value = users
            completionBlock(true)
        }
    }
}
