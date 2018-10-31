//
//  TailgatorMessagesFlowLayout.swift
//  Tailgate
//
//  Created by Michael Onjack on 10/29/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import Foundation
import AVFoundation
import MessageKit
import SDWebImage

open class TailgatorMessagesFlowLayout: MessagesCollectionViewFlowLayout {
    
    open lazy var customPhotoMessageSizeCalculator = CustomPhotoMessageSizeCalculator(layout: self)
    
    open override func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
        
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .photo = message.kind {
            return customPhotoMessageSizeCalculator
        }
        
        return super.cellSizeCalculatorForItem(at: indexPath)
    }
    
    open override func messageSizeCalculators() -> [MessageSizeCalculator] {
        var superCalculators = super.messageSizeCalculators()
        // Append any of your custom `MessageSizeCalculator` if you wish for the convenience
        // functions to work such as `setMessageIncoming...` or `setMessageOutgoing...`
        superCalculators.append(customPhotoMessageSizeCalculator)
        return superCalculators
    }
}






open class CustomPhotoMessageSizeCalculator: MessageSizeCalculator {
    
    
    open override func messageContainerSize(for message: MessageType) -> CGSize {
        guard let message = message as? TailgatorMessage else { return .zero }
        
        let maxWidth = messageContainerMaxWidth(for: message)
        let sizeForMediaItem = { (maxWidth: CGFloat, item: MediaItem) -> CGSize in
            if maxWidth < item.size.width {
                // Maintain the ratio if width is too great
                let height = maxWidth * item.size.height / item.size.width
                return CGSize(width: maxWidth, height: height)
            }
            return item.size
        }
        
        
        switch message.kind {
        case .photo(let item):
            switch message.mediaStatus {
            case .loaded:
                return sizeForMediaItem(maxWidth, item)
            case .error, .loading, .notLoaded:
                return CGSize(width: 40, height: 40)
            }
            
        case .video(let item):
            return sizeForMediaItem(maxWidth, item)
        default:
            fatalError("messageContainerSize received unhandled MessageDataType: \(message.kind)")
        }
    }
    
}

