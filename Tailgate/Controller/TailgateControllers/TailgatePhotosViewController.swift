//
//  TailgatePhotosViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 10/28/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

class TailgatePhotosViewController: UIViewController {

    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet var emptyView: UIView!
    
    fileprivate let reuseIdentifier = "TailgateCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    fileprivate let itemsPerRow: CGFloat = 3
    
    
    var tailgate: Tailgate!
    var imageIds: [String] = []
    var imageUrls: [String] = []
    var state = CollectionState.loading {
        didSet {
            setCollectionBackgroundView()
        }
    }
    var selectedImageIndex: IndexPath? {
        didSet {
            var imagesToUpdate = [IndexPath]()
            if let selectedImageIndex = selectedImageIndex {
                // The image at this index was either selected or unselected so it needs to be updated
                imagesToUpdate.append(selectedImageIndex)
            }
            
            if let oldValue = oldValue {
                // If an old value existed for this variable, the image at that index needs to be updated (unselected)
                imagesToUpdate.append(oldValue)
            }
            
            // Update the indexes that need updating in the collection view
            imageCollectionView?.performBatchUpdates({
                self.imageCollectionView?.reloadItems(at: imagesToUpdate)
            }) { completed in
                // Scroll the enlarged selected image to the middle of the screen
                if let selectedImageIndex = self.selectedImageIndex {
                    self.imageCollectionView?.scrollToItem(
                        at: selectedImageIndex,
                        at: .centeredVertically,
                        animated: true)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        
        getTailgateImageUrls(tailgate: self.tailgate) { (imgUrls, imgIds) in
            self.imageIds = imgIds
            self.imageUrls = imgUrls
            self.imageCollectionView.reloadData()
        }
    }
    
    
    func setCollectionBackgroundView() {
        switch state {
        case .empty, .loading:
            imageCollectionView.backgroundView = emptyView
            imageCollectionView.backgroundView?.isHidden = false
        default:
            imageCollectionView.backgroundView?.isHidden = true
            imageCollectionView.backgroundView = nil
        }
    }

}




extension TailgatePhotosViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // If the tapped image is already the selected, set the largePhotoIndexPath property to nil, otherwise set it to the index path the user just tapped
        selectedImageIndex = selectedImageIndex == indexPath ? nil : indexPath
        return false
    }
}





extension TailgatePhotosViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if self.imageUrls.count > 0 {
            state = .populated
        } else {
            state = .empty
        }
        
        return self.imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! TailgateImageCollectionViewCell
        
        cell.delegate = self
        cell.imageView.sd_setImage(with: URL(string: self.imageUrls[indexPath.row]), completed: nil)
        
        // Show the delete button when the owner of the tailgate selects the image
        if let selectedIndex = self.selectedImageIndex, selectedIndex == indexPath, self.tailgate.ownerId == getCurrentUserId()  {
            cell.deleteButton.isHidden = false
        } else {
            cell.deleteButton.isHidden = true
        }
        
        // Show the share button when a user invited to the tailgate selects the image
        if let selectedIndex = self.selectedImageIndex, selectedIndex == indexPath  {
            if self.tailgate.invites.contains(configuration.currentUser) || self.tailgate.ownerId == getCurrentUserId() {
                cell.shareButton.isHidden = false
            } else {
                cell.shareButton.isHidden = true
            }
        } else {
            cell.shareButton.isHidden = true
        }
        
        return cell
    }
}





extension TailgatePhotosViewController : UICollectionViewDelegateFlowLayout {
    // responsible for telling the layout the size of a given cell
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Check if the current cell is the selected image
        if indexPath == selectedImageIndex {
            let maxWidth = collectionView.bounds.width - (sectionInsets.left + sectionInsets.right)
            return CGSize(width: maxWidth, height: maxWidth)
        }
        
        // Here, you work out the total amount of space taken up by padding.
        // There will be n + 1 evenly sized spaces, where n is the number of items in the row. The space size can be taken from the left section inset.
        // Subtracting this from the view’s width and dividing by the number of items in a row gives you the width for each item. You then return the size as a square
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = collectionView.bounds.width - paddingSpace
        let widthPerItem = floor(availableWidth / itemsPerRow)
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //  returns the spacing between the cells, headers, and footers. A constant is used to store the value
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // This method controls the spacing between each line in the layout. You want this to match the padding at the left and right
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0;
    }
}





extension TailgatePhotosViewController : TailgateImageCellDelegate {
    func delete(cell: TailgateImageCollectionViewCell) {
        if let indexPath = self.imageCollectionView.indexPath(for: cell) {
            let deleteConfirmationAlert = UIAlertController(title: nil, message: "Are you sure you want to delete this tailgate photo?", preferredStyle: .alert)
            
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                let imageId: String = self.imageIds[indexPath.row]
                
                // From the image from storage
                deleteTailgateImage(tailgate: self.tailgate, imageId: imageId)
                
                // Remove the entry from the collection view data source
                self.imageIds.remove(at: indexPath.row)
                self.imageUrls.remove(at: indexPath.row)
                
                // Delete the entry from the collection view itself
                self.imageCollectionView.deleteItems(at: [indexPath])
            }
            deleteConfirmationAlert.addAction(deleteAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                // canceled
            }
            deleteConfirmationAlert.addAction(cancelAction)
            
            self.present(deleteConfirmationAlert, animated: true, completion: nil)
        }
    }
    
    func share(cell: TailgateImageCollectionViewCell) {
        let activityController = UIActivityViewController(activityItems: [cell.imageView.image!], applicationActivities: [])
        
        if let popoverController = activityController.popoverPresentationController {
            popoverController.sourceView = (cell).superview
            popoverController.sourceRect = (cell).frame
        }
        
        self.present(activityController, animated: true)
    }
}
