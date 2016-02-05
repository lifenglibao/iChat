//
//  CommenBase.swift
//  iChat
//
//  Created by iAPPS Pte Ltd on 07/01/16.
//  Copyright © 2016年 iAPPS Pte Ltd. All rights reserved.
//

import Foundation
import UIKit

class CommenBase: UIViewController{
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    

    func searchBarBeginEditing(tabBar:UITabBarController) {
        UIView.animateWithDuration(0.2) { () -> Void in
            
            var statusBarFrame = CGRect()
            
            statusBarFrame     = UIApplication.sharedApplication().statusBarFrame
            
            let yDiff = (tabBar.navigationController?.navigationBar.frame.origin.y)! - (tabBar.navigationController?.navigationBar.frame.size.height)! - statusBarFrame.size.height
            
            tabBar.navigationController?.navigationBar.frame = CGRectMake(0, yDiff, self.view.frame.size.width, (tabBar.navigationController?.navigationBar.frame.size.height)!)
            
        }
    }
    
    func searchBarEndEditing(tabBar:UITabBarController) {
        UIView.animateWithDuration(0.2) { () -> Void in
            
            var statusBarFrame = CGRect()
            
            statusBarFrame     = UIApplication.sharedApplication().statusBarFrame
            
            let yDiff = (tabBar.navigationController?.navigationBar.frame.origin.y)! + (tabBar.navigationController?.navigationBar.frame.size.height)! + statusBarFrame.size.height
            
            tabBar.navigationController?.navigationBar.frame = CGRectMake(0, yDiff, self.view.frame.size.width, (tabBar.navigationController?.navigationBar.frame.size.height)!)
            
        }
    }
    
    func customNavBarItem(_class:AnyClass,tabBar:UITabBarController,tar:NSObject,ac:Selector) {
        
        if (_class.description() == "iChat.MainChat") {
            tabBar.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .Add, target: tar, action: ac)
            return
        }
        
        if (_class.description() == "iChat.MainAboutMe") {
            tabBar.navigationItem.rightBarButtonItem = nil
            return
        }
        
        if (_class.description() == "iChat.ContactsList") {
            tabBar.navigationItem.rightBarButtonItem = nil
            return
        }
    }
    
    
}