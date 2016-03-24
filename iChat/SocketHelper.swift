//
//  SocketHelper.swift
//  iChat
//
//  Created by iAPPS Pte Ltd on 26/01/16.
//  Copyright © 2016年 iAPPS Pte Ltd. All rights reserved.
//

import Foundation
import UIKit


class SocketHelper: NSObject{
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    internal func socketCMDStatus (cmd:String,object:AnyObject) {
        if (appDelegate.webSocket.readyState == .OPEN){
            if (cmd == CMD_LOGIN) {
                appDelegate.webSocket.send(LOGIN_CMD(object.objectForKey(NAME) as! String, USER_PASSWORD:object.objectForKey(PASS_WORD) as! String, USER_AVATAR:object.objectForKey(AVATAR) as! String))
            }
            
            if (cmd == CMD_GET_FRIENDS) {
                appDelegate.webSocket.send(GET_FRIEND_LIST_CMD(appDelegate.SELF_USER_ID))
            }
            
            if (cmd == CMD_CREATE_GROUP_CHAT) {
                
                var temp = [String]()
                
                for var i = 0; i<appDelegate.GROUP_FRIEND_DATA.count ; i++ {
                    temp.append(appDelegate.GROUP_FRIEND_DATA[i].objectForKey(FRIEND_ID) as! String)
                }
                temp.append(appDelegate.SELF_USER_ID)
                let invite_id = temp.map{String($0)}.joinWithSeparator(",")
                print(invite_id)
                appDelegate.webSocket.send(CREATE_GROUP_CHAT_CMD("test", CHANNAL_ID: 0, SELFS_ID: appDelegate.SELF_USER_ID, INVITE_ID:invite_id, GROUP_AVATAR: ""))
            }
            
        }else{
            CommonFunctions.dismissGlobalHUD()
            CommonFunctions.showAlertWithTitle("Sorry", msg: "Some network error happend,please try later", delegate: self, cancelTitle: "ok")
        }
    }
}