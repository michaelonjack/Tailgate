//
//  TailgateMessagesViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 10/28/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit
import AVFoundation
import MessageKit
import MessageInputBar
import FirebaseDatabase
import YPImagePicker
import SDWebImage

class TailgateMessagesViewController: MessagesViewController {

    var tailgate: Tailgate!
    var lastSelectedMessageId:String!
    var messages:[TailgatorMessage] = []
    
    override func viewDidLoad() {
        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: TailgatorMessagesFlowLayout())
        super.viewDidLoad()

        messagesCollectionView.register(TailgatorTextMessageCell.self)
        messagesCollectionView.register(TailgatorMediaMessageCell.self)
        
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
        
        setupGestureRecognizers()
        loadMessages()
        setKeyboardStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.resignFirstResponder()
        
        // Once the user exits, do a mass save of their upvoted/downvoted messages
        saveVotedMessages(forUser: configuration.currentUser)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.resignFirstResponder()
    }
    
    
    func setupGestureRecognizers() {
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapGesture(_:)))
        doubleTapGesture.delaysTouchesBegan = true
        doubleTapGesture.numberOfTapsRequired = 2
        messagesCollectionView.addGestureRecognizer(doubleTapGesture)
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSingleTapGesture(_:)))
        singleTapGesture.delaysTouchesBegan = true
        messagesCollectionView.addGestureRecognizer(singleTapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        longPressGesture.delaysTouchesBegan = true
        messagesCollectionView.addGestureRecognizer(longPressGesture)
    }
    
    @objc
    open func handleDoubleTapGesture(_ gesture: UIGestureRecognizer) {
        guard gesture.state == .ended else { return }
        
        let touchLocation = gesture.location(in: messagesCollectionView)
        guard let indexPath = messagesCollectionView.indexPathForItem(at: touchLocation) else { return }
        
        if let cell = messagesCollectionView.cellForItem(at: indexPath) as? TailgatorTextMessageCell {
            cell.handleDoubleTapGesture(gesture)
        } else if let cell = messagesCollectionView.cellForItem(at: indexPath) as? TailgatorMediaMessageCell {
            cell.handleDoubleTapGesture(gesture)
        }
    }
    
    @objc
    open func handleSingleTapGesture(_ gesture: UIGestureRecognizer) {
        guard gesture.state == .ended else { return }
        
        self.becomeFirstResponder()
        messagesCollectionView.handleTapGesture(gesture)
    }
    
    @objc
    open func handleLongPressGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: messagesCollectionView)
        guard let indexPath = messagesCollectionView.indexPathForItem(at: touchLocation) else { return }
        
        if let cell = messagesCollectionView.cellForItem(at: indexPath) as? TailgatorTextMessageCell {
            cell.handleLongPressGesture(gesture)
        } else if let cell = messagesCollectionView.cellForItem(at: indexPath) as? TailgatorMediaMessageCell {
            cell.handleLongPressGesture(gesture)
        }
    }
    
    func insertNewMessage(message: TailgatorMessage) {
        guard !messages.contains(message) else { return }
        
        messages.append(message)
        messages.sort()
        messagesCollectionView.reloadData()
        
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToBottom(animated: true)
        }
        
        if let url = message.imgUrl, message.mediaStatus == .notLoaded {
            
            var _message = message
            
            // Update the media status to show the image is already being fetched
            _message.mediaStatus = .loading
            print("loading")
            self.messages[self.messages.firstIndex(of: _message)!] = _message
            
            SDWebImageDownloader.shared().downloadImage(with: url, options: SDWebImageDownloaderOptions(rawValue: 0), progress: nil, completed: { (image, data, error, bool) in
                
                let currentIndex = self.messages.firstIndex(of: _message)!
                
                if error != nil {
                    _message.mediaStatus = .error
                    print("error")
                    self.messages[currentIndex] = _message
                }
                    
                else if let image = image {
                    _message.mediaStatus = .loaded
                    print("loaded")
                    let mediaItem = ImageMediaItem(image: image)
                    _message.kind = .photo(mediaItem)
                    self.messages[currentIndex] = _message
                    
                    DispatchQueue.main.async {
                        self.messagesCollectionView.reloadSections(IndexSet(integer: currentIndex))
                    }
                }
            })
        }

    }
    
    func loadMessages() {
        let messagesPath:String = "tailgates/" + tailgate.id + "/messages"
        
        let messagesReference = Database.database().reference(withPath: messagesPath)
        messagesReference.keepSynced(true)
        
        // Child Added data events are called on every node currently at the location AND any time a node is added to the location
        messagesReference.observe(.childAdded) { (snapshot) in
            self.insertNewMessage(message: TailgatorMessage(snapshot: snapshot) )
        }
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return messages[indexPath.section].sender == messages[indexPath.section - 1].sender
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messages.count else { return false }
        return messages[indexPath.section].sender == messages[indexPath.section + 1].sender
    }
    
    func updateTopStackView(forNewItem newItem: InputBarButtonItem? = nil, ofWidth width:CGFloat? = nil) {
        
        // If there aren't any images attached to the message, hide the top stack view
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
        
        for item in self.messageInputBar.topStackViewItems {
            if let barButtonItem = item as? InputBarButtonItem, barButtonItem.image != nil {
                usedSpace = usedSpace + barButtonItem.bounds.size.width + stackViewSpacing
            }
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
            topStackViewItems.append(InputBarButtonItem.fixedSpace(emptySpace))
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
                            
                            stackItems.remove(at: stackItems.index{
                                if let barButtonItem = $0 as? InputBarButtonItem, barButtonItem == imageButton {
                                    return true
                                } else {
                                    return false
                                }
                            }!)
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
        
        messageInputBar.setLeftStackViewWidthConstant(to: 40, animated: false)
        messageInputBar.setStackViewItems(buttons, forStack: .left, animated: false)
        
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.leftStackView.distribution = .equalCentering
        messageInputBar.rightStackView.alignment = .center
        messageInputBar.rightStackView.distribution = .equalCentering
    }
    
    
    
    func uploadTailgatorMessage(message: TailgatorMessage) {
        
        let messagesPath:String = "tailgates/" + tailgate.id + "/messages"
        let dbReference = Database.database().reference(withPath: messagesPath)
        
        switch message.kind {
        case .text(_):
            dbReference.updateChildValues([message.messageId : message.toAnyObject()])
        case .photo(let mediaType):
            let timestamp:String = getTimestampString()
            let imgUploadPath:String = "images/users/" + tailgate.ownerId + "/tailgate/" + tailgate.id + "/messages/" + timestamp
            
            if let image = mediaType.image {
                uploadImageToStorage(image: image, uploadPath: imgUploadPath) { (downloadUrlStr) in
                    if let downloadUrlStr = downloadUrlStr, let downloadUrl = URL(string: downloadUrlStr) {
                        var mutatedMessage = message
                        mutatedMessage.imgUrl = downloadUrl
                        
                        dbReference.updateChildValues([mutatedMessage.messageId : mutatedMessage.toAnyObject()])
                    }
                }
            }
        default:
            break
        }
    }
    
    
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
            fatalError("The collectionView is not a MessagesCollectionView.")
        }
        
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("MessagesDataSource has not been set.")
        }
        
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        
        switch message.kind {
        case .text, .attributedText, .emoji:
            let cell = messagesCollectionView.dequeueReusableCell(TailgatorTextMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .photo, .video:
            let cell = messagesCollectionView.dequeueReusableCell(TailgatorMediaMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .location:
            let cell = messagesCollectionView.dequeueReusableCell(LocationMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .custom:
            let cell = messagesCollectionView.dequeueReusableCell(TailgatorTextMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        }
    }
}



extension TailgateMessagesViewController: MessagesDataSource {
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func currentSender() -> Sender {
        return Sender(id: configuration.currentUser.uid, displayName: configuration.currentUser.name)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: message.sender.displayName, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if let message = message as? TailgatorMessage {
            var scoreString = String(message.score)
            
            if configuration.currentUser.didUpvoteMessage(withId: message.messageId) {
                scoreString = scoreString + " 👍"
            } else if configuration.currentUser.didDownvoteMessage(withId: message.messageId) {
                scoreString = scoreString + " 👎"
            }
            
            var messagesCopy = self.messages
            messagesCopy.sort(by: { $0.score > $1.score })
            if message.messageId == messagesCopy[0].messageId {
                scoreString = scoreString + " 🏆"
            }
            
            return NSAttributedString(string: scoreString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
        }
        
        return NSAttributedString(string: "Score: ", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
}



extension TailgateMessagesViewController: MessagesLayoutDelegate {
    // Handled by TailgatorMessagesFlowLayout now
    //func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat
    
    // Handled by TailgatorMessagesFlowLayout now
    //func heightForMedia(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat
    
    // Handled by TailgatorMessagesFlowLayout now
    //func widthForMedia(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
}






extension TailgateMessagesViewController: MessagesDisplayDelegate {
    
    
    
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
        
        if let message = message as? TailgatorMessage {
            if let sendingUser = message.user, let profilePictureUrlStr = sendingUser.profilePictureUrl {
                let profilePictureUrl = URL(string: profilePictureUrlStr)
                
                SDWebImageDownloader.shared().downloadImage(with: profilePictureUrl, options: SDWebImageDownloaderOptions(rawValue: 0), progress: nil, completed: { (image, data, error, bool) in
                    
                    var profilePicture: UIImage = UIImage(named: "Avatar")!
                    if let image = image, error == nil {
                        profilePicture = image
                        
                        let avatar = Avatar(image: profilePicture, initials: "")
                        avatarView.set(avatar: avatar)
                    }
                })
            }
            
            else {
                let sendingUserId = message.userId
                getUserById(userId: sendingUserId) { (user) in
                    if let profilePictureUrlStr = user.profilePictureUrl {
                        
                        let profilePictureUrl = URL(string: profilePictureUrlStr)
                        
                        SDWebImageDownloader.shared().downloadImage(with: profilePictureUrl, options: SDWebImageDownloaderOptions(rawValue: 0), progress: nil, completed: { (image, data, error, bool) in
                            
                            var profilePicture: UIImage = UIImage(named: "Avatar")!
                            if let image = image, error == nil {
                                profilePicture = image
                                
                                let avatar = Avatar(image: profilePicture, initials: "")
                                avatarView.set(avatar: avatar)
                            }
                        })
                    }
                }
            }
        }
        
        avatarView.contentMode = .scaleAspectFit
        avatarView.clipsToBounds = true
        avatarView.setCorner(radius: avatarView.frame.height / 2)
        avatarView.backgroundColor = .clear
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






extension TailgateMessagesViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        // Check if any images were uploaded in the top stack view
        for topBarItem in self.messageInputBar.topStackViewItems {
            if let topBarItem = topBarItem as? InputBarButtonItem, let itemImage = topBarItem.image {
                var imageMessage = TailgatorMessage(image: itemImage, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                imageMessage.mediaStatus = .loaded
                
                uploadTailgatorMessage(message: imageMessage)
                insertNewMessage(message: imageMessage)
            }
        }
        
        // Clear the top stack view now that the images have been sent
        messageInputBar.setStackViewItems([], forStack: .top, animated: false)
        updateTopStackView()
        
        for component in inputBar.inputTextView.components {
            
            if let image = component as? UIImage {
                var imageMessage = TailgatorMessage(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                imageMessage.mediaStatus = .loaded
                
                uploadTailgatorMessage(message: imageMessage)
                insertNewMessage(message: imageMessage)
            }
                
            else if let text = component as? String {
                let textMessage = TailgatorMessage(text: text, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                
                uploadTailgatorMessage(message: textMessage)
                insertNewMessage(message: textMessage)
            }
        }
        
        inputBar.inputTextView.text = String()
        
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToBottom(animated: true)
        }
    }
}






extension TailgateMessagesViewController: TailgatorMessageCellDelegate {
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom message label tapped")
    }
    
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("Accessory view tapped")
    }
    
    func didDoubleTapTopCell(in cell: MessageCollectionViewCell) {
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            var tappedMessage = messages[indexPath.section]
            var scoreDifference = 0
            
            if configuration.currentUser.didUpvoteMessage(withId: tappedMessage.messageId) {
                configuration.currentUser.removeVoteFromMessage(withId: tappedMessage.messageId)
                tappedMessage.score = tappedMessage.score - 1
                scoreDifference = -1
            } else if configuration.currentUser.didDownvoteMessage(withId: tappedMessage.messageId) {
                configuration.currentUser.removeVoteFromMessage(withId: tappedMessage.messageId)
                configuration.currentUser.upvoteMessage(withId: tappedMessage.messageId)
                tappedMessage.score = tappedMessage.score + 2
                scoreDifference = 2
            } else {
                configuration.currentUser.upvoteMessage(withId: tappedMessage.messageId)
                tappedMessage.score = tappedMessage.score + 1
                scoreDifference = 1
            }
            
            // Update the vote count in the database
            let messageReference = Database.database().reference(withPath: "tailgates/" + tailgate.id + "/messages/" + tappedMessage.messageId)
            messageReference.keepSynced(true)
            messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
                let message = TailgatorMessage(snapshot: snapshot)
                let updatedMessageScore = message.score + scoreDifference
                messageReference.updateChildValues(["score":updatedMessageScore])
            }, withCancel: nil)
            
            messages[indexPath.section] = tappedMessage
            
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    func didDoubleTapBottomCell(in cell: MessageCollectionViewCell) {
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            var tappedMessage = messages[indexPath.section]
            var scoreDifference = 0
            
            if configuration.currentUser.didUpvoteMessage(withId: tappedMessage.messageId) {
                configuration.currentUser.removeVoteFromMessage(withId: tappedMessage.messageId)
                configuration.currentUser.downvoteMessage(withId: tappedMessage.messageId)
                tappedMessage.score = tappedMessage.score - 2
                scoreDifference = -2
                
            } else if configuration.currentUser.didDownvoteMessage(withId: tappedMessage.messageId) {
                configuration.currentUser.removeVoteFromMessage(withId: tappedMessage.messageId)
                tappedMessage.score = tappedMessage.score + 1
                scoreDifference = 1
            } else {
                configuration.currentUser.downvoteMessage(withId: tappedMessage.messageId)
                tappedMessage.score = tappedMessage.score - 1
                scoreDifference = -1
            }
            
            // Update the vote count in the database
            let messageReference = Database.database().reference(withPath: "tailgates/" + tailgate.id + "/messages/" + tappedMessage.messageId)
            messageReference.keepSynced(true)
            messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
                let message = TailgatorMessage(snapshot: snapshot)
                let updatedMessageScore = message.score + scoreDifference
                messageReference.updateChildValues(["score":updatedMessageScore])
            }, withCancel: nil)
            
            messages[indexPath.section] = tappedMessage
            
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    func didLongPressMessage(in cell: MessageCollectionViewCell) {
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actions = [
            UIAlertAction(title: "Copy", style: .default, handler: { (_) in
                if let indexPath = self.messagesCollectionView.indexPath(for: cell) {
                    let tappedMessage = self.messages[indexPath.section]
                    
                    switch tappedMessage.kind {
                    case .text(let message), .emoji(let message):
                        UIPasteboard.general.string = message
                    case .attributedText(let attrMessage):
                        UIPasteboard.general.string = attrMessage.string
                    case .photo(let mediaItem):
                        UIPasteboard.general.image = mediaItem.image
                    case .video(let mediaItem):
                        UIPasteboard.general.string = mediaItem.url?.absoluteString
                    default:
                        break
                    }
                }
            }),
            UIAlertAction(title: "Report Message", style: .destructive, handler: { (_) in
                if let indexPath = self.messagesCollectionView.indexPath(for: cell) {
                    let tappedMessage = self.messages[indexPath.section]
                    self.lastSelectedMessageId = tappedMessage.messageId
                    self.performSegue(withIdentifier: "MessagesToReport", sender: nil)
                }
            }),
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ]
        actions.forEach { actionSheetController.addAction($0) }
        present(actionSheetController, animated: true, completion: nil)
    }
}
