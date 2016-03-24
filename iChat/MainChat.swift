//
//  MainChat.swift
//  iChat
//
//  Created by iAPPS Pte Ltd on 05/01/16.
//  Copyright © 2016年 iAPPS Pte Ltd. All rights reserved.
//

import Foundation
import UIKit

class MainChat: UITableViewController,UISearchBarDelegate,SRWebSocketDelegate,popMenuHelperDelegate{
    
    var searchBar : UISearchBar!
    var dataSource  = NSMutableArray()
    var popMenu  = XHPopMenu?()
    var database = FMDatabase()
    var receivedDataFromSocket = NSDictionary()
    var group_friendDic = NSMutableArray()

    var badgeNumber:NSInteger = 0
    
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 2)) { () -> Void in
            
            self.receivedDataFromSocket = message.dataUsingEncoding(NSUTF8StringEncoding)!.objectFromJSONData() as! NSDictionary
            print("--------webSocketReceiveMsg-------:\n\(self.receivedDataFromSocket)");
            
            if (self.receivedDataFromSocket.objectForKey("cmd") as! String == CMD_FROM_MESSAGE) {
                
                // get msg from other side
                
                let date        = CommonFunctions.getDateFromStringWithGMT(self.receivedDataFromSocket.objectForKey("created_at") as! String)
                let channal_id  = self.receivedDataFromSocket.objectForKey("channal")!.integerValue
                let msg         = self.receivedDataFromSocket.objectForKey("data") as! NSString
                let friend_id   = self.receivedDataFromSocket.objectForKey("from") as! String
                let is_group    = channal_id > 0 ? true : false
                let group_id    = channal_id > 0 ? channal_id : 0
                let group_name  = channal_id > 0 ? sourceHelper.getGroupNameByGroupID(group_id) : ""
                let table_name  = channal_id > 0 ? "group"+(self.receivedDataFromSocket.objectForKey("channal") as! String) : self.receivedDataFromSocket.objectForKey("from") as! String

                sourceHelper.updateChatTable(
                    table_name,
                    friendID: friend_id,
                    message: msg,
                    isSender: false,
                    time: date,
                    type: 0,
                    isGroup: is_group,
                    isShow: true,
                    groupID: group_id,
                    groupName: group_name)
                
                self.calculateBadgeNumber(table_name)
                sourceHelper.updateAppDelegatChatListData()
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.dataSource = self.appDelegate.CHAT_LIST_DATA
                    
                    self.tableView.reloadData()
                })
                
            }else if (self.receivedDataFromSocket.objectForKey("cmd") as! String == CMD_GET_FRIENDS && self.receivedDataFromSocket.objectForKey("status_code")!.integerValue == STATUS_CODE_SUCCESS_FRIEND) {
                
                // get friend list
                sourceHelper.updateFriendsTable(self.receivedDataFromSocket.valueForKey("data") as! NSMutableArray)
                
            }else if (self.receivedDataFromSocket.objectForKey("cmd") as! String == CMD_CREATE_GROUP_CHAT && self.receivedDataFromSocket.objectForKey("status_code")!.integerValue == STATUS_CODE_SUCCESS_FRIEND) {
                
                // creare group
                
                let group_name  = self.receivedDataFromSocket.objectForKey("data")?.objectForKey("name") as! String
                let group_id    = self.receivedDataFromSocket.objectForKey("data")?.objectForKey("id")!.integerValue
                let table_name  = "group" + ((self.receivedDataFromSocket.objectForKey("data")?.objectForKey("id"))! as! String)
                let date        = CommonFunctions.getDateFromStringWithGMT(self.receivedDataFromSocket.objectForKey("data")?.valueForKey("created_at") as! String)

                self.group_friendDic = self.receivedDataFromSocket.objectForKey("data")!.valueForKey("inviteUsers") as! NSMutableArray
                print(self.group_friendDic)
                
                sourceHelper.updateChatTable(
                            table_name,
                             friendID: "",
                              message: "",
                             isSender: false,
                                 time: date,
                                 type: 0,
                              isGroup: true,
                               isShow: true,
                              groupID: group_id!,
                            groupName: group_name)
                
                sourceHelper.updateAppDelegatChatListData()
                
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
    
    func calculateBadgeNumber(tableName:String) {
        
        badgeNumber = badgeNumber+1
        print(badgeNumber)
        sourceHelper.updateChatBadgeNumber(tableName, badge:badgeNumber)
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        popMenuHelper.delegate = self
        self.popMenu = popMenuHelper.initPopMenus()
        commenBase.customNavBarItem(MainChat.self, tabBar: self.tabBarController!, tar: self, ac: "showCustomMenuView:")
        appDelegate.webSocket.delegate = self

        if appDelegate.GROUP_FRIEND_DATA.count != 0{
            
            print(appDelegate.GROUP_FRIEND_DATA)

            socketHelper.socketCMDStatus(CMD_CREATE_GROUP_CHAT, object:appDelegate.GROUP_FRIEND_DATA)
            
        }else{
            dataSource = appDelegate.CHAT_LIST_DATA
        }
        self.tableView.reloadData()
    }
    
    override func viewDidLoad () {
        super.viewDidLoad()
        
        database = FMDatabase.init(path: appDelegate.getdestinationPath())
        sourceHelper.updateAppDelegatChatListData()
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
        if dataSource.count != 0 {
            return self.dataSource.count
        }
            return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:MainChatCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! MainChatCell

        if dataSource.count != 0 {
            var show_name = String()
            if  (sourceHelper.isNotNull(dataSource[indexPath.row].valueForKey(GL_GROUP_NAME)!)) {
                show_name = dataSource[indexPath.row].valueForKey(GL_GROUP_NAME) as! String
            }else{
                show_name = dataSource[indexPath.row].valueForKey(FRIEND_NAME) as! String
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if (sourceHelper.isNotNull(self.dataSource[indexPath.row].valueForKey(FRIEND_AVATAR)!)) {
                    cell.avatarImg.sd_setImageWithURL(NSURL.init(string: self.dataSource[indexPath.row].valueForKey(FRIEND_AVATAR) as! String), placeholderImage: UIImage(named: "icon"))
                }else{
                    cell.avatarImg.image = UIImage(named:"icon")
                }
            })
            
            cell.userName?.text = show_name
            cell.msgContent?.text = self.dataSource[indexPath.row].valueForKey(GL_MESSAGE) as? String
            cell.msgReceivedDate?.text = self.dataSource[indexPath.row].valueForKey(GL_MESSAGE_CREATE_TIME) as? String
            
            if (self.dataSource[indexPath.row].valueForKey(GL_MESSAGE_BADGE)!.integerValue > 0) {
                
                cell.badge?.text = "\(self.dataSource[indexPath.row].valueForKey(GL_MESSAGE_BADGE)!.integerValue)"
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

        sourceHelper.updateChatBadgeNumber(self.dataSource[indexPath.row].valueForKey(GL_TABLE_NAME) as! String, badge: 0)

        let mesChatVC = XHDemoWeChatMessageTableViewController.init()
        let friend_id = self.dataSource[indexPath.row].valueForKey(FRIEND_ID)
        let friend_name = self.dataSource[indexPath.row].valueForKey(FRIEND_NAME)
        let friend_avatar = self.dataSource[indexPath.row].valueForKey(FRIEND_AVATAR)
        if  (sourceHelper.isNotNull(dataSource[indexPath.row].valueForKey(GL_GROUP_NAME)!)) {
            mesChatVC.isGroupChat = true
            mesChatVC.friends_dic = NSDictionary(objects: [friend_id!,friend_name!,friend_avatar!], forKeys: [FRIEND_ID,FRIEND_NAME,FRIEND_AVATAR]) as [NSObject : AnyObject]
        }else{
            mesChatVC.isPrivateChat = true
            mesChatVC.friends_dic = NSDictionary(objects: [friend_id!,friend_name!,friend_avatar!], forKeys: [FRIEND_ID,FRIEND_NAME,FRIEND_AVATAR]) as [NSObject : AnyObject]
        }
        mesChatVC.isGetLocalChatData = true
        self.tabBarController?.navigationController?.pushViewController(mesChatVC, animated: true)

    }
    
    func showCustomMenuView (buttonItem:UIBarButtonItem) {
        self.popMenu!.showMenuOnView(self.view, atPoint: CGPointZero)
    }
    
    func addContactForGroup (){
        
        let friendArray = sourceHelper.getFriends()
        let items = NSMutableArray()
        
        for var i = 0; i<friendArray.count; i++ {
            let item = MultiSelectItem()
            item.friend_avatar = NSURL.init(string: friendArray[i].valueForKey(FRIEND_AVATAR) as! String)
            item.friend_name = friendArray[i].valueForKey(FRIEND_NAME) as! String
            item.friend_id = friendArray[i].valueForKey(FRIEND_ID) as! String
            items.addObject(item)
        }
        
        let vc = MultiSelectViewController.init()
        vc.items = items as [AnyObject]
        let navc = UINavigationController.init(rootViewController: vc)
        self.tabBarController?.navigationController?.presentViewController(navc, animated: true, completion: nil)

    }

    
}