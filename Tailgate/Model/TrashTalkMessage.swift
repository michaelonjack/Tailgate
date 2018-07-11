//
//  TrashTalkMessage.swift
//  Tailgate
//
//  Created by Michael Onjack on 7/9/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import Foundation
import MessageKit

struct TrashTalkMessage: MessageType {
    var messageId: String
    var sender: Sender
    var sentDate: Date
    var data: MessageData
    var senderTeam: School?
    var score: Int
    
    private init(data: MessageData, sender: Sender, messageId: String, date: Date, team: School?) {
        self.data = data
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
        self.senderTeam = team
        self.score = 0
    }
    
    init(text: String, sender: Sender, messageId: String, date: Date, team: School?) {
        self.init(data: .text(text), sender: sender, messageId: messageId, date: date, team: team)
    }
    
    init(attributedText: NSAttributedString, sender: Sender, messageId: String, date: Date, team: School?) {
        self.init(data: .attributedText(attributedText), sender: sender, messageId: messageId, date: date, team: team)
    }
    
    init(image: UIImage, sender: Sender, messageId: String, date: Date, team: School?) {
        self.init(data: .photo(image), sender: sender, messageId: messageId, date: date, team: team)
    }
    
    init(emoji: String, sender: Sender, messageId: String, date: Date, team: School?) {
        self.init(data: .emoji(emoji), sender: sender, messageId: messageId, date: date, team: team)
    }
}
