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
    
    
    func isNotStringNull(object:AnyObject) -> Bool {
        if (object.isKindOfClass(NSNull) || Optional(object) == nil || Optional(object)!.isEqualToString("<null>")){
            return false
        }else{
            return true
        }
    }
    
    func checkTableIsExists (database:FMDatabase, tableName:Int)->Bool {

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
    
    func updateAppDelegatChatListData (database:FMDatabase) {
        
        if database.open(){
            do {
                let array = NSMutableArray()
                let sql1 = "select friend_id from chat_list"
                let a = try database.executeQuery(sql1, values: nil)
                while a.next(){
                    let friendId = a.intForColumn("friend_id")
                    array.addObject(NSDictionary(object:NSNumber.init(int: friendId), forKey: FRIEND_ID))
                }
                appDelegate.CHAT_LIST_DATA.removeAllObjects()
            
                for (var i=0; i<array.count; i++){
                    let sql = SELECT_CHAT_LIST(array.objectAtIndex(i).valueForKey(FRIEND_ID)!.integerValue)
                    let s   = try database.executeQuery(sql, values: nil)
                    
                    while s.next(){
                        let friendId = s.intForColumn("user_id")
                        let friendName = s.stringForColumn("user_name")
                        let friendAvatar = s.stringForColumn("avatar")
                        let message = s.stringForColumn("message")
                        let time = s.stringForColumn("create_time")
                        let badge = s.intForColumn("badge")

                        appDelegate.CHAT_LIST_DATA.addObject(NSDictionary(
                            objects: [NSNumber.init(int: friendId),friendName,friendAvatar,message,time,NSNumber.init(int: badge)],
                            forKeys: [FRIEND_ID,FRIEND_NAME,FRIEND_AVATAR,FRIEND_MESSAGE,FRIEND_MESSAGE_CREATE_TIME,FRIEND_MESSAGE_BADGE]))
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
    
    func getChatContentForFriend (database:FMDatabase, friendid:Int)->NSMutableArray {
        
        let array = NSMutableArray()

        if database.open(){
            do {
                let sql = "select * from (SELECT * FROM '\(friendid)' order by id desc limit 10) as v order by id asc;"
                let s   = try database.executeQuery(sql, values: nil)
                
                while s.next(){
                    let type    = s.intForColumn("type")
                    let ststus  = s.intForColumn("status")
                    let message = s.stringForColumn("message")
                    let time    = s.stringForColumn("create_time")
                    
                    array.addObject(NSDictionary(
                        objects: [NSNumber.init(int: ststus), NSNumber.init(int: type),message,time],
                        forKeys: [FRIEND_MESSAGE_STATUS,FRIEND_MESSAGE_TYPE,FRIEND_MESSAGE,FRIEND_MESSAGE_CREATE_TIME]))
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
    
    func updatePrivateChatTable (database:FMDatabase, friendDic:NSDictionary, message:NSString, isSender:Bool, time:NSDate, type:Int) {
        if database.open() {
            do {
                var status = Int()
                if (isSender) {
                    status = 1
                }else{
                    status = 0
                }
                
                let createTime = CommonFunctions.getStringFromDate(time)
                let sql        = CREATE_PRIVATE_CHAT_TABLE(friendDic.objectForKey(FRIEND_ID)!.integerValue)
                let sql2       = UPDATE_PRIVATE_CHAT_TABLE(friendDic.objectForKey(FRIEND_ID)!.integerValue, MESSAGE: message as String, STATUS: status, TIME: createTime, TYPE: type)
                
                if (checkTableIsExists(database, tableName: friendDic.objectForKey(FRIEND_ID)!.integerValue)){
                    try database.executeUpdate(sql2, values: nil)
                    
                }else{
                    try database.executeUpdate(sql, values: nil)
                    try database.executeUpdate(sql2, values: nil)
                }
                
                if (!isAlreadyOnChatListTable(database, friendDic: friendDic)) {
                    let sql3   = UPDATE_CHAT_LIST(friendDic.objectForKey(FRIEND_ID)!.integerValue, IS_SHOW: 1, IS_GROUP: 0)
                    try database.executeUpdate(sql3, values: nil)
                }
                
            } catch let error as NSError {
                print(error.description)
            }
        }else{
            print("database can not open!!!")
        }
    
    }
    
    
    func updateChatListBadgeNumber (database:FMDatabase, friendID:Int, badge:Int) {
        if database.open() {
            do {

                let sql    = UPDATE_CHAT_LIST_FOR_BADGE(badge, CHAT_FRIEND_ID: friendID)
                try database.executeUpdate(sql, values: nil)
                
            } catch let error as NSError {
                print(error.description)
            }
        }else{
            print("database can not open!!!")
        }
    }
    
    func getBadgeNumber (database:FMDatabase, friendDic:NSDictionary)->NSInteger {
        
        var badge = NSInteger()

        if database.open() {
            do {

                let sql    = SELECT_CHAT_LIST_FOR_BADGE(friendDic.objectForKey(FRIEND_ID)!.integerValue)
                let s      = try database.executeQuery(sql, values: nil)
                
                while s.next(){
                    badge  = NSNumber(int: s.intForColumn(FRIEND_MESSAGE_BADGE)).integerValue
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
    func isAlreadyOnChatListTable (database:FMDatabase, friendDic:NSDictionary)->Bool {
        if database.open() {
            do {
                
                var totalCount = Int32()
                
                let sql        = "select count(*) from chat_list where friend_id = '\(friendDic.objectForKey(FRIEND_ID)!.integerValue)'"
                
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
    
    func updateFriendsTable(database:FMDatabase,dataSource:NSMutableArray) {
        
        let tableName = "friends"
        
        if database.open(){
            do {
                
                try database.executeUpdate(DELETE_FRIENDS_LIST_TABLE(tableName), values: nil)
                try database.executeUpdate(RESET_FRIENDS_LIST_TABLE_REFERENCE_COUNT(tableName), values: nil)
                
                for (var i = 0; i<dataSource.count; i++) {
                    
                    try database.executeUpdate(UPDATE_FRIENDS_LIST_TABLE(tableName, INSERT_ID: dataSource.valueForKey("userId")[i].integerValue, INSERT_NAME: dataSource.valueForKey("username")[i].stringValue, INSERT_AVATAR: dataSource.valueForKey("avatar")[i].stringValue), values: nil)
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

}