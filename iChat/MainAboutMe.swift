//
//  MainAboutMe.swift
//  iChat
//
//  Created by iAPPS Pte Ltd on 05/01/16.
//  Copyright © 2016年 iAPPS Pte Ltd. All rights reserved.
//

import Foundation
import UIKit

class MainAboutMe: CommenBase, UITableViewDataSource ,UITableViewDelegate{
    
    @IBOutlet var tableView : UITableView!
    
    var dataSource  = NSMutableArray()
    
    func loadDataSource () {
        self.dataSource = sourceHelper.getProfileConfigureArray()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        commenBase.customNavBarItem(MainAboutMe.self, tabBar: self.tabBarController!, tar: self, ac: nil)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        loadDataSource()
       
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.dataSource.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        switch (section) {
        case 0:
            return 1
        case 1:
            return 2
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let sectionDictionary = self.dataSource[indexPath.section]
        print(self.dataSource[indexPath.section])

        if (indexPath.section == 0){
            let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
            cell.accessoryType = .DisclosureIndicator;
            cell.textLabel?.text = sectionDictionary.valueForKey("title") as? String
            cell.detailTextLabel?.text = sectionDictionary.valueForKey("WeChatNumber") as? String
            cell.imageView!.image = UIImage(named: (sectionDictionary.valueForKey("image") as? String)!)

            return cell

        }else if (indexPath.section == 1){
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            cell.accessoryType = .DisclosureIndicator;
            cell.textLabel?.text = sectionDictionary[indexPath.row].valueForKey("title") as? String
            cell.imageView?.image = UIImage(named: sectionDictionary[indexPath.row].valueForKey("image") as! String)
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            cell.accessoryType = .DisclosureIndicator;
            cell.textLabel?.text = sectionDictionary.valueForKey("title") as? String
            cell.imageView?.image = UIImage(named: sectionDictionary.valueForKey("image") as! String)
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath:NSIndexPath) -> CGFloat
    {
        if indexPath.section == 0 {
            return 80
        }
        return 44
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch (section) {
        case 0:
            return 1
            
        default:
            return 1
        }
    }
    

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

    }
    
}
