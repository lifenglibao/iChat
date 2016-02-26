//
//  GlobalVar.swift
//  iChat
//
//  Created by iAPPS Pte Ltd on 05/01/16.
//  Copyright © 2016年 iAPPS Pte Ltd. All rights reserved.
//

import Foundation
import UIKit

let sourceHelper = SourceHelper()
let popMenuHelper = PopMenuHelper()
let commenBase = CommenBase()
let socketHelper = SocketHelper()


//*****************-- API LINK --**************//

let API_URL = "ws://192.168.1.111:9503/"

//*****************-- STATUS CODE --**************//

let STATUS_CODE_SUCCESS_LOGIN   = 1010
let STATUS_CODE_FAILED_LOGIN    = 1022
let STATUS_CODE_SUCCESS_FRIEND  = 1030

//*****************-- CONSTANS --**************//

let NAME             = "username"
let PASS_WORD        = "userpass"
let USER_ID          = "userId"
let ID               = "id"
let AVATAR           = "avatar"
let MSG_TYPE_TEXT    = "text"

let FRIEND_ID        = "friend_id"
let FRIEND_NAME      = "friend_name"
let FRIEND_AVATAR    = "friend_avatar"
let FRIEND_MESSAGE   = "message"
let FRIEND_MESSAGE_CREATE_TIME    = "create_time"
let FRIEND_MESSAGE_TYPE           = "type"
let FRIEND_MESSAGE_STATUS         = "status"
let FRIEND_MESSAGE_BADGE          = "badge"

let SELF_IMG         = "http://img.woyaogexing.com/2015/02/23/648ce6c426d58542!200x200.jpg"
//*****************-- CMD --**************//

let CMD_LOGIN        = "login"
let CMD_GET_FRIENDS  = "getFriendList"
let CMD_GROUP_CHAT   = "createGroup"
let CMD_PRIVATE_CHAT = "message"


//*****************-- GET VIEW CONTROLLER FROM STORY BOARD --**************//


func GET_VIEW_CONTROLLER(identifier:String)->UIViewController {
    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    return mainStoryboard.instantiateViewControllerWithIdentifier(identifier)
}

//*****************-- OVERRIDE UICOLOR --**************//

func RGBA_ALPHA (R:CGFloat, G:CGFloat, B:CGFloat, A:CGFloat)->UIColor {
    return UIColor.init(red: R/255.0, green: G/255.0, blue:  B/255.0, alpha: A)
}


//*****************-- CMD LOGIN--**************//


func LOGIN_CMD(USER_NAME:String, USER_PASSWORD:String, USER_AVATAR:String)->String{
    return "{\"cmd\":\"login\",\"username\":\"\(USER_NAME)\",\"userpass\":\"\(USER_PASSWORD)\",\"avatar\":\"\(USER_AVATAR)\"}"
}

//*****************-- CMD GET FRIEND LIST --**************//

func GET_FRIEND_LIST_CMD(SELFS_ID:Int)->String{
    return "{\"cmd\":\"getFriendList\",\"userId\":\(SELFS_ID)}"
}

//*****************-- CMD CREATE GROUP CHAT--**************//

func CREATE_GROUP_CHAT_CMD(GROUP_NAME:String, SELFS_ID:Int,INVITE_ID:String)->String{
    return "{\"cmd\":\"createGroup\",\"channal\":0,\"name\":\"\(GROUP_NAME)\",\"from\":\(SELFS_ID),\"inviteUsers\":\"\(INVITE_ID)\"}"
}

//*****************-- CMD CREATE PRIVATE CHAT--**************//

func CREATE_PRIVATE_CHAT_CMD(SELFS_ID:Int, TO_ID:Int,CHAT_DATA:String,TYPE:String)->String{
    return "{\"cmd\":\"message\",\"from\":\(SELFS_ID),\"to\":\(TO_ID),\"channal\":0,\"data\":\"\(CHAT_DATA)\",\"type\":\"\(TYPE)\"}"
}



//****************-- DATA BASE --******************//

func CREATE_PRIVATE_CHAT_TABLE(CHAT_FRIEND_ID:Int)->String{
    return " CREATE TABLE IF NOT EXISTS '\(CHAT_FRIEND_ID)' ( 'id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , 'message' TEXT NOT NULL , 'status' INTEGER NOT NULL , 'create_time' DATETIME NOT NULL ,'type' INTEGER NOT NULL);"
}

func UPDATE_PRIVATE_CHAT_TABLE(CHAT_FRIEND_ID:Int, MESSAGE:String, STATUS:Int, TIME:String, TYPE:Int)->String{
    return " INSERT INTO '\(CHAT_FRIEND_ID)' ( 'message', 'status', 'create_time', 'type') VALUES ( '\(MESSAGE)', '\(STATUS)', '\(TIME)', '\(TYPE)');"
}

func UPDATE_CHAT_LIST(CHAT_FRIEND_ID:Int, IS_SHOW:Int, IS_GROUP:Int)->String{
    return " INSERT INTO 'chat_list' ( 'friend_id', 'is_show', 'is_group') VALUES ('\(CHAT_FRIEND_ID)', '\(IS_SHOW)', '\(IS_GROUP)');"
}

func UPDATE_CHAT_LIST_FOR_BADGE(BADGE:Int, CHAT_FRIEND_ID:Int)->String{
    return " UPDATE chat_list SET badge = \(BADGE) WHERE friend_id = \(CHAT_FRIEND_ID);"
}

func SELECT_CHAT_LIST_FOR_BADGE(CHAT_FRIEND_ID:Int)->String{
    return " SELECT badge from chat_list WHERE friend_id = \(CHAT_FRIEND_ID);"
}

func SELECT_CHAT_LIST(CHAT_TABLE_ID:Int)->String{
    return " select user_id, user_name, avatar, message, create_time, badge from friends join chat_list on friends.user_id = chat_list.friend_id join '\(CHAT_TABLE_ID)' ON friends.user_id = '\(CHAT_TABLE_ID)' where is_show =1 order by create_time desc limit 1;"
}

func UPDATE_FRIENDS_LIST_TABLE(TABLE_NAME:String, INSERT_ID:Int, INSERT_NAME:String, INSERT_AVATAR:String)->String{
    return " insert into '\(TABLE_NAME)' ( 'user_id', 'user_name', 'avatar') values ( '\(INSERT_ID)', '\(INSERT_NAME)', '\(INSERT_AVATAR)');"
}

func DELETE_FRIENDS_LIST_TABLE(TABLE_NAME:String)->String{
    return " DELETE FROM \(TABLE_NAME);"
}

func RESET_FRIENDS_LIST_TABLE_REFERENCE_COUNT(TABLE_NAME:String)->String{
    return " UPDATE sqlite_sequence set seq = 0 where name = \(TABLE_NAME);"
}

