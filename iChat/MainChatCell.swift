//
//  MainChatCell.swift
//  iChat
//
//  Created by iAPPS Pte Ltd on 05/01/16.
//  Copyright © 2016年 iAPPS Pte Ltd. All rights reserved.
//

import UIKit

class MainChatCell: UITableViewCell {
    
    @IBOutlet var avatarImg         :UIImageView!
    @IBOutlet var userName          :UILabel?
    @IBOutlet var msgContent        :UILabel?
    @IBOutlet var msgReceivedDate   :UILabel?
    @IBOutlet var badge             :SwiftBadge?

    //    @IBOutlet var unknowLabel       :UILabel!
    //    @IBOutlet var videoImageView    :UIImageView?
    
}