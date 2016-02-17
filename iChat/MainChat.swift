//
//  MainChat.swift
//  iChat
//
//  Created by iAPPS Pte Ltd on 05/01/16.
//  Copyright © 2016年 iAPPS Pte Ltd. All rights reserved.
//

import Foundation
import UIKit

class MainChat: UITableViewController,UISearchBarDelegate,SRWebSocketDelegate{
    
    var searchBar : UISearchBar!
    var dataSource  = NSMutableArray()
    var popMenu  = XHPopMenu?()
    var database = FMDatabase()
    var receivedDataFromSocket = NSDictionary()
    var friendDic = NSDictionary()
    var badgeDic = NSDictionary()
    var badgeNumber:NSInteger = 0
    
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 2)) { () -> Void in
            
            self.receivedDataFromSocket = message.dataUsingEncoding(NSUTF8StringEncoding)!.objectFromJSONData() as! NSDictionary
            print("--------webSocketReceiveMsg-------:\n\(self.receivedDataFromSocket)");
            
            if (self.receivedDataFromSocket.objectForKey("cmd")!.isEqualToString("fromMsg")) {
                self.friendDic = NSDictionary(
                    objects: [self.receivedDataFromSocket.objectForKey("from")!,self.receivedDataFromSocket.objectForKey("fromName")!,self.receivedDataFromSocket.objectForKey(AVATAR)!],
                    forKeys: [FRIEND_ID,FRIEND_NAME,FRIEND_AVATAR])
                
                print("--------friendDic-------:\n\(self.friendDic)");
                
                let msg  = self.receivedDataFromSocket.objectForKey("data") as! NSString
                let date = CommonFunctions.getDateFromStringWithGMT(self.receivedDataFromSocket.objectForKey("created_at") as! String)
                
                sourceHelper.updatePrivateChatTable(self.database, friendDic: self.friendDic, message: msg, isSender: false, time: date, type: 0)
                self.calculateBadgeNumber()
                sourceHelper.updateAppDelegatChatListData(self.database)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.dataSource = self.appDelegate.CHAT_LIST_DATA
                    
                    self.tableView.reloadData()
                })

            }
        }
    }
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        
    }
    
    func webSocketDidOpen(webSocket: SRWebSocket!) {
        print("webSocket has did open!!!")
    }
    
    func calculateBadgeNumber() {
        
        badgeNumber++
        print(badgeNumber)
        let oldBadgeNumber = sourceHelper.getBadgeNumber(database, friendDic: friendDic)
        print(badgeNumber+oldBadgeNumber)

        sourceHelper.updateChatListBadgeNumber(database, friendID: friendDic.objectForKey(FRIEND_ID)!.integerValue, badge:badgeNumber+oldBadgeNumber)
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.popMenu = popMenuHelper.initPopMenus()
        commenBase.customNavBarItem(MainChat.self, tabBar: self.tabBarController!, tar: self, ac: "showCustomMenuView:")
        appDelegate.webSocket.delegate = self
        dataSource = appDelegate.CHAT_LIST_DATA
        self.tableView.reloadData()
    }
    
    override func viewDidLoad () {
        super.viewDidLoad()
        
        database = FMDatabase.init(path: appDelegate.getdestinationPath())
        sourceHelper.updateAppDelegatChatListData(database)

        self.searchBar = UISearchBar.init(frame:CGRectMake(0, 0, self.view.frame.size.width, 44))
        self.searchBar.sizeToFit()
        self.searchBar.translucent = true
        self.searchBar.barTintColor = UIColor.groupTableViewBackgroundColor()
        self.searchBar.placeholder = "Search"
        self.searchBar.delegate = self
        
        self.tableView.tableHeaderView = self.searchBar
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.tableFooterView!.hidden = true
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:MainChatCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! MainChatCell

        if dataSource.count != 0 {
            cell.userName?.text = dataSource[indexPath.row].valueForKey(FRIEND_NAME) as? String
            cell.avatarImg.sd_setImageWithURL(NSURL.init(string:dataSource[indexPath.row].valueForKey(FRIEND_AVATAR) as! String))
            cell.msgContent?.text = dataSource[indexPath.row].valueForKey(FRIEND_MESSAGE) as? String
            cell.msgReceivedDate?.text = dataSource[indexPath.row].valueForKey(FRIEND_MESSAGE_CREATE_TIME) as? String
            
            if (dataSource[indexPath.row].valueForKey(FRIEND_MESSAGE_BADGE) as! Int>0) {
                
                cell.badge?.text = "\(dataSource[indexPath.row].valueForKey(FRIEND_MESSAGE_BADGE) as! Int)"
                cell.badge?.hidden = false
            }else{
                cell.badge?.hidden = true
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath:NSIndexPath) -> CGFloat
    {
        return 70
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        badgeNumber = 0
        sourceHelper.updateChatListBadgeNumber(database, friendID: self.dataSource[indexPath.row].valueForKey(FRIEND_ID) as! Int, badge: 0)
        sourceHelper.updateAppDelegatChatListData(database)

        let mesChatVC = XHDemoWeChatMessageTableViewController.init()
        let friend_id = self.dataSource[indexPath.row].valueForKey(FRIEND_ID)
        let friend_name = self.dataSource[indexPath.row].valueForKey(FRIEND_NAME)
        let friend_avatar = self.dataSource[indexPath.row].valueForKey(FRIEND_AVATAR)
        mesChatVC.friends_dic = NSDictionary(objects: [friend_id!,friend_name!,friend_avatar!], forKeys: [FRIEND_ID,FRIEND_NAME,FRIEND_AVATAR]) as [NSObject : AnyObject]
        mesChatVC.isGetLocalChatData = true
        self.tabBarController?.navigationController?.pushViewController(mesChatVC, animated: true)

    }
    
    func showCustomMenuView (buttonItem:UIBarButtonItem) {
        self.popMenu!.showMenuOnView(self.view, atPoint: CGPointZero)
    }
    
}