//
//  TailgatorMessage.swift
//  Tailgate
//
//  Created by Michael Onjack on 10/28/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import Foundation
import MessageKit
import FirebaseDatabase
import SDWebImage

enum MediaStatus {
    case notLoaded
    case loading
    case loaded
    case error
}

struct ImageMediaItem: MediaItem {
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
    
}

struct TailgatorMessage: MessageType {
    
    var messageId: String
    var sender: Sender
    var sentDate: Date
    var sentDateStr: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: self.sentDate)
    }
    var kind: MessageKind
    var userId: String
    var user: User?
    var imgUrl: URL?
    var score: Int
    var mediaStatus: MediaStatus
    var showDetail:Bool
    
    private init(kind: MessageKind, sender: Sender, messageId: String, date: Date) {
        self.kind = kind
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
        self.user = configuration.currentUser
        self.userId = configuration.currentUser.uid
        self.score = 0
        self.mediaStatus = .notLoaded
        self.showDetail = false
    }
    
    init(text: String, sender: Sender, messageId: String, date: Date) {
        self.init(kind: .text(text), sender: sender, messageId: messageId, date: date)
    }
    
    init(attributedText: NSAttributedString, sender: Sender, messageId: String, date: Date) {
        self.init(kind: .attributedText(attributedText), sender: sender, messageId: messageId, date: date)
    }
    
    init(image: UIImage, sender: Sender, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(image: image)
        self.init(kind: .photo(mediaItem), sender: sender, messageId: messageId, date: date)
    }
    
    init(emoji: String, sender: Sender, messageId: String, date: Date) {
        self.init(kind: .emoji(emoji), sender: sender, messageId: messageId, date: date)
    }
    
    init(snapshot:DataSnapshot) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.messageId = snapshot.key
        self.sentDate = formatter.date(from: snapshotValue["sentDate"] as? String ?? "")!
        self.score = snapshotValue["score"] as? Int ?? 0
        self.userId = snapshotValue["userId"] as? String ?? ""
        self.mediaStatus = .notLoaded
        self.showDetail = false
        
        // Set the sender
        let senderId = snapshotValue["sender"]!["id"] as? String ?? ""
        let senderDisplayName = snapshotValue["sender"]!["displayName"] as? String ?? ""
        self.sender = Sender(id: senderId, displayName: senderDisplayName)
        
        // Set the message data
        if let messageData = snapshotValue["data"], let messageType = messageData["type"] as? String {
            switch messageType {
            case "text":
                let messageText = messageData["value"] as? String ?? ""
                self.kind = .text(messageText)
            case "photo":
                if let imageUrlStr = messageData["url"] as? String {
                    let imageUrl = URL(string: imageUrlStr)
                    self.imgUrl = imageUrl
                    
                    let mediaItem = ImageMediaItem(image: UIImage(named: "Loading")!)
                    self.kind = .photo(mediaItem)
                }
                    
                else {
                    self.kind = .text("error")
                }
                
            default:
                self.kind = .text("error")
            }
        } else {
            self.kind = .text("error")
        }
    }
    
    func toAnyObject() -> Any {
        
        var messageData:[String:Any] = [:]
        switch kind {
        case .text(let str):
            messageData["type"] = "text"
            messageData["value"] = str
        case .photo(_):
            messageData["type"] = "photo"
            if let url = self.imgUrl {
                messageData["url"] = url.absoluteString
            }
        default:
            break
        }
        
        return [
            "sentDate": sentDateStr,
            "score": score,
            "sender": ["id":sender.id, "displayName":sender.displayName],
            "userId": user?.uid ?? "",
            "data": messageData
        ]
    }
}


extension TailgatorMessage: Comparable {
    
    static func == (lhs: TailgatorMessage, rhs: TailgatorMessage) -> Bool {
        return lhs.messageId == rhs.messageId
    }
    
    static func < (lhs: TailgatorMessage, rhs: TailgatorMessage) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
    
}
