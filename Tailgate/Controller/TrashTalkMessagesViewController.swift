//
//  TrashTalkMessagesViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 7/9/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit
import AVFoundation
import MessageKit
import YPImagePicker
import FirebaseDatabase
import SDWebImage

class TrashTalkMessagesViewController: MessagesViewController {
    
    var messages:[TrashTalkMessage] = []
    var game: Game!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = false
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        
        messageInputBar.topStackView.axis = .horizontal
        messageInputBar.topStackView.spacing = 5.0
        messageInputBar.topStackView.alignment = .center
        messageInputBar.topStackView.distribution = .fillProportionally
        updateTopStackView()
        
        
        loadMessages()
        setKeyboardStyle()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadMessages() {
        let threadName:String = game.awayTeam.replacingOccurrences(of: " ", with: "") + "at" + game.homeTeam.replacingOccurrences(of: " ", with: "")
        let messagesPath:String = "trashtalk/" + configuration.week + "/" + threadName + "/mesages"
        
        let messagesReference = Database.database().reference(withPath: messagesPath)
        messagesReference.keepSynced(true)
        
        messagesReference.observeSingleEvent(of: .value) { (snapshot) in
            for messageSnapshot in snapshot.children {
                self.messages.append( TrashTalkMessage(snapshot: messageSnapshot as! DataSnapshot) )
            }
            
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadData()
            }
        }
    }
    
    
    func updateTopStackView(forNewItem newItem: InputBarButtonItem? = nil, ofWidth width:CGFloat? = nil) {
        
        //
        if messageInputBar.topStackViewItems.count == 0 && newItem == nil {
            self.messageInputBar.sendButton.isEnabled = false
            messageInputBar.topStackViewPadding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
            self.messageInputBar.setStackViewItems([], forStack: .top, animated: true)
            return
        }
        
        // Calculate the size of the new fixed space entry
        var topStackViewItems = self.messageInputBar.topStackViewItems
        let stackViewSpacing = self.messageInputBar.topStackView.spacing
        var usedSpace:CGFloat = newItem == nil ? 0 : width! + stackViewSpacing
        
        for item in self.messageInputBar.topStackViewItems where item.image != nil {
            usedSpace = usedSpace + item.bounds.size.width + stackViewSpacing
        }
        
        let emptySpace = self.messageInputBar.bounds.size.width - usedSpace - self.messageInputBar.topStackViewPadding.left - self.messageInputBar.topStackViewPadding.right
        
        // Remove the fixed space entry if it exists
        if topStackViewItems.count > 0 {
            topStackViewItems.removeLast()
        }
        // Add the button
        if let newItem = newItem {
            topStackViewItems.append(newItem)
        }
        // If there are images in the top stack view, add the empty right padding
        if topStackViewItems.count > 0 {
            topStackViewItems.append(.fixedSpace(emptySpace))
        }
        
        if topStackViewItems.count > 0 {
            self.messageInputBar.sendButton.isEnabled = true
            messageInputBar.topStackViewPadding = UIEdgeInsets(top: 8, left: 5, bottom: 0, right: 5)
        } else {
            self.messageInputBar.sendButton.isEnabled = false
            messageInputBar.topStackViewPadding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        }
        
        self.messageInputBar.setStackViewItems(topStackViewItems, forStack: .top, animated: true)
    }

    
    
    func setKeyboardStyle() {
        messageInputBar.backgroundView.backgroundColor = .white
        messageInputBar.isTranslucent = false
        messageInputBar.inputTextView.backgroundColor = .clear
        messageInputBar.inputTextView.layer.borderWidth = 0
        
        let cameraButton = InputBarButtonItem()
        cameraButton.image = UIImage(named: "Camera")?.withRenderingMode(.alwaysTemplate)
        cameraButton.setSize(CGSize(width: 30.0, height: 30.0), animated: true)
        cameraButton.tintColor = UIColor.lightGray
        
        cameraButton.onSelected { (barButtonItem) in
            cameraButton.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        }
        cameraButton.onDeselected { (barButtonItem) in
            cameraButton.tintColor = UIColor.lightGray
        }
        cameraButton.onTouchUpInside { (barButtonItem) in
            var ypConfig = YPImagePickerConfiguration()
            ypConfig.onlySquareImagesFromCamera = false
            ypConfig.library.onlySquare = false
            ypConfig.showsFilters = false
            ypConfig.library.mediaType = .photo
            ypConfig.usesFrontCamera = false
            ypConfig.shouldSaveNewPicturesToAlbum = false
            
            let picker = YPImagePicker(configuration: ypConfig)
            picker.didFinishPicking { items, _ in
                if let photo = items.singlePhoto {
                    
                    let imageButton = InputBarButtonItem()
                    imageButton.image = photo.image
                    imageButton.setSize(CGSize(width: photo.image.size.width/40, height: photo.image.size.height/40), animated: true)
                    imageButton.layer.cornerRadius = 8.0
                    imageButton.layer.masksToBounds = true
                    imageButton.onTouchUpInside({ (_) in
                        let removeImageAlert = UIAlertController(title: nil, message: "Remove image from message?", preferredStyle: .alert)
                        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { (action) in
                            var stackItems = self.messageInputBar.topStackViewItems
                            stackItems.remove(at: stackItems.index{$0 == imageButton}!)
                            self.messageInputBar.setStackViewItems(stackItems, forStack: .top, animated: false)
                            self.updateTopStackView()
                        }
                        removeImageAlert.addAction(removeAction)
                        
                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                            // canceled
                        }
                        removeImageAlert.addAction(cancelAction)
                        
                        self.present(removeImageAlert, animated: true, completion: nil)
                    })
                    
                    self.updateTopStackView(forNewItem: imageButton, ofWidth: photo.image.size.width/40)
                }
                picker.dismiss(animated: true, completion: nil)
            }
            self.present(picker, animated: true, completion: nil)
        }
        
        let buttons = [cameraButton]
        
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        messageInputBar.setStackViewItems(buttons, forStack: .left, animated: false)
        
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.leftStackView.distribution = .equalCentering
        messageInputBar.rightStackView.alignment = .center
        messageInputBar.rightStackView.distribution = .equalCentering
    }
    
    func uploadTrashTalkMessage(message: TrashTalkMessage) {
        
        let threadName:String = game.awayTeam.replacingOccurrences(of: " ", with: "") + "at" + game.homeTeam.replacingOccurrences(of: " ", with: "")
        let messagesPath:String = "trashtalk/" + configuration.week + "/" + threadName + "/mesages"
        let dbReference = Database.database().reference(withPath: messagesPath)
        
        switch message.data {
        case .text(_):
            dbReference.updateChildValues([message.messageId : message.toAnyObject()])
        case .photo(let image):
            let timestamp:String = getTimestampString()
            let imgUploadPath:String = "images/trashtalk/" + configuration.week + "/" + threadName + "/" + timestamp
            
            uploadImageToStorage(image: image, uploadPath: imgUploadPath) { (downloadUrlStr) in
                if let downloadUrlStr = downloadUrlStr, let downloadUrl = URL(string: downloadUrlStr) {
                    var mutatedMessage = message
                    mutatedMessage.imgUrl = downloadUrl
                    
                    dbReference.updateChildValues([mutatedMessage.messageId : mutatedMessage.toAnyObject()])
                }
            }
        default:
            break
        }
    }
}






