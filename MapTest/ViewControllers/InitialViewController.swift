//
//  InitialViewController.swift
//  MapTest
//
//  Created by Oleksii Shulzhenko on 28.01.2018.
//  Copyright © 2018 Oleksii Shulzhenko. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    
    @IBAction func loginButtonAction(_ sender: UIButton) {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewControllerID") as? LoginViewController {
            if let navController = navigationController {
                navController.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func newAccountButtonAction(_ sender: UIButton) {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewAccountViewControllerID") as? NewAccountViewController {
            if let navController = navigationController {
                navController.pushViewController(viewController, animated: true)
            }
        }
    }
}
