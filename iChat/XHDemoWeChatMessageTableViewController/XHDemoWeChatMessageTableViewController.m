//
//  XHDemoWeChatMessageTableViewController.m
//  MessageDisplayExample
//
//  Created by HUAJIE-1 on 14-4-27.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//


#import "XHDemoWeChatMessageTableViewController.h"

#import "XHDisplayTextViewController.h"
#import "XHDisplayMediaViewController.h"
#import "XHDisplayLocationViewController.h"

#import "XHAudioPlayerHelper.h"
#import "iChat-Swift.h"
#import <SDWebImage/UIImageView+WebCache.h>
//#import "XHContactDetailTableViewController.h"


@interface XHDemoWeChatMessageTableViewController () <XHAudioPlayerHelperDelegate>

@property (nonatomic, strong) NSArray *emotionManagers;

@property (nonatomic, strong) XHMessageTableViewCell *currentSelectedCell;
@property (nonatomic, strong) SRWebSocket *webSocket;
@property (nonatomic, strong) NSDictionary *receivedDataFromSocket;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) FMDatabase * fmDataBase;
@property (nonatomic, strong) SourceHelper * sourceHelper;
@property (nonatomic, strong) NSMutableArray * localChatData;

@end

@implementation XHDemoWeChatMessageTableViewController


- (void)didGetText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date {

    XHMessage *textMessage = [[XHMessage alloc] initWithText:text sender:sender timestamp:date];
    UIImageView * imgV = [[UIImageView alloc] init];
    
    [imgV sd_setImageWithURL:
     [NSURL URLWithString:
      [NSString stringWithFormat:@"%@", _friends_dic ? [_friends_dic objectForKey:FRIEND_AVATAR] : [_receivedDataFromSocket objectForKey:AVATAR]]]];
    
    textMessage.avatar = imgV.image;
    
    textMessage.bubbleMessageType = XHBubbleMessageTypeReceiving;
    [self getMsgFromFriends:textMessage];

    if (!_isGetLocalChatData) {
        
        if (_friends_dic!=nil || _receivedDataFromSocket!=nil) {
            
            [_sourceHelper updateChatTable:_fmDataBase
                                 tableName:[_friends_dic objectForKey:FRIEND_ID]
                                  friendID:[[_friends_dic objectForKey:FRIEND_ID] integerValue]
                                   message:text
                                  isSender:false
                                      time:date
                                      type:0
                                   isGroup:false
                                    isShow:true
                                   groupID:0
                                 groupName:@""];
            
            [_sourceHelper updateAppDelegatChatListData:_fmDataBase];
        }
        
    }else{
        
    }
    

}


- (XHMessage *)getPhotoMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType {
    XHMessage *photoMessage = [[XHMessage alloc] initWithPhoto:nil thumbnailUrl:@"http://d.hiphotos.baidu.com/image/pic/item/30adcbef76094b361721961da1cc7cd98c109d8b.jpg" originPhotoUrl:nil sender:@"Jack" timestamp:[NSDate date]];
    photoMessage.avatar = [UIImage imageNamed:@"icon"];
    photoMessage.avatarUrl = @"http://www.pailixiu.com/jack/JieIcon@2x.png";
    photoMessage.bubbleMessageType = bubbleMessageType;
    
    return photoMessage;
}

- (XHMessage *)getVideoMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType {
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"IMG_1555.MOV" ofType:@""];
    XHMessage *videoMessage = [[XHMessage alloc] initWithVideoConverPhoto:[XHMessageVideoConverPhotoFactory videoConverPhotoWithVideoPath:videoPath] videoPath:videoPath videoUrl:nil sender:@"Jayson" timestamp:[NSDate date]];
    videoMessage.avatar = [UIImage imageNamed:@"icon"];
    videoMessage.avatarUrl = @"http://www.pailixiu.com/jack/JieIcon@2x.png";
    videoMessage.bubbleMessageType = bubbleMessageType;
    
    return videoMessage;
}

- (XHMessage *)getVoiceMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType {
    XHMessage *voiceMessage = [[XHMessage alloc] initWithVoicePath:nil voiceUrl:nil voiceDuration:@"1" sender:@"Jayson" timestamp:[NSDate date] isRead:NO];
    voiceMessage.avatar = [UIImage imageNamed:@"icon"];
    voiceMessage.avatarUrl = @"http://www.pailixiu.com/jack/JieIcon@2x.png";
    voiceMessage.bubbleMessageType = bubbleMessageType;
    
    return voiceMessage;
}

