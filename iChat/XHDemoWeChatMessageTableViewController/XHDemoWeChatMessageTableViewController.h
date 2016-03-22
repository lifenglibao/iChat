//
//  XHDemoWeChatMessageTableViewController.h
//  MessageDisplayExample
//
//  Created by HUAJIE-1 on 14-4-27.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHMessageTableViewController.h"
#import "CommonFunctions.h"
#import "AuxilaryService.h"
@interface XHDemoWeChatMessageTableViewController : XHMessageTableViewController<SRWebSocketDelegate>

- (void)loadDemoDataSource;
@property (nonatomic,strong) NSDictionary *friends_dic;
@property (nonatomic,strong) UIViewController *host;
@property (nonatomic) BOOL isGetLocalChatData;
@property (nonatomic) BOOL isPrivateChat;
@property (nonatomic) BOOL isGroupChat;

@end