extension TrashTalkMessagesViewController: MessagesDataSource {
    func currentSender() -> Sender {
        let currentUser = configuration.currentUser
        if let currentUserSchool = currentUser?.school {
            return Sender(id: currentUserSchool.name, displayName: currentUserSchool.teamName)
        } else {
            return Sender(id: "neutral", displayName: "Neutral Fan")
        }
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let formatter: DateFormatter = DateFormatter()
        formatter.dateStyle = .medium
        
        let dateString = formatter.string(from: message.sentDate)
        
        if let message = message as? TrashTalkMessage {
            let scoreString = "Score: " + String(message.score)
            let bottomLabelText = dateString + "   -   " + scoreString
            
            return NSAttributedString(string: bottomLabelText, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption2)])
        }
        
        return NSAttributedString(string: dateString, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
            fatalError("The collectionView is not a MessagesCollectionView.")
        }
        
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("MessagesDataSource has not been set.")
        }
        
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        
        switch message.data {
        case .text, .attributedText, .emoji:
            let cell = messagesCollectionView.dequeueReusableCell(TextMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .photo, .video:
            let cell = messagesCollectionView.dequeueReusableCell(MediaMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .location:
            let cell = messagesCollectionView.dequeueReusableCell(LocationMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        }
    }
}



extension TrashTalkMessagesViewController: MessagesLayoutDelegate {
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 10.0
    }
    
    func heightForMedia(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        if var message = message as? TrashTalkMessage {
        
            if let url = message.imgUrl, message.mediaStatus == .notLoaded {
            
                // Update the media status to show the image is already being fetched
                message.mediaStatus = .loading
                print("loading")
                self.messages[indexPath.section] = message
                
                SDWebImageDownloader.shared().downloadImage(with: url, options: SDWebImageDownloaderOptions(rawValue: 0), progress: nil, completed: { (image, data, error, bool) in
                    
                    if error != nil {
                        message.mediaStatus = .error
                        print("error")
                        self.messages[indexPath.section] = message
                    }
                    
                    else if let image = image {
                        message.mediaStatus = .loaded
                        print("loaded")
                        message.data = .photo(image)
                        self.messages[indexPath.section] = message
                        
                        DispatchQueue.main.async {
                            self.messagesCollectionView.reloadItems(at: [indexPath])
                        }
                    }
                })
            }
            
            switch message.mediaStatus {
            case .notLoaded, .loading, .error:
                return 40
            case .loaded:
                switch message.data {
                case .photo(let image), .video(_, let image):
                    let boundingRect = CGRect(origin: .zero, size: CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
                    return AVMakeRect(aspectRatio: image.size, insideRect: boundingRect).height
                default:
                    return 0
                }
            }
        }
        
        return 40
    }
    
    func widthForMedia(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if let message = message as? TrashTalkMessage {
            switch message.mediaStatus {
            case .notLoaded, .loading, .error:
                return 40
            case .loaded:
                return maxWidth
            }
        }
        
        return maxWidth
    }
}






extension TrashTalkMessagesViewController: MessagesDisplayDelegate {
    
    
    
    /////////////////////////////////////////////////////////////////
    //
    // messageStyle
    //
    // Adds the message bubble tail
    //
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    /////////////////////////////////////////////////////////////////
    //
    // configureAvatarView
    //
    // Determines which image should be used for each member in the conversation
    //
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        if let message = message as? TrashTalkMessage {
            if let senderTeam = message.senderTeam, let teamLogo = senderTeam.logoImageView.image {
                let avatar = Avatar(image: teamLogo, initials: "")
                avatarView.set(avatar: avatar)
                avatarView.contentMode = .scaleAspectFit
                avatarView.clipsToBounds = false
                avatarView.setCorner(radius: 0)
                avatarView.backgroundColor = .clear
            }
        }
    }
    
    /////////////////////////////////////////////////////////////////
    //
    // backgroundColor
    //
    // Sets the bubble color for each message
    //
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1) : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
}