- (XHMessage *)getEmotionMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType {
    XHMessage *emotionMessage = [[XHMessage alloc] initWithEmotionPath:[[NSBundle mainBundle] pathForResource:@"emotion1.gif" ofType:nil] sender:@"Jayson" timestamp:[NSDate date]];
    emotionMessage.avatar = [UIImage imageNamed:@"icon"];
    emotionMessage.avatarUrl = @"http://www.pailixiu.com/jack/JieIcon@2x.png";
    emotionMessage.bubbleMessageType = bubbleMessageType;
    
    return emotionMessage;
}

- (XHMessage *)getGeolocationsMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType {
    XHMessage *localPositionMessage = [[XHMessage alloc] initWithLocalPositionPhoto:[UIImage imageNamed:@"Fav_Cell_Loc"] geolocations:@"中国广东省广州市天河区东圃二马路121号" location:[[CLLocation alloc] initWithLatitude:23.110387 longitude:113.399444] sender:@"Jack" timestamp:[NSDate date]];
    localPositionMessage.avatar = [UIImage imageNamed:@"icon"];
    localPositionMessage.avatarUrl = @"http://www.pailixiu.com/jack/meIcon@2x.png";
    localPositionMessage.bubbleMessageType = bubbleMessageType;
    
    return localPositionMessage;
}

- (void)getMessages {
    
    NSString *text = [_receivedDataFromSocket objectForKey:@"data"];
    NSDate   *date = [CommonFunctions getDateFromStringWithGMT:[NSString stringWithFormat:@"%@",[_receivedDataFromSocket objectForKey:@"created_at"]]];
    [self didGetText:text fromSender:nil onDate:date];
}

- (void)getMsgFromFriends:(XHMessage *)addedMessage {
    WEAKSELF
    
    NSMutableArray *messages = [NSMutableArray arrayWithArray:weakSelf.messages];
    [messages addObject:addedMessage];
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:1];
    [indexPaths addObject:[NSIndexPath indexPathForRow:messages.count - 1 inSection:0]];
    
    weakSelf.messages = messages;
    [weakSelf.messageTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [weakSelf scrollToBottomAnimated:NO];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[XHAudioPlayerHelper shareInstance] stopAudio];
    [_fmDataBase close];
    _isGetLocalChatData = false;
    _isGroupChat = false;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}
- (id)init {
    self = [super init];
    if (self) {
        // 配置输入框UI的样式
//        self.allowsSendVoice = NO;
//        self.allowsSendFace = NO;
//        self.allowsSendMultiMedia = NO;
    }
    return self;
}


- (void) getLocalChatData{
    
    if (_isGetLocalChatData) {
        if (_isPrivateChat) {
            _localChatData = [_sourceHelper getChatContentForFriend:_fmDataBase tableName:[_friends_dic objectForKey:FRIEND_ID]];
        }else{
            _localChatData = [_sourceHelper getChatContentForFriend:_fmDataBase tableName:[_friends_dic objectForKey:FRIEND_ID]];
        }
        
        if (_localChatData.count>0) {
            
            NSLog(@"getChatContentForFriend %@----%@",[_friends_dic objectForKey:FRIEND_NAME], _localChatData);
            
            for (int i = 0; i<_localChatData.count; i++) {
                
                //            [[_localChatData objectAtIndex:i] valueForKey:FRIEND_MESSAGE_TYPE];
                
                NSInteger status = [[[_localChatData objectAtIndex:i] valueForKey:GL_IS_SENDER] integerValue];
                
                NSString *meg = [[_localChatData objectAtIndex:i] valueForKey:GL_MESSAGE];
                NSDate  *time = [CommonFunctions getDateFromString:[[_localChatData objectAtIndex:i] valueForKey:GL_MESSAGE_CREATE_TIME]];
                
                if (status == 1) {
                    [self didSendText:meg fromSender:nil onDate:time];
                }else{
                    [self didGetText:meg fromSender:nil onDate:time];
                }
            }
            _isGetLocalChatData = false;

        }else{
            _isGetLocalChatData = false;
        }
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];

//    [self.navigationItem setHidesBackButton:YES animated:YES];
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(refreshMainChatList:)];

    _appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    _appDelegate.webSocket.delegate = self;
    _sourceHelper = [[SourceHelper alloc] init];
    _fmDataBase = [[FMDatabase alloc] initWithPath:_appDelegate.getdestinationPath];
    
    [self getLocalChatData];
    
    // Do any additional setup after loading the view.
    
    if (CURRENT_SYS_VERSION >= 7.0) {
        self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan=NO;
    }

