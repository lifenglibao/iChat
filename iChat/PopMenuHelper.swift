//
//  PopMenuHelper.swift
//  iChat
//
//  Created by iAPPS Pte Ltd on 07/01/16.
//  Copyright © 2016年 iAPPS Pte Ltd. All rights reserved.
//

import Foundation
import UIKit


class PopMenuHelper: NSObject{

    var popMenu  = XHPopMenu?()

    func initPopMenus () ->XHPopMenu {
        if (popMenu == nil) {
            let popMenuItems = NSMutableArray.init(capacity: 5)
            for var i = 0; i<4; i++ {
                var imageName = NSString()
                var title     = NSString()
                
                switch (i) {
                case 0:
                    imageName = "contacts_add_newmessage"
                    title = "发起群聊"
                    break
                    
                case 1:
                    imageName = "contacts_add_friend"
                    title = "添加朋友"
                    break
                    
                case 2:
                    imageName = "contacts_add_scan"
                    title = "扫一扫"
                    break
                    
                case 3:
                    imageName = "contacts_add_photo"
                    title = "拍照分享"
                    break
                    
                default:
                    break
                }
                
                let popMenuItem = XHPopMenuItem.init(image: UIImage(named: imageName as String), title: title as String)
                popMenuItems.addObject(popMenuItem)
            }
            
            weak var weakSelf = self
            popMenu = XHPopMenu.init(menus: popMenuItems as [AnyObject])
            
            popMenu?.popMenuDidSlectedCompled = {
                ind,men in
                if (ind == 2){
                    
                }else if (ind == 0){
                    
                }
            }
        }
        return popMenu!
    }

}