extension TrashTalkMessagesViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        // Check if any images were uploaded in the top stack view
        for topBarItem in self.messageInputBar.topStackViewItems {
            if let itemImage = topBarItem.image {
                let imageMessage = TrashTalkMessage(image: itemImage, sender: currentSender(), messageId: UUID().uuidString, date: Date(), team: configuration.currentUser.school)
                
                uploadTrashTalkMessage(message: imageMessage)
                
                self.messages.append(imageMessage)
                self.messagesCollectionView.insertSections([messages.count-1])
            }
        }
        
        // Clear the top stack view now that the images have been sent
        messageInputBar.setStackViewItems([], forStack: .top, animated: false)
        updateTopStackView()
        
        for component in inputBar.inputTextView.components {
            
            if let image = component as? UIImage {
                let imageMessage = TrashTalkMessage(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date(), team: configuration.currentUser.school)
                
                uploadTrashTalkMessage(message: imageMessage)
                
                self.messages.append(imageMessage)
                self.messagesCollectionView.insertSections([messages.count-1])
            }
            
            else if let text = component as? String {
                let textMessage = TrashTalkMessage(text: text, sender: currentSender(), messageId: UUID().uuidString, date: Date(), team: configuration.currentUser.school)
                
                uploadTrashTalkMessage(message: textMessage)
                
                self.messages.append(textMessage)
                self.messagesCollectionView.insertSections([messages.count-1])
            }
        }
        
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
    }
}






extension TrashTalkMessagesViewController: MessageCellDelegate {
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    
    func didTapTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }
    
    func didDoubleTapTopCell(in cell: MessageCollectionViewCell) {
        print("Top of cell double tapped")
    }
    
    func didDoubleTapBottomCell(in cell: MessageCollectionViewCell) {
        print("Bottom of cell double tapped")
    }
}
