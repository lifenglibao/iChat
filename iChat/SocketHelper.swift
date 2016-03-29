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
            
            if (cmd == CMD_GET_OFFLINE_MESSAGE) {
                appDelegate.webSocket.send(GET_OFFLINE_MESSAGE(appDelegate.SELF_USER_ID, LAST_MSG_ID: "0"))
            }
            
            if (cmd == CMD_MESSAGE) {
                appDelegate.webSocket.send(SEND_MSG_CHAT_CMD(appDelegate.SELF_USER_ID,
                                                            TO_ID: object.objectForKey(FRIEND_ID) as! String,
                                                          CHANNAL: object.objectForKey("to") as! String,
                                                        CHAT_DATA: object.objectForKey(GL_MESSAGE) as! String,
                                                             TYPE: object.objectForKey(MSG_TYPE_TEXT) as! String))
            }
            
            if (cmd == CMD_CREATE_GROUP_CHAT) {
                
                var temp = [String]()
                
                for var i = 0; i<appDelegate.GROUP_FRIEND_DATA.count ; i++ {
                    temp.append(appDelegate.GROUP_FRIEND_DATA[i].objectForKey(FRIEND_ID) as! String)
                }
                temp.append(appDelegate.SELF_USER_ID)
                let invite_id = temp.map{String($0)}.joinWithSeparator(",")
                appDelegate.webSocket.send(CREATE_GROUP_CHAT_CMD(appDelegate.GROUP_NAME_STRING, CHANNAL_ID: 0, SELFS_ID: appDelegate.SELF_USER_ID, INVITE_ID:invite_id, GROUP_AVATAR: ""))
            }
            
        }else{
            CommonFunctions.dismissGlobalHUD()
            CommonFunctions.showAlertWithTitle("Sorry", msg: "Some network error happend,please try later", delegate: self, cancelTitle: "ok")
        }
    }
}