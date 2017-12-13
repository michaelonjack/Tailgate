//
//  TailgateViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/12/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import YPImagePicker

class TailgateViewController: UIViewController {

    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var trashButton: UIButton!
    
    fileprivate let reuseIdentifier = "TailgateCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    fileprivate let itemsPerRow: CGFloat = 3
    
    var imageUrls: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        
        getTailgateImageUrlsForUser(userid: (Auth.auth().currentUser?.uid)!) { imgUrls in
            self.imageUrls = imgUrls
            self.imageCollectionView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.containerSwipeNavigationController?.showEmbeddedView(position: .center)
    }
    
    @IBAction func trashButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        var ypConfig = YPImagePickerConfiguration()
        ypConfig.onlySquareImagesFromCamera = true
        ypConfig.onlySquareImagesFromLibrary = true
        ypConfig.showsFilters = true
        ypConfig.showsVideo = false
        ypConfig.usesFrontCamera = false
        ypConfig.shouldSaveNewPicturesToAlbum = false
        
        let picker = YPImagePicker(configuration: ypConfig)
        picker.didSelectImage = { image in
            
            uploadTailgatePictureForUser(userid: (Auth.auth().currentUser?.uid)!, image: image) {
                downloadUrl in
                
                if let imageUrl = downloadUrl {
                    
                    self.imageUrls.append(imageUrl)
                    self.imageCollectionView.reloadData()
                }
            }
            
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
}



extension TailgateViewController: UICollectionViewDataSource {
    // There’s one search per section, so the number of sections is the count of the searches array
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // The number of items in a section is the count of the searchResults array from the relevant FlickrSearch object.
    func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return self.imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // The cell coming back is now a FlickrPhotoCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! TailgatePhotoCell
        cell.imageView.sd_setImage(with: URL(string: self.imageUrls[indexPath.row]), completed: nil)
        
        return cell
    }
}





extension TailgateViewController : UICollectionViewDelegateFlowLayout {
    // responsible for telling the layout the size of a given cell
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
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
