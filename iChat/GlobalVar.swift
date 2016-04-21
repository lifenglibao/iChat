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

//let API_URL = "ws://192.168.1.129:9503/" //test
let API_URL = "ws://52.76.146.143:9501/" //dev

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

let GL_MESSAGE                = "message"
let GL_IS_SENDER              = "is_sender"
let GL_MESSAGE_CREATE_TIME    = "create_time"
let GL_MESSAGE_TYPE           = "type"
let GL_IS_GROUP               = "is_group"
let GL_IS_SHOW                = "is_show"
let GL_GROUP_ID               = "group_id"
let GL_GROUP_NAME             = "group_name"
let GL_MESSAGE_BADGE          = "badge"
let GL_TABLE_NAME             = "table_name"

let SELF_IMG         = "http://img.woyaogexing.com/2015/02/23/648ce6c426d58542!200x200.jpg"
//*****************-- CMD --**************//

let CMD_LOGIN               = "login"
let CMD_GET_FRIENDS         = "getFriendList"
let CMD_CREATE_GROUP_CHAT   = "createGroup"
let CMD_MESSAGE             = "message"
let CMD_FROM_MESSAGE        = "fromMsg"
let CMD_GET_OFFLINE_MESSAGE = "getOfflineMessage"
let CMD_DID_GET_OFFLINE_MESSAGE = "offlineMessage"


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

func GET_FRIEND_LIST_CMD(SELFS_ID:String)->String{
    return "{\"cmd\":\"getFriendList\",\"userId\":\"\(SELFS_ID)\"}"
}

//*****************-- CMD CREATE GROUP CHAT--**************//

func CREATE_GROUP_CHAT_CMD(GROUP_NAME:String, CHANNAL_ID:Int, SELFS_ID:String, INVITE_ID:String, GROUP_AVATAR:String)->String{
    return "{\"cmd\":\"createGroup\",\"channal\":\(CHANNAL_ID),\"name\":\"\(GROUP_NAME)\",\"from\":\"\(SELFS_ID)\",\"inviteUsers\":\"\(INVITE_ID)\",\"avatar\":\"\(GROUP_AVATAR)\"}"
}

//*****************-- CMD SEND MESSAGE--**************//

func SEND_MSG_CHAT_CMD(SELFS_ID:String, TO_ID:String, CHANNAL:String, CHAT_DATA:String,TYPE:String)->String{
    return "{\"cmd\":\"message\",\"from\":\"\(SELFS_ID)\",\"to\":\"\(TO_ID)\",\"channal\":\"\(CHANNAL)\",\"data\":\"\(CHAT_DATA)\",\"type\":\"\(TYPE)\"}"
}

//*****************-- CMD GET OFFLINE MESSAGE--**************//

func GET_OFFLINE_MESSAGE(SELFS_ID:String, LAST_MSG_ID:String)->String{
    return "{\"cmd\":\"getOfflineMessage\",\"userId\":\"\(SELFS_ID)\",\"last_message_id\":\"\(LAST_MSG_ID)\",\"limit\":10000,\"page\":1}"
}


//****************-- DATA BASE --******************//

func CREATE_CHAT_TABLE(TABLE_NAME:String)->String{
    return " CREATE TABLE IF NOT EXISTS '\(TABLE_NAME)' ( 'id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , 'server_msg_id' INTEGER , 'friend_id' INTEGER NOT NULL , 'friend_name' VARCHAR NOT NULL , 'friend_avatar' VARCHAR NOT NULL , 'message' TEXT, 'is_sender' INTEGER NOT NULL , 'create_time' DATETIME NOT NULL , 'type' INTEGER NOT NULL , 'is_group' INTEGER, 'is_show' INTEGER, 'group_id' INTEGER, 'group_name' INTEGER);"
}

func UPDATE_CHAT_TABLE(TABLE_NAME:String, CHAT_FRIEND_ID:String, CHAT_FRIEND_NAME:String, CHAT_FRIEND_AVA:String, MESSAGE:String, IS_SENDER:Int, TIME:String, TYPE:Int, IS_GROUP:Int, IS_SHOW:Int, GROUP_ID:Int, GROUP_NAME:String)->String{
    return " INSERT INTO '\(TABLE_NAME)' ( 'friend_id', 'friend_name', 'friend_avatar', 'message', 'is_sender', 'create_time', 'type', 'is_group', 'is_show', 'group_id', 'group_name') VALUES ( '\(CHAT_FRIEND_ID)', '\(CHAT_FRIEND_NAME)', '\(CHAT_FRIEND_AVA)', '\(MESSAGE)', '\(IS_SENDER)', '\(TIME)', '\(TYPE)', '\(IS_GROUP)', '\(IS_SHOW)', '\(GROUP_ID)', '\(GROUP_NAME)');"
}

func UPDATE_CHAT_BADGE(TABLE_NAME:String, GROUP_ID:Int, GROUP_NAME:String, IS_GROUP:Int, IS_SHOW:Int)->String{
    return " INSERT INTO chat_badge ( 'table_name', 'group_id', 'group_name', 'is_group', 'is_show') VALUES ( '\(TABLE_NAME)', '\(GROUP_ID)', '\(GROUP_NAME)', '\(IS_GROUP)', '\(IS_SHOW)');"
}

func UPDATE_CHAT_BADGE_FOR_BADGE(TABLE_NAME:String, BADGE:Int)->String{
    return " update chat_badge set badge = '\(BADGE)' where table_name = '\(TABLE_NAME)';"
}

func SELECT_CHAT_LIST_FOR_BADGE(TABLE_NAME:String)->String{
    return " SELECT badge from chat_badge WHERE table_name = '\(TABLE_NAME)';"
}

func FIND_CHAT_TABLE(TABLE_NAME:String)->String{
    return " select friend_id, friend_name, friend_avatar, message, is_sender, create_time, type, chat_badge.is_group, chat_badge.is_show, chat_badge.group_id, chat_badge.group_name, badge, chat_badge.table_name from \'\(TABLE_NAME)\' join chat_badge on chat_badge.table_name = \'\(TABLE_NAME)\' where chat_badge.is_show =1 and \'\(TABLE_NAME)\'.is_show =1 order by create_time desc limit 1;"
}

func UPDATE_FRIENDS_LIST_TABLE(TABLE_NAME:String, INSERT_ID:String, INSERT_NAME:String, INSERT_AVATAR:String)->String{
    return " insert into '\(TABLE_NAME)' ( 'user_id', 'user_name', 'avatar') values ( '\(INSERT_ID)', '\(INSERT_NAME)', '\(INSERT_AVATAR)');"
}

func CLEAR_FRIENDS_LIST_TABLE(TABLE_NAME:String)->String{
    return " DELETE FROM \(TABLE_NAME);"
}

//func RESET_FRIENDS_LIST_TABLE_REFERENCE_COUNT(TABLE_NAME:String)->String{
//    return " UPDATE sqlite_sequence set seq = 0 where name = \(TABLE_NAME);"
//}

func GET_FRIEDNS(TABLE_NAME:String)->String{
    return " select user_id, user_name, avatar from \(TABLE_NAME);"
}

func GET_FRIEDNS_BY_ID(TABLE_NAME:String, SEARCH_ID:String)->String{
    return " select user_name, avatar from \(TABLE_NAME) where user_id = \'\(SEARCH_ID)\';"
}

func GET_GROUP_NAME_BY_GROUP_ID(TABLE_NAME:String, SEARCH_ID:Int)->String{
    return " select group_name from \'\(TABLE_NAME)\' where group_id = \(SEARCH_ID);"
}

