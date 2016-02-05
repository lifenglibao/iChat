//
//  ViewController.swift
//  iChat
//
//  Created by iAPPS Pte Ltd on 05/01/16.
//  Copyright © 2016年 iAPPS Pte Ltd. All rights reserved.
//

import UIKit

class ViewController: UITabBarController {
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.sharedApplication().statusBarStyle = .LightContent

        if (!appDelegate.IS_LOGIN) {
            let vc = GET_VIEW_CONTROLLER("LoginViewController")
            self.navigationController?.presentViewController(vc, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