//    self.title = NSLocalizedStringFromTable(@"Chat", @"MessageDisplayKitString", @"聊天");
//    self.navigationController.navigationItem.leftBarButtonItem = nil;
    // Custom UI
//    [self setBackgroundColor:[UIColor clearColor]];
//    [self setBackgroundImage:[UIImage imageNamed:@"TableViewBackgroundImage"]];
    
    // 设置自身用户名
//    self.messageSender = @"";
    
    // 添加第三方接入数据
//    NSMutableArray *shareMenuItems = [NSMutableArray array];
//    NSArray *plugIcons = @[@"sharemore_pic", @"sharemore_video", @"sharemore_location", @"sharemore_friendcard", @"sharemore_myfav", @"sharemore_wxtalk", @"sharemore_videovoip", @"sharemore_voiceinput", @"sharemore_openapi", @"sharemore_openapi", @"avatar"];
//    NSArray *plugTitle = @[@"照片", @"拍摄", @"位置", @"名片", @"我的收藏", @"实时对讲机", @"视频聊天", @"语音输入", @"大众点评", @"应用", @"曾宪华"];
//    for (NSString *plugIcon in plugIcons) {
//        XHShareMenuItem *shareMenuItem = [[XHShareMenuItem alloc] initWithNormalIconImage:[UIImage imageNamed:plugIcon] title:[plugTitle objectAtIndex:[plugIcons indexOfObject:plugIcon]]];
//        [shareMenuItems addObject:shareMenuItem];
//    }
//    
//    NSMutableArray *emotionManagers = [NSMutableArray array];
//    for (NSInteger i = 0; i < 10; i ++) {
//        XHEmotionManager *emotionManager = [[XHEmotionManager alloc] init];
//        emotionManager.emotionName = [NSString stringWithFormat:@"表情%ld", (long)i];
//        NSMutableArray *emotions = [NSMutableArray array];
//        for (NSInteger j = 0; j < 18; j ++) {
//            XHEmotion *emotion = [[XHEmotion alloc] init];
//            NSString *imageName = [NSString stringWithFormat:@"section%ld_emotion%ld", (long)i , (long)j % 16];
//            emotion.emotionPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"emotion%ld.gif", (long)j] ofType:@""];
//            emotion.emotionConverPhoto = [UIImage imageNamed:imageName];
//            [emotions addObject:emotion];
//        }
//        emotionManager.emotions = emotions;
//        
//        [emotionManagers addObject:emotionManager];
//    }
//    
//    self.emotionManagers = emotionManagers;
//    [self.emotionManagerView reloadData];
    
//    self.shareMenuItems = shareMenuItems;
//    [self.shareMenuView reloadData];
        
//    [self loadDemoDataSource];
}

#pragma marks webSocket Delegate


- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    _receivedDataFromSocket = [[message dataUsingEncoding:NSUTF8StringEncoding] objectFromJSONData];
    NSLog(@"-----------webSocketReceiveMsg-------:\n%@",_receivedDataFromSocket);
    
    if (_receivedDataFromSocket !=nil && [[_receivedDataFromSocket objectForKey:@"cmd"] isEqualToString:CMD_FROM_MESSAGE]) {
        [self getMessages];
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"-----------webSocketError-------:\n%@",error.description);

}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"-----------webSocketClose-------:\n");
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.emotionManagers = nil;
    [[XHAudioPlayerHelper shareInstance] setDelegate:nil];
}

/*
 [self removeMessageAtIndexPath:indexPath];
 [self insertOldMessages:self.messages];
 */

#pragma mark - XHMessageTableViewCell delegate

