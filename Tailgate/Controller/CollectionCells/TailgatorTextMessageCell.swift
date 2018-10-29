//
//  TailgatorTextMessageCell.swift
//  Tailgate
//
//  Created by Michael Onjack on 10/28/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit
import MessageKit

open class TailgatorTextMessageCell: TextMessageCell {
    //open override class func reuseIdentifier() -> String { return "messagekit.cell.trashtalk.text" }
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    open func handleDoubleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: self)
        
        let cellMinY = cellTopLabel.frame.maxY - cellTopLabel.frame.height
        let cellMidY = messageContainerView.frame.midY
        let cellMaxY = messageBottomLabel.frame.maxY
        
        if let delegate = delegate as? TailgatorMessageCellDelegate {
            switch true {
            case cellMinY <= touchLocation.y && touchLocation.y < cellMidY:
                delegate.didDoubleTapTopCell(in: self)
            case cellMidY < touchLocation.y && touchLocation.y <= cellMaxY:
                delegate.didDoubleTapBottomCell(in: self)
            default:
                break
            }
        }
    }
    
    open func handleLongPressGesture(_ gesture: UIGestureRecognizer) {
        guard let longPressGesture = gesture as? UILongPressGestureRecognizer else { return }
        let touchLocation = gesture.location(in: self)
        
        if let delegate = delegate as? TailgatorMessageCellDelegate {
            switch true {
            case messageContainerView.frame.contains(touchLocation) && !cellContentView(canHandle: convert(touchLocation, to: messageContainerView)):
                if longPressGesture.state == .began {
                    delegate.didLongPressMessage(in: self)
                }
            default:
                break
            }
        }
    }
    
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
