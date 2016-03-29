//
//  ContactsList.swift
//  iChat
//
//  Created by iAPPS Pte Ltd on 05/01/16.
//  Copyright © 2016年 iAPPS Pte Ltd. All rights reserved.
//

import Foundation
import UIKit

class ContactsList:UITableViewController,UISearchBarDelegate,SRWebSocketDelegate{
    
    var searchBar : UISearchBar!
    var dataSource  = NSMutableArray()
    var database = FMDatabase()

    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    
    func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.forFriendList(message)
        })
    }
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        CommonFunctions.dismissGlobalHUD()
        CommonFunctions.showAlertWithTitle("Sorry", msg: "Some network error happend,please try later", delegate: self, cancelTitle: "ok")
    }
    
    func webSocketDidOpen(webSocket: SRWebSocket!) {
        print("webSocket has did open!!!")
    }

    func forFriendList (msg:AnyObject) {
        
        var dic = NSDictionary()
        dic = msg.dataUsingEncoding(NSUTF8StringEncoding)?.objectFromJSONData() as! NSDictionary
        print("webSocket has received msg!!!:-------\n",dic)
        
        if (dic.objectForKey("cmd")!.isEqualToString("getFriendList") && dic.objectForKey("status_code")!.integerValue == STATUS_CODE_SUCCESS_FRIEND) {
            dataSource.removeAllObjects()
            dataSource.addObjectsFromArray(dic.valueForKey("data") as! NSMutableArray as [AnyObject])
            sourceHelper.updateFriendsTable(dataSource)
            self.tableView.reloadData()
        }else{
            
        }
        CommonFunctions.dismissGlobalHUD()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        appDelegate.webSocket.delegate = self
        CommonFunctions.showGlobalProgressHUDWithTitle("Loading...")
        socketHelper.socketCMDStatus(CMD_GET_FRIENDS, object: appDelegate.SELF_USER_ID)
        commenBase.customNavBarItem(ContactsList.self, tabBar: self.tabBarController!, tar: self, ac: nil)
    }
    
    override func viewDidLoad () {
        super.viewDidLoad()
        database = FMDatabase.init(path: appDelegate.getdestinationPath())

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
        
        let cell:ContactsListCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ContactsListCell
        
        cell.userName?.text = dataSource[indexPath.row].valueForKey(NAME) as? String
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if (sourceHelper.isNotNull(self.dataSource[indexPath.row].valueForKey(AVATAR)!)) {
                cell.avatarImg.sd_setImageWithURL(NSURL.init(string: self.dataSource[indexPath.row].valueForKey(AVATAR) as! String), placeholderImage: UIImage(named: "placeholderImage"))
            }else{
                cell.avatarImg.image = UIImage(named:"placeholderImage")
            }
        })

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath:NSIndexPath) -> CGFloat
    {
        return 60
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let mesChatVC = XHDemoWeChatMessageTableViewController.init()
        mesChatVC.chatDataSource = self.dataSource[indexPath.row] as! [NSObject : AnyObject]
        mesChatVC.isGetLocalChatData = true
        mesChatVC.isPrivateChat = true
        mesChatVC.isFirstChat   = true
        self.tabBarController?.navigationController?.pushViewController(mesChatVC, animated: true)

    }
    
}
