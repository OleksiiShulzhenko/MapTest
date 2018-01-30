//
//  UserModelController.swift
//  MapTest
//
//  Created by Oleksii Shulzhenko on 29.01.2018.
//  Copyright © 2018 Oleksii Shulzhenko. All rights reserved.
//

import Foundation

class UserModelController {
    
    static let share = UserModelController()
    
    var userViewModels: [UserModel] = []
    
    func retriveUsers(completionBlock: @escaping (_ success: Bool) -> ()) {
        FirebaseAPI.instance.getUsers { [weak self](users) in
            guard let strongSelf = self else {completionBlock(false); return}
            let uss = users.filter({ (model) -> Bool in
                return model.coordinate.value != nil
            })
            strongSelf.userViewModels = uss
            completionBlock(true)
        }
    }
    
    func observeChangeUsers(completionBlock: @escaping (_ success: Bool) -> ()) {
        FirebaseAPI.instance.observeChangeUsers { [weak self](changedUsers) in
            guard let strongSelf = self else {completionBlock(false); return}
            for changedUser in changedUsers {
                guard changedUser.coordinate.value != nil else {continue}
                for user in strongSelf.userViewModels {
                    if changedUser.userID.value == user.userID.value {
                        user.coordinate.value = changedUser.coordinate.value
                        break
                    }
                }
            }
            completionBlock(true)
        }
    }
    
    func observeNewUsers(completionBlock: @escaping (_ success: Bool) -> ()) {
        FirebaseAPI.instance.observeNewUsers { [weak self](newUsers) in
            guard let strongSelf = self else {completionBlock(false); return}
            let nuss = newUsers.filter({ (model) -> Bool in
                return model.coordinate.value != nil
            })
            strongSelf.userViewModels.append(contentsOf: nuss)
            completionBlock(true)
        }
    }
}
