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
        
        let border = CALayer()
        border.frame = CGRect(x: 0, y: 0, width: cellTopLabel.frame.width, height: 2)
        if configuration.currentUser.didUpvoteMessage(withId: message.messageId) {
            border.backgroundColor = UIColor.orange.cgColor
            cellTopLabel.layer.addSublayer(border)
        } else if configuration.currentUser.didDownvoteMessage(withId: message.messageId) {
            border.backgroundColor = UIColor.lavender.cgColor
            cellTopLabel.layer.addSublayer(border)
        }
    }
}
