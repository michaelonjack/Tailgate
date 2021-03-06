//
//  GamedaySignsViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 3/23/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit
import SDWebImage
import YPImagePicker
import NotificationBannerSwift

class GamedaySignsViewController: UIViewController {

    @IBOutlet weak var signCollectionView: UICollectionView!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var loadingView: UIView!
    
    let refreshControl = UIRefreshControl()
    fileprivate let reuseIdentifier = "SignCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    fileprivate let itemsPerRow: CGFloat = 3
    
    var imageUrls: [String] = []
    var selectedWeek: Int?
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
            signCollectionView?.performBatchUpdates({
                self.signCollectionView?.reloadItems(at: imagesToUpdate)
            }) { completed in
                // Scroll the enlarged selected image to the middle of the screen
                if let selectedImageIndex = self.selectedImageIndex {
                    self.signCollectionView?.scrollToItem(
                        at: selectedImageIndex,
                        at: .centeredVertically,
                        animated: true)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        state = .loading
        
        signCollectionView.delegate = self
        signCollectionView.dataSource = self
        self.addRefreshControl()
        
        // Get sign image urls
        getGamedaySignImageUrls { (imgUrls) in
            self.imageUrls = imgUrls
            
            if self.imageUrls.count > 0 {
                self.state = .populated
            } else {
                self.state = .empty
            }
            
            self.signCollectionView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            if let selectedWeek = self.selectedWeek {
                self.weekButton.setTitle("Week " + String(selectedWeek), for: .normal)
            } else {
                self.weekButton.setTitle("Week " + String(configuration.weekNum), for: .normal)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SignsToWeekPickerPopup" {
            guard let popupController = segue.destination as? PickerPopupViewController else {return}
            
            var values:[String] = []
            for i in 1..<configuration.weekNum+1 {
                values.append("Week " + String(i))
            }
            
            popupController.values = values
            if let selectedWeek = self.selectedWeek {
                popupController.initialIndex = selectedWeek-1
            } else {
                popupController.initialIndex =  configuration.weekNum-1
            }
            popupController.pickerPopupDelegate = self
        }
    }
    
    
    
    func setCollectionBackgroundView() {
        switch state {
        case .loading:
            signCollectionView.backgroundView = loadingView
            signCollectionView.backgroundView?.isHidden = false
        case .empty:
            signCollectionView.backgroundView = emptyView
            signCollectionView.backgroundView?.isHidden = false
        default:
            signCollectionView.backgroundView?.isHidden = true
            signCollectionView.backgroundView = nil
        }
    }
    
    

    @IBAction func submitSignPressed(_ sender: Any) {
        var ypConfig = YPImagePickerConfiguration()
        ypConfig.onlySquareImagesFromCamera = true
        ypConfig.library.onlySquare = true
        ypConfig.showsPhotoFilters = true
        ypConfig.library.mediaType = .photo
        ypConfig.usesFrontCamera = false
        ypConfig.shouldSaveNewPicturesToAlbum = false
        
        let picker = YPImagePicker(configuration: ypConfig)
        picker.didFinishPicking { items, _ in
            
            if let photo = items.singlePhoto {
                let uploadPath = "images/Gameday/" + configuration.season + "/" + configuration.week + "/submitted/" +  getTimestampString() + ".jpg"
                uploadImageToStorage(image: photo.image, uploadPath: uploadPath, completion: { (downloadUrl) in
                    // Nothing for now!
                })
                
                DispatchQueue.main.async {
                    picker.dismiss(animated: true, completion: nil)
                    let successBanner = NotificationBanner(attributedTitle: NSAttributedString(string: "Sign Submitted"), attributedSubtitle: NSAttributedString(string: "Check back to see if your sign gets posted!"), style: .success)
                    successBanner.show()
                }
            } else {
                picker.dismiss(animated: true, completion: nil)
            }
        }
        present(picker, animated: true, completion: nil)
    }
}



extension GamedaySignsViewController: PickerPopupDelegate {
    func selectPressed(popupController: PickerPopupViewController, selectedIndex: Int, selectedValue: String) {
        
        // Update the week button label to show the selected value
        DispatchQueue.main.async {
            popupController.dismiss(animated: true, completion: nil)
            self.weekButton.setTitle(selectedValue, for: .normal)
        }
        
        selectedWeek = selectedIndex + 1
        
        // Get the rankings for the selected week
        getGamedaySignImageUrls(forWeek: selectedWeek!) { (imgUrls) in
            self.imageUrls = imgUrls
            
            if self.imageUrls.count > 0 {
                self.state = .populated
            } else {
                self.state = .empty
            }
            
            DispatchQueue.main.async {
                self.signCollectionView.reloadData()
            }
        }
    }
}



extension GamedaySignsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // If the tapped image is already the selected, set the largePhotoIndexPath property to nil, otherwise set it to the index path the user just tapped
        selectedImageIndex = selectedImageIndex == indexPath ? nil : indexPath
        return false
    }
    
    func addRefreshControl() {
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            self.signCollectionView.refreshControl = self.refreshControl
        } else {
            self.signCollectionView.addSubview(self.refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(refreshSignsCollectionView(_:)), for: .valueChanged)
    }
    
    @objc private func refreshSignsCollectionView(_ sender: Any) {
        state = .loading
        
        // Get sign image urls
        getGamedaySignImageUrls(forWeek: selectedWeek ?? configuration.weekNum) { (imgUrls) in
            self.imageUrls = imgUrls
            
            if self.imageUrls.count > 0 {
                self.state = .populated
            } else {
                self.state = .empty
            }
            
            DispatchQueue.main.async {
                self.signCollectionView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
}



extension GamedaySignsViewController: UICollectionViewDataSource {
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
        // The cell coming back is now a FlickrPhotoCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! ImageCollectionViewCell
        cell.imageView.sd_setImage(with: URL(string: self.imageUrls[indexPath.row]), completed: nil)
        
        return cell
    }
}



extension GamedaySignsViewController : UICollectionViewDelegateFlowLayout {
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
