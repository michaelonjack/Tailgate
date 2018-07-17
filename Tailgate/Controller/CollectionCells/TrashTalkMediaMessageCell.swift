//
//  TrashTalkMediaMessageCell.swift
//  Tailgate
//
//  Created by Michael Onjack on 7/14/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit
import MessageKit

open class TrashTalkMediaMessageCell: MediaMessageCell {
    open override class func reuseIdentifier() -> String { return "messagekit.cell.trashtalk.mediamessage" }
    
    open override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        
        self.layer.sublayers?.forEach {
            if $0.backgroundColor == UIColor.orange.cgColor || $0.backgroundColor == UIColor.lavender.cgColor {
                $0.removeFromSuperlayer()
            }
        }
        
        var isFromCurrentSender = false
        if let dataSource = messagesCollectionView.dataSource as? MessagesDataSource {
            isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        }
        
        let border = CALayer()
        let cellWidth = self.frame.width
        let cellHeight = self.frame.height
        
        if isFromCurrentSender {
            border.frame = CGRect(x: 0, y: 0, width: 4, height: cellHeight)
        } else {
            border.frame = CGRect(x: cellWidth-4, y: 0, width: 4, height: cellHeight)
        }
        
        if configuration.currentUser.didUpvoteMessage(withId: message.messageId) {
            border.backgroundColor = UIColor.orange.cgColor
            self.layer.addSublayer(border)
        } else if configuration.currentUser.didDownvoteMessage(withId: message.messageId) {
            border.backgroundColor = UIColor.lavender.cgColor
            self.layer.addSublayer(border)
        }
    }
}
