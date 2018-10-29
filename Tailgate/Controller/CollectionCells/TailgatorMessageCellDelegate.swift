//
//  TailgatorMessageCellDelegate.swift
//  Tailgate
//
//  Created by Michael Onjack on 10/28/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import Foundation
import MessageKit

public protocol TailgatorMessageCellDelegate: MessageCellDelegate {
    /// Triggered when a double tap occurs in the top half of the cell
    ///
    /// - Parameters:
    ///   - cell: The cell where the touch occurred.
    ///
    /// You can get a reference to the `MessageType` for the cell by using `UICollectionView`'s
    /// `indexPath(for: cell)` method. Then using the returned `IndexPath` with the `MessagesDataSource`
    /// method `messageForItem(at:indexPath:messagesCollectionView)`.
    func didDoubleTapTopCell(in cell: MessageCollectionViewCell)
    
    /// Triggered when a double tap occurs in the bottom half of the cell
    ///
    /// - Parameters:
    ///   - cell: The cell where the touch occurred.
    ///
    /// You can get a reference to the `MessageType` for the cell by using `UICollectionView`'s
    /// `indexPath(for: cell)` method. Then using the returned `IndexPath` with the `MessagesDataSource`
    /// method `messageForItem(at:indexPath:messagesCollectionView)`.
    func didDoubleTapBottomCell(in cell: MessageCollectionViewCell)
    
    /// Triggered when a long press occurs in the `MessageContainerView`.
    ///
    /// - Parameters:
    ///   - cell: The cell where the touch occurred.
    ///
    /// You can get a reference to the `MessageType` for the cell by using `UICollectionView`'s
    /// `indexPath(for: cell)` method. Then using the returned `IndexPath` with the `MessagesDataSource`
    /// method `messageForItem(at:indexPath:messagesCollectionView)`.
    func didLongPressMessage(in cell: MessageCollectionViewCell)
}

public extension TailgatorMessageCellDelegate {
    func didDoubleTapTopCell(in cell: MessageCollectionViewCell) {}
    
    func didDoubleTapBottomCell(in cell: MessageCollectionViewCell) {}
    
    func didLongPressMessage(in cell: MessageCollectionViewCell) {}
}
