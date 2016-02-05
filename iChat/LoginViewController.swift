//
//  LoginViewController.swift
//  iChat
//
//  Created by iAPPS Pte Ltd on 22/01/16.
//  Copyright © 2016年 iAPPS Pte Ltd. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: CommenBase,SRWebSocketDelegate{
    
    @IBOutlet var loginBtn  : UIButton!
    @IBOutlet var mobileNum : UITextField!
    @IBOutlet var passWord  : UITextField!

    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = .Default
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        appDelegate.webSocket.delegate = self
    }
    
    @IBAction func login() {
        CommonFunctions.showGlobalProgressHUDWithTitle("Loading...")
        let dic = NSDictionary(objects: [mobileNum.text!,passWord.text!,SELF_IMG], forKeys: [NAME,PASS_WORD,AVATAR])
        socketHelper.socketCMDStatus(CMD_LOGIN,object:dic)
    }
    
    func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        print(reason)
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.forUserLogin(message)
        })
    }
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        CommonFunctions.dismissGlobalHUD()
        CommonFunctions.showAlertWithTitle("Sorry", msg: "Some network error happend,please try later", delegate: self, cancelTitle: "ok")
        print(error.description)
    }
    
    func webSocketDidOpen(webSocket: SRWebSocket!) {
        print("webSocket has did open!!!")
    }

    
    func forUserLogin (msg:AnyObject) {
        
        var dic = NSDictionary()
        dic = msg.dataUsingEncoding(NSUTF8StringEncoding)?.objectFromJSONData() as! NSDictionary
        
        print("webSocket has received msg!!!:-------\n",dic)
        
        if (dic.objectForKey("cmd")!.isEqualToString("login") &&    dic.objectForKey("status_code")!.integerValue == STATUS_CODE_SUCCESS_LOGIN) {
            // login successfully
            appDelegate.IS_LOGIN = true
            appDelegate.SELF_USER_ID  = dic.objectForKey(USER_ID)!.integerValue
            appDelegate.SELF_USER_NAME  = dic.objectForKey(NAME) as! String
            appDelegate.SELF_USER_AVATAR  = dic.objectForKey(AVATAR) as! String
            updateAccountTable(dic)
            self.dismissViewControllerAnimated(true, completion: nil)
        }else{
            // show login field informations
            
        }
        CommonFunctions.dismissGlobalHUD()
    }
    
    func updateAccountTable(userInfo:NSDictionary) {
        
        let finalName = "accounts"
        let database = FMDatabase.init(path: appDelegate.getdestinationPath())
        
        if database.open(){
            do {
                
                let updateSQL = "INSERT INTO \(finalName) ( 'mobile_num', 'pass_word', 'user_id', 'user_name', 'avatar') VALUES ('\(mobileNum.text!)', '\(passWord.text!)', '\(userInfo.objectForKey("userId")!)','\(userInfo.objectForKey("username")!)','\(userInfo.objectForKey("avatar")!)')"
                try database.executeUpdate(updateSQL, values: nil)
                let rs = try database.executeQuery("select id ,mobile_num, pass_word, user_id, user_name, avatar from \(finalName)", values: nil)
                while rs.next() {
                    let c = rs.stringForColumn("id")
                    let x = rs.stringForColumn("mobile_num")
                    let y = rs.stringForColumn("pass_word")
                    let z = rs.stringForColumn("user_id")
                    let a = rs.stringForColumn("user_name")
                    let b = rs.stringForColumn("avatar")

                    print("id = \(c); mobile_num = \(x); pass_word = \(y); user_id = \(z); user_name = \(a); avatar = \(b);")
                }
                print("Account Table table has updated !!!!")
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
