//
//  SourceHelper.swift
//  iChat
//
//  Created by iAPPS Pte Ltd on 06/01/16.
//  Copyright © 2016年 iAPPS Pte Ltd. All rights reserved.
//

import Foundation
import UIKit


class SourceHelper: NSObject{

    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var database    = FMDatabase.init(path: (UIApplication.sharedApplication().delegate as! AppDelegate).getdestinationPath())
    
    func post(params : Dictionary<String, String>, url : String, postCompleted : (succeeded: Bool, msg: String) -> ()) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        print(params)
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            print(request)

        } catch let error as NSError {
            
            print(error.description)
        }
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            print("Response: \(response)")
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")

            do {
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary {
                    if let success = json["success"] as? Bool {
                        print("Succes: \(success)")
                        postCompleted(succeeded: success, msg: "Success")
                    }
                } else {
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Error could not parse JSON: \(jsonStr)")
                    postCompleted(succeeded: false, msg: "Error")
                }
            } catch let err as NSError {
                print(err.localizedDescription)
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: '\(jsonStr)'")
                postCompleted(succeeded: false, msg: "Error")

            }
        })
        
        task.resume()
    }
    
    func getProfileConfigureArray()->NSMutableArray {
        
        let profiles = NSMutableArray.init(capacity: 1)
        let titleKey = "title"
        let imageKey = "image"
        
        let userInfoDictionary = NSMutableDictionary.init(objects: ["LF","15539518006","icon"], forKeys: [titleKey,"WeChatNumber",imageKey])
        profiles.addObject(userInfoDictionary)
        
        let rows = NSMutableArray()
        for var i = 0; i < 2; i++ {
            var title = NSString()
            var imageName = NSString()
            
            switch i {
            case 0:
                title = "我的收藏"
                imageName = "MoreMyFavorites"
                break
            case 1:
                title = "我的银行卡"
                imageName = "MoreMyBankCard"
                break
            default:
                break
                
            }
            
            let sectionDictionary = NSMutableDictionary.init(objects: [title,imageName], forKeys: [titleKey,imageKey])
            rows.addObject(sectionDictionary)
        }
        profiles.addObject(rows)
        profiles.addObject(NSMutableDictionary.init(objects: ["设置","MoreSetting"], forKeys: [titleKey,imageKey]))
        
        return profiles
    }
    
    
    func isNotNull(object:AnyObject) -> Bool {
        if (object.isKindOfClass(NSNull) || Optional(object) == nil || Optional(object)!.isEqualToString("<null>") || Optional(object)!.isEqualToString("")){
            return false
        }else{
            return true
        }
    }
    
    func checkTableIsExists (tableName:String)->Bool {

        var totalCount = Int32()
        if database.open(){
            do {

                let sql = " SELECT COUNT(*) FROM sqlite_master where type = 'table' and name = '\(tableName)';"
                let s   = try database.executeQuery(sql, values: nil)
                
                while s.next(){
                    totalCount = s.intForColumnIndex(0)
                }
                s.close()
                
            } catch let error as NSError {
                print(error.description)
            }

        }else{
            print("database can not open!!!")
        }
        
        print(totalCount)
        if totalCount>0{
            return true
        }else{
            return false
        }

    }
    
    func updateAppDelegatChatListData () {
        
        if database.open(){
            do {
                let array = NSMutableArray()
                let sql1 = "select table_name from chat_badge"
                let a = try database.executeQuery(sql1, values: nil)
                while a.next(){
                    let table_name = a.stringForColumn(GL_TABLE_NAME)
                    array.addObject(NSDictionary(object:table_name, forKey: GL_TABLE_NAME))
                }
                appDelegate.CHAT_LIST_DATA.removeAllObjects()

                for (var i=0; i<array.count; i++){

                    let sql = FIND_CHAT_TABLE(array.objectAtIndex(i).valueForKey(GL_TABLE_NAME) as! String)
                    let s   = try database.executeQuery(sql, values: nil)
                    
                    while s.next(){
                        let friendId        = s.stringForColumn(FRIEND_ID)
                        let friendName      = s.stringForColumn(FRIEND_NAME)
                        let friendAvatar    = s.stringForColumn(FRIEND_AVATAR)
                        let message         = s.stringForColumn(GL_MESSAGE)
                        let is_sender       = s.stringForColumn(GL_IS_SENDER)
                        let time            = s.stringForColumn(GL_MESSAGE_CREATE_TIME)
                        let type            = s.stringForColumn(GL_MESSAGE_TYPE)
                        let is_group        = s.stringForColumn(GL_IS_GROUP)
                        let is_show         = s.stringForColumn(GL_IS_SHOW)
                        let group_id        = s.stringForColumn(GL_GROUP_ID)
                        let group_name      = s.stringForColumn(GL_GROUP_NAME)
                        let badge           = s.stringForColumn(GL_MESSAGE_BADGE)
                        let table_name      = s.stringForColumn(GL_TABLE_NAME)

                        appDelegate.CHAT_LIST_DATA.addObject(NSDictionary(
                            objects:    [friendId,
                                        friendName,
                                        friendAvatar,
                                        message,
                                        is_sender,
                                        time,
                                        type,
                                        is_group,
                                        is_show,
                                        group_id,
                                        group_name,
                                        badge,
                                        table_name],
                            forKeys:
                                        [FRIEND_ID,
                                        FRIEND_NAME,
                                        FRIEND_AVATAR,
                                        GL_MESSAGE,
                                        GL_IS_SENDER,
                                        GL_MESSAGE_CREATE_TIME,
                                        GL_MESSAGE_TYPE,
                                        GL_IS_GROUP,
                                        GL_IS_SHOW,
                                        GL_GROUP_ID,
                                        GL_GROUP_NAME,
                                        GL_MESSAGE_BADGE,
                                        GL_TABLE_NAME]))
                    }
                    s.close()
                }
                NSLog("Those data will be create on chat list page:\n------ %@",appDelegate.CHAT_LIST_DATA);
                
            } catch let error as NSError {
                print(error.description)
            }
        }else{
            print("database can not open!!!")
        }

    }
    
    func getChatContentForFriend (tableName:String)->NSMutableArray {
        
        let array = NSMutableArray()

        if database.open(){
            do {
                let sql = "select * from (SELECT * FROM '\(tableName)' order by id desc limit 10) as v order by id asc;"
                let s   = try database.executeQuery(sql, values: nil)
                
                while s.next(){
                    let friend_id   = s.stringForColumn(FRIEND_ID)
                    let friend_name = s.stringForColumn(FRIEND_NAME)
                    let friend_ava  = s.stringForColumn(FRIEND_AVATAR)
                    let message     = s.stringForColumn(GL_MESSAGE)
                    let is_sender   = s.stringForColumn(GL_IS_SENDER)
                    let time        = s.stringForColumn(GL_MESSAGE_CREATE_TIME)
                    let type        = s.stringForColumn(GL_MESSAGE_TYPE)
                    let is_group    = s.stringForColumn(GL_IS_GROUP)
                    let is_show     = s.stringForColumn(GL_IS_SHOW)
                    let group_id    = s.stringForColumn(GL_GROUP_ID)
                    let group_name  = s.stringForColumn(GL_GROUP_NAME)

                    array.addObject(NSDictionary(
                        objects: [friend_id,
                                friend_name,
                                 friend_ava,
                                    message,
                                  is_sender,
                                       time,
                                       type,
                                   is_group,
                                    is_show,
                                   group_id,
                                 group_name],
                        
                        forKeys: [FRIEND_ID,
                                FRIEND_NAME,
                              FRIEND_AVATAR,
                                 GL_MESSAGE,
                               GL_IS_SENDER,
                     GL_MESSAGE_CREATE_TIME,
                            GL_MESSAGE_TYPE,
                                GL_IS_GROUP,
                                 GL_IS_SHOW,
                                GL_GROUP_ID,
                              GL_GROUP_NAME]))
                }
                
                s.close()

            } catch let error as NSError {
                print(error.description)
            }
        }else{
            print("database can not open!!!")
        }
        return array
    }
    
    func updateChatTable (tableName:NSString, friendID:NSString, message:NSString, isSender:Bool, time:NSDate, type:Int, isGroup:Bool, isShow:Bool, groupID:Int, groupName:String) {
        if database.open() {
            do {
                var is_sender = Int()
                var is_group  = Int()
                var is_show   = Int()
                
                is_sender     = isSender ? 1 : 0
                is_group      = isGroup ? 1 : 0
                is_show       = isShow ? 1 : 0
                
                let createTime = CommonFunctions.getStringFromDate(time)
                let sql        = CREATE_CHAT_TABLE(tableName as String)
                let friendData = getFriendsByID(friendID as String)
                let name       = friendData.count > 0 ? friendData[0].objectForKey(FRIEND_NAME) as! String : ""
                let avatar     = friendData.count > 0 ? friendData[0].objectForKey(FRIEND_AVATAR) as! String : ""

                let sql2       = UPDATE_CHAT_TABLE(tableName as String,
                    CHAT_FRIEND_ID: friendID as String,
                    CHAT_FRIEND_NAME: name,
                    CHAT_FRIEND_AVA: avatar,
                    MESSAGE: message as String,
                    IS_SENDER: is_sender,
                    TIME: createTime,
                    TYPE: type,
                    IS_GROUP: is_group,
                    IS_SHOW: is_show,
                    GROUP_ID: groupID,
                    GROUP_NAME: groupName)
                
                if (checkTableIsExists(tableName as String)){
                    try database.executeUpdate(sql2, values: nil)
                    
                }else{
                    try database.executeUpdate(sql, values: nil)
                    try database.executeUpdate(sql2, values: nil)
                }
                
                if (!isAlreadyOnChatListTable(tableName as String)) {
                    let sql3   = UPDATE_CHAT_BADGE(tableName as String, GROUP_ID: groupID, GROUP_NAME: groupName, IS_GROUP: is_group, IS_SHOW: is_show)
                    try database.executeUpdate(sql3, values: nil)
                }

                
            } catch let error as NSError {
                print(error.description)
            }
        }else{
            print("database can not open!!!")
        }
    
    }
    
    func updateChatBadgeNumber (tableName:String, badge:Int) {
        if database.open() {
            do {

                let sql    = UPDATE_CHAT_BADGE_FOR_BADGE(tableName, BADGE: badge)
                try database.executeUpdate(sql, values: nil)
                
            } catch let error as NSError {
                print(error.description)
            }
        }else{
            print("database can not open!!!")
        }
    }
    
    func getBadgeNumber (tableName:String)->String {
        
        var badge = String()

        if database.open() {
            do {

                let sql    = SELECT_CHAT_LIST_FOR_BADGE(tableName)
                let s      = try database.executeQuery(sql, values: nil)
                
                while s.next(){
                    badge  = s.stringForColumn(GL_MESSAGE_BADGE)
                }
                
            } catch let error as NSError {
                print(error.description)
            }
        }else{
            print("database can not open!!!")
        }
        
        print("-----now badge is ----\n\(badge)")
        return badge
    }
    func isAlreadyOnChatListTable (tableName:String)->Bool {
        if database.open() {
            do {
                
                var totalCount = Int32()

                let sql        = "select count(*) from chat_badge where table_name = '\(tableName)'"
                
                let s          = try database.executeQuery(sql, values: nil)
                
                while s.next(){
                    totalCount = s.intForColumnIndex(0)
                }
                s.close()
                
                if totalCount>0 {
                    return true
                }else{
                    return false
                }
                
                
            } catch let error as NSError {
                print(error.description)
            }
        }else{
            print("database can not open!!!")
        }
        
        return false
    }
    
    func updateFriendsTable(dataSource:NSMutableArray) {
        
        let tableName = "friends"
        
        if database.open(){
            do {
                
                try database.executeUpdate(CLEAR_FRIENDS_LIST_TABLE(tableName), values: nil)
                
                for (var i = 0; i<dataSource.count; i++) {
                    
                    let name = isNotNull(dataSource[i].valueForKey("username")!) ? dataSource[i].valueForKey("username") as! String : ""
                    let avatar = isNotNull(dataSource[i].valueForKey("avatar")!) ? dataSource[i].valueForKey("avatar") as! String : ""
                    try database.executeUpdate(UPDATE_FRIENDS_LIST_TABLE(
                        tableName,
                        INSERT_ID: dataSource[i].valueForKey("userId") as! String,
                        INSERT_NAME: name,
                        INSERT_AVATAR: avatar),
                        values: nil)
                }
                print("Friends Table table has updated !!!!")
                database.close()
            } catch let error as NSError {
                database.close()
                print("failed: \(error.localizedDescription)")
            }
        }else{
            print("database can not open!!!")
        }
    }

    func getFriends()->NSMutableArray {
        
        let tableName = "friends"
        let array = NSMutableArray()

        if database.open(){
            do {
                
                let s = try database.executeQuery(GET_FRIEDNS(tableName), values: nil)
                
                while s.next(){
                    let friend_avatar = s.stringForColumn("avatar")
                    let friend_name   = s.stringForColumn("user_name")
                    let friend_id     = s.stringForColumn("user_id")
                    
                    array.addObject(NSDictionary(
                        objects: [friend_id, friend_avatar,friend_name],
                        forKeys: [FRIEND_ID,FRIEND_AVATAR,FRIEND_NAME]))
                }
                database.close()
            } catch let error as NSError {
                database.close()
                print("failed: \(error.localizedDescription)")
            }
        }else{
            print("database can not open!!!")
        }
        return array
    }
    
    func getFriendsByID(friend_id:String)->NSMutableArray {
        
        let tableName = "friends"
        let array = NSMutableArray()
        
        if database.open(){
            do {
                
                let s = try database.executeQuery(GET_FRIEDNS_BY_ID(tableName, SEARCH_ID: friend_id), values: nil)
                
                while s.next(){
                    let friend_avatar = s.stringForColumn("avatar")
                    let friend_name   = s.stringForColumn("user_name")
//                    let friend_id     = s.intForColumn("user_id")
                    
                    array.addObject(NSDictionary(
                        objects: [friend_avatar,friend_name],
                        forKeys: [FRIEND_AVATAR,FRIEND_NAME]))
                }
                database.close()
            } catch let error as NSError {
                database.close()
                print("failed: \(error.localizedDescription)")
            }
        }else{
            print("database can not open!!!")
        }
        return array
    }
    
    func getGroupNameByGroupID(groupID:Int)->String {
        
        let tableName = "chat_badge"
        var str = String()
        
        if database.open(){
            do {
                let s = try database.executeQuery(GET_GROUP_NAME_BY_GROUP_ID(tableName, SEARCH_ID: groupID), values: nil)
                
                while s.next(){
                    str = s.stringForColumn(GL_GROUP_NAME)
                }
                database.close()
            } catch let error as NSError {
                database.close()
                print("failed: \(error.localizedDescription)")
            }
        }else{
            print("database can not open!!!")
        }
        return str
    }
}