- (void)multiMediaMessageDidSelectedOnMessage:(id<XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath onMessageTableViewCell:(XHMessageTableViewCell *)messageTableViewCell {
    UIViewController *disPlayViewController;
    switch (message.messageMediaType) {
        case XHBubbleMessageMediaTypeVideo:
        case XHBubbleMessageMediaTypePhoto: {
            DLog(@"message : %@", message.photo);
            DLog(@"message : %@", message.videoConverPhoto);
            XHDisplayMediaViewController *messageDisplayTextView = [[XHDisplayMediaViewController alloc] init];
            messageDisplayTextView.message = message;
            disPlayViewController = messageDisplayTextView;
            break;
        }
            break;
        case XHBubbleMessageMediaTypeVoice: {
            DLog(@"message : %@", message.voicePath);
            
            // Mark the voice as read and hide the red dot.
            message.isRead = YES;
            messageTableViewCell.messageBubbleView.voiceUnreadDotImageView.hidden = YES;
            
            [[XHAudioPlayerHelper shareInstance] setDelegate:(id<NSFileManagerDelegate>)self];
            if (_currentSelectedCell) {
                [_currentSelectedCell.messageBubbleView.animationVoiceImageView stopAnimating];
            }
            if (_currentSelectedCell == messageTableViewCell) {
                [messageTableViewCell.messageBubbleView.animationVoiceImageView stopAnimating];
                [[XHAudioPlayerHelper shareInstance] stopAudio];
                self.currentSelectedCell = nil;
            } else {
                self.currentSelectedCell = messageTableViewCell;
                [messageTableViewCell.messageBubbleView.animationVoiceImageView startAnimating];
                [[XHAudioPlayerHelper shareInstance] managerAudioWithFileName:message.voicePath toPlay:YES];
            }
            break;
        }
        case XHBubbleMessageMediaTypeEmotion:
            DLog(@"facePath : %@", message.emotionPath);
            break;
        case XHBubbleMessageMediaTypeLocalPosition: {
            DLog(@"facePath : %@", message.localPositionPhoto);
            XHDisplayLocationViewController *displayLocationViewController = [[XHDisplayLocationViewController alloc] init];
            displayLocationViewController.message = message;
            disPlayViewController = displayLocationViewController;
            break;
        }
        default:
            break;
    }
    if (disPlayViewController) {
        [self.navigationController pushViewController:disPlayViewController animated:YES];
    }
}

- (void)didDoubleSelectedOnTextMessage:(id<XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath {
    DLog(@"text : %@", message.text);
    XHDisplayTextViewController *displayTextViewController = [[XHDisplayTextViewController alloc] init];
    displayTextViewController.message = message;
    [self.navigationController pushViewController:displayTextViewController animated:YES];
}

- (void)didSelectedAvatarOnMessage:(id<XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath {
//    DLog(@"indexPath : %@", indexPath);
//    XHContact *contact = [[XHContact alloc] init];
//    contact.contactName = [message sender];
//    contact.contactIntroduction = @"自定义描述，这个需要和业务逻辑挂钩";
//    XHContactDetailTableViewController *contactDetailTableViewController = [[XHContactDetailTableViewController alloc] initWithContact:contact];
//    [self.navigationController pushViewController:contactDetailTableViewController animated:YES];
}

- (void)menuDidSelectedAtBubbleMessageMenuSelecteType:(XHBubbleMessageMenuSelecteType)bubbleMessageMenuSelecteType {
    
}

#pragma mark - XHAudioPlayerHelper Delegate

- (void)didAudioPlayerStopPlay:(AVAudioPlayer *)audioPlayer {
    if (!_currentSelectedCell) {
        return;
    }
    [_currentSelectedCell.messageBubbleView.animationVoiceImageView stopAnimating];
    self.currentSelectedCell = nil;
}

#pragma mark - XHEmotionManagerView DataSource

- (NSInteger)numberOfEmotionManagers {
    return self.emotionManagers.count;
}

- (XHEmotionManager *)emotionManagerForColumn:(NSInteger)column {
    return [self.emotionManagers objectAtIndex:column];
}

- (NSArray *)emotionManagersAtManager {
    return self.emotionManagers;
}

#pragma mark - XHMessageTableViewController Delegate

- (BOOL)shouldLoadMoreMessagesScrollToTop {
    return YES;
}

//- (void)loadMoreMessagesScrollTotop {
//    if (!self.loadingMoreMessage) {
//        self.loadingMoreMessage = YES;
//        
//        WEAKSELF
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            NSMutableArray *messages = [weakSelf getMessages];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [weakSelf insertOldMessages:messages];
//                weakSelf.loadingMoreMessage = NO;
//            });
//        });
//    }
//}

/**
 *  发送文本消息的回调方法
 *
 *  @param text   目标文本字符串
 *  @param sender 发送者的名字
 *  @param date   发送时间
 */
- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date {
    
    XHMessage *textMessage = [[XHMessage alloc] initWithText:text sender:sender timestamp:date];
    UIImageView * imgV = [[UIImageView alloc] init];
    [imgV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",_appDelegate.SELF_USER_AVATAR]]];
    textMessage.avatar = imgV.image;
    [self addMessage:textMessage];
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeText];

    if (!_isGetLocalChatData) {
        [_webSocket send:CREATE_PRIVATE_CHAT_CMD(_appDelegate.SELF_USER_ID, [[_friends_dic objectForKey:FRIEND_ID] integerValue], text, MSG_TYPE_TEXT)];
        [_sourceHelper updateChatTable:_fmDataBase
                             tableName:[_friends_dic objectForKey:FRIEND_ID]
                              friendID:[[_friends_dic objectForKey:FRIEND_ID] integerValue]
                               message:text
                              isSender:true
                                  time:date
                                  type:0
                               isGroup:false
                                isShow:true
                               groupID:0
                             groupName:@""];
//        [self updatePrivateChatTable:text isSender:YES createTime:date type:0];
        [_sourceHelper updateAppDelegatChatListData:_fmDataBase];
    }else{

    }
}

//- (void)updatePrivateChatTable :(NSString *)message isSender:(BOOL)isSender createTime:(NSDate*)time type:(int)type{
//    
//    if ([_fmDataBase open]) {
//        @try {
//            int status;
//            if (isSender) {
//                status = 1;
//            }else{
//                status = 0;
//            }
//            
//            NSString *createTime = [CommonFunctions getStringFromDate:time];
//            
//            NSString * sql = CREATE_PRIVATE_CHAT_TABLE([[_friends_dic objectForKey:FRIEND_ID] integerValue]);
//            NSString * sql2 = UPDATE_PRIVATE_CHAT_TABLE([[_friends_dic objectForKey:FRIEND_ID] integerValue], message, status, createTime, type);
//            
//            if ([_sourceHelper checkTableIsExists:_fmDataBase tableName:[[_friends_dic objectForKey:FRIEND_ID] integerValue]]) {
//                
//                BOOL success_sql2 = [_fmDataBase executeUpdate:sql2];
//                
//                if (success_sql2) {
//                    NSLog(@"INSERT into %ld table success!!!",[[_friends_dic objectForKey:FRIEND_ID] integerValue]);
//                }
//
//                
//            }else{
//                BOOL success_sql = [_fmDataBase executeUpdate:sql];
//                if (success_sql) {
//                    
//                    NSLog(@"create chat table with %@ success!!!",[_friends_dic objectForKey:FRIEND_NAME]);
//                    BOOL success_sql2 = [_fmDataBase executeUpdate:sql2];
//                    
//                    if (success_sql2) {
//                        NSLog(@"INSERT into %ld table success!!!",[[_friends_dic objectForKey:FRIEND_ID] integerValue]);
//                    }
//                    
//                }else{
//                    
//                }
//            }
//
//            if (![self isAlreadyOnChatListTable]) {
//                NSString * sql3 = UPDATE_CHAT_LIST([[_friends_dic objectForKey:FRIEND_ID] integerValue], 1, 0);
//                [_fmDataBase executeUpdate:sql3];
//                NSLog(@"update chat list table success!!!");
//            }else{
//                
//            }
//        }
//        @catch (NSException *exception) {
//            NSLog(@"%@",exception.debugDescription);
//        }
//        @finally {
//        }
//    }
//}
//
//- (BOOL) isAlreadyOnChatListTable {
//    if ([_fmDataBase open]) {
//        
//        int totalCount;
//
//        @try {
//            
//            NSString * sql = [NSString stringWithFormat:@"select count(*) from chat_list where friend_id = %ld",[[_friends_dic objectForKey:FRIEND_ID] integerValue]];
//            
//            FMResultSet *s = [_fmDataBase executeQuery:sql];
//            
//            if ([s next]) {
//                totalCount = [s intForColumnIndex:0];
//            }
//            [s close];
//        }
//        @catch (NSException *exception) {
//            NSLog(@"%@",exception.debugDescription);
//        }
//        @finally {
//            
//            if (totalCount>0) {
//                return true;
//            }
//            return false;
//        }
//    }
//}

/**
 *  发送图片消息的回调方法
 *
 *  @param photo  目标图片对象，后续有可能会换
 *  @param sender 发送者的名字
 *  @param date   发送时间
 */
- (void)didSendPhoto:(UIImage *)photo fromSender:(NSString *)sender onDate:(NSDate *)date {
    XHMessage *photoMessage = [[XHMessage alloc] initWithPhoto:photo thumbnailUrl:nil originPhotoUrl:nil sender:sender timestamp:date];
    photoMessage.avatar = [UIImage imageNamed:@"icon"];
    photoMessage.avatarUrl = @"http://www.pailixiu.com/jack/meIcon@2x.png";
    [self addMessage:photoMessage];
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypePhoto];
}

/**
 *  发送视频消息的回调方法
 *
 *  @param videoPath 目标视频本地路径
 *  @param sender    发送者的名字
 *  @param date      发送时间
 */
- (void)didSendVideoConverPhoto:(UIImage *)videoConverPhoto videoPath:(NSString *)videoPath fromSender:(NSString *)sender onDate:(NSDate *)date {
    XHMessage *videoMessage = [[XHMessage alloc] initWithVideoConverPhoto:videoConverPhoto videoPath:videoPath videoUrl:nil sender:sender timestamp:date];
    videoMessage.avatar = [UIImage imageNamed:@"icon"];
    videoMessage.avatarUrl = @"http://www.pailixiu.com/jack/meIcon@2x.png";
    [self addMessage:videoMessage];
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeVideo];
}

/**
 *  发送语音消息的回调方法
 *
 *  @param voicePath        目标语音本地路径
 *  @param voiceDuration    目标语音时长
 *  @param sender           发送者的名字
 *  @param date             发送时间
 */
- (void)didSendVoice:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration fromSender:(NSString *)sender onDate:(NSDate *)date {
    
    XHMessage *voiceMessage = [[XHMessage alloc] initWithVoicePath:voicePath voiceUrl:nil voiceDuration:voiceDuration sender:sender timestamp:date];
    voiceMessage.avatar = [UIImage imageNamed:@"icon"];
    voiceMessage.avatarUrl = @"http://www.pailixiu.com/jack/meIcon@2x.png";
    [self addMessage:voiceMessage];
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeVoice];
}

/**
 *  发送第三方表情消息的回调方法
 *
 *  @param facePath 目标第三方表情的本地路径
 *  @param sender   发送者的名字
 *  @param date     发送时间
 */
- (void)didSendEmotion:(NSString *)emotionPath fromSender:(NSString *)sender onDate:(NSDate *)date {
    XHMessage *emotionMessage = [[XHMessage alloc] initWithEmotionPath:emotionPath sender:sender timestamp:date];
    emotionMessage.avatar = [UIImage imageNamed:@"icon"];
    emotionMessage.avatarUrl = @"http://www.pailixiu.com/jack/meIcon@2x.png";
    [self addMessage:emotionMessage];
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeEmotion];
}

/**
 *  有些网友说需要发送地理位置，这个我暂时放一放
 */
- (void)didSendGeoLocationsPhoto:(UIImage *)geoLocationsPhoto geolocations:(NSString *)geolocations location:(CLLocation *)location fromSender:(NSString *)sender onDate:(NSDate *)date {
    XHMessage *geoLocationsMessage = [[XHMessage alloc] initWithLocalPositionPhoto:geoLocationsPhoto geolocations:geolocations location:location sender:sender timestamp:date];
    geoLocationsMessage.avatar = [UIImage imageNamed:@"icon"];
    geoLocationsMessage.avatarUrl = @"http://www.pailixiu.com/jack/meIcon@2x.png";
    [self addMessage:geoLocationsMessage];
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeLocalPosition];
}

/**
 *  是否显示时间轴Label的回调方法
 *
 *  @param indexPath 目标消息的位置IndexPath
 *
 *  @return 根据indexPath获取消息的Model的对象，从而判断返回YES or NO来控制是否显示时间轴Label
 */
- (BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2) {
        return YES;
    } else {
        return NO;
    }
}

/**
 *  配置Cell的样式或者字体
 *
 *  @param cell      目标Cell
 *  @param indexPath 目标Cell所在位置IndexPath
 */
- (void)configureCell:(XHMessageTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {

}

/**
 *  协议回掉是否支持用户手动滚动
 *
 *  @return 返回YES or NO
 */
- (BOOL)shouldPreventScrollToBottomWhileUserScrolling {
    return YES;
}

@end
