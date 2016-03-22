//
//  Constans.h
//  iChat
//
//  Created by iAPPS Pte Ltd on 22/01/16.
//  Copyright © 2016年 iAPPS Pte Ltd. All rights reserved.
//

#ifndef Constans_h
#define Constans_h


#endif /* Constans_h */

//*****************-- API LINK --**************//

#define API_URL @"ws://192.168.1.111:9503/" //test
//#define API_URL @"ws://52.76.146.143:9501/" //dev

//*****************-- STATUS CODE --**************//

#define STATUS_CODE_SUCCESS_LOGIN   = 1010
#define STATUS_CODE_FAILED_LOGIN    = 1022
#define STATUS_CODE_SUCCESS_FRIEND  = 1030

//*****************-- CONSTANS --**************//

#define NAME            @"username"
#define PASS_WORD       @"userpass"
#define USER_ID         @"userId"
#define ID              @"id"
#define AVATAR          @"avatar"
#define MSG_TYPE_TEXT   @"text"

#define FRIEND_ID       @"friend_id"
#define FRIEND_NAME     @"friend_name"
#define FRIEND_AVATAR   @"friend_avatar"

#define GL_MESSAGE                  @ "message"
#define GL_MESSAGE_CREATE_TIME      @ "create_time"
#define GL_MESSAGE_TYPE             @ "type"
#define GL_IS_SENDER                @ "is_sender"
#define GL_IS_GROUP                 @ "is_group"
#define GL_IS_SHOW                  @ "is_show"
#define GL_GROUP_ID                 @ "group_id"
#define GL_GROUP_NAME               @ "group_name"
#define GL_MESSAGE_BADGE            @ "badge"
#define GL_TABLE_NAME               @ "table_name"


//*****************-- CMD --**************//

#define CMD_LOGIN               @ "login"
#define CMD_GET_FRIENDS         @ "getFriendList"
#define CMD_CREATE_GROUP_CHAT   @ "createGroup"
#define CMD_MESSAGE             @ "message"
#define CMD_FROM_MESSAGE        @ "fromMsg"


//*****************-- OVERRIDE UICOLOR --**************//

#ifndef RGB
#define RGB(R,G,B) [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:1.0f]
#endif

#ifndef RGBALPHA
#define RGBALPHA(R,G,B,A) [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:A]
#endif

//*****************-- CMD LOGIN--**************//

#define LOGIN_CMD(USER_NAME,USER_PASSWORD,USER_AVATAR) [NSString stringWithFormat:@"{\"cmd\":\"login\",\"username\":\"%@\",\"userpass\":\"%@\",\"avatar\":\"%@\"}",USER_NAME,USER_PASSWORD,USER_AVATAR]

//*****************-- CMD GET FRIEND LIST --**************//

#define GET_FRIEND_LIST_CMD(SELFS_ID) [NSString stringWithFormat:@" {\"cmd\":\"getFriendList\",\"userId\":%d}",SELFS_ID]

//*****************-- CMD CREATE GROUP CHAT--**************//

#define CREATE_GROUP_CHAT_CMD(GROUP_NAME,SELFS_ID,INVITE_ID) [NSString stringWithFormat:@" {\"cmd\":\"createGroup\",\"channal\":0,\"name\":\"%@\",\"from\":%d,\"inviteUsers\":\"%@\"}",GROUP_NAME,SELFS_ID,INVITE_ID]

//*****************-- CMD CREATE PRIVATE CHAT--**************//

#define CREATE_PRIVATE_CHAT_CMD(SELFS_ID,TO_ID,CHAT_DATA,TYPE) [NSString stringWithFormat:@" {\"cmd\":\"message\",\"from\":%ld,\"to\":%ld,\"channal\":0,\"data\":\"%@\",\"type\":\"%@\"}",SELFS_ID,TO_ID,CHAT_DATA,TYPE]


//****************-- DATA BASE --******************//
#define CREATE_PRIVATE_CHAT_TABLE(CHAT_FRIEND_ID) [NSString stringWithFormat:@" CREATE TABLE '%ld' ( 'id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , 'message' TEXT NOT NULL , 'status' INTEGER NOT NULL , 'create_time' DATETIME NOT NULL ,'type' INTEGER NOT NULL);",CHAT_FRIEND_ID]

#define UPDATE_PRIVATE_CHAT_TABLE(CHAT_FRIEND_ID,MESSAGE,STATUS,TIME,TYPE) [NSString stringWithFormat:@" INSERT INTO '%ld' ( 'message', 'status', 'create_time', 'type') VALUES ( '%@', '%d', '%@', '%d');",CHAT_FRIEND_ID,MESSAGE,STATUS,TIME,TYPE]

#define UPDATE_CHAT_LIST(CHAT_FRIEND_ID,IS_SHOW,IS_GROUP) [NSString stringWithFormat:@" INSERT INTO 'chat_list' ( 'friend_id', 'is_show', 'is_group') VALUES ('%ld', '%d', '%d');", CHAT_FRIEND_ID,IS_SHOW,IS_GROUP]

#define SELECT_CHAT_LIST(CHAT_TABLE_ID,CHAT_FRIEND_ID) [NSString stringWithFormat:@"select user_id, user_name, avatar, message, create_time from friends join chat_list on friends.user_id = chat_list.friend_id join '%ld' ON friends.user_id = '%ld' where is_show =1 order by create_time desc limit 1;",CHAT_TABLE_ID,CHAT_FRIEND_ID]

