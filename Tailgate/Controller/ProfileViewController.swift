//
//  ProfileViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/10/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import UIKit
import Firebase
import YPImagePicker
import SDWebImage
import VegaScrollFlowLayout

class ProfileViewController: UIViewController {

    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var invitesCollectionView: UICollectionView!
    
    let currentUserRef = Database.database().reference(withPath: "users/" + (Auth.auth().currentUser?.uid)!)
    let currentUserStorageRef = Storage.storage().reference(withPath: "images/" + (Auth.auth().currentUser?.uid)!)
    
    var feedItems:[Tailgate] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doStuff()
        self.invitesCollectionView.delegate = self
        self.invitesCollectionView.dataSource = self
        let vegaLayout = VegaScrollFlowLayout()
        self.invitesCollectionView.collectionViewLayout = vegaLayout
        vegaLayout.minimumLineSpacing = 15
        vegaLayout.itemSize = CGSize(width: self.invitesCollectionView.frame.width - 16, height: 90)
        vegaLayout.sectionInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        vegaLayout.springHardness = 60
        
        // Get all public tailgates and tailgates the current user is invited to
        getTailgatesToDisplay { (tailgates) in
            self.feedItems = tailgates
            self.invitesCollectionView.reloadData()
        }
       
        loadProfilePicture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    /////////////////////////////////////////////////////
    //
    // loadProfilePicture
    //
    //  Pulls the user's profile picture from the database if it exists
    //
    func loadProfilePicture() {
        // Load the stored image
        currentUserRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let storedData = snapshot.value as? NSDictionary
            
            // Load user's profile picture from Firebase Storage if it exists (exists if the user has a profPic URL in the database)
            if snapshot.hasChild("profilePictureUrl") {
                let picUrlStr = storedData?["profilePictureUrl"] as? String ?? ""
                if picUrlStr != "" {
                    let picUrl = URL(string: picUrlStr)
                    self.profilePictureButton.sd_setImage(with: picUrl, for: .normal, placeholderImage: UIImage(named: "Avatar"))
                    
                    // round picture corners
                    self.profilePictureButton.layer.cornerRadius = 8.0
                    self.profilePictureButton.clipsToBounds = true
                }
            } else {
                print("Error -- Loading Profile Picture")
            }
        })
    }
    
    
    
    @IBAction func profilePicturePressed(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            var ypConfig = YPImagePickerConfiguration()
            ypConfig.onlySquareImagesFromCamera = true
            ypConfig.onlySquareImagesFromLibrary = true
            ypConfig.showsFilters = true
            ypConfig.showsVideoInLibrary = false
            ypConfig.usesFrontCamera = false
            ypConfig.shouldSaveNewPicturesToAlbum = false
            
            let picker = YPImagePicker(configuration: ypConfig)
            picker.didSelectImage = { image in
                // Sets the user's profile picture to be this image
                self.profilePictureButton.setImage(image, for: .normal)
                self.profilePictureButton.imageView?.contentMode = .scaleAspectFill
                
                let uploadPath = "images/" + getCurrentUserId() + "/ProfilePicture"
                uploadImageToStorage(image: image, uploadPath: uploadPath, completion: { (downloadUrl) in
                    updateValueForCurrentUser(key: "profilePictureUrl", value: downloadUrl!)
                })
                
                picker.dismiss(animated: true, completion: nil)
            }
            present(picker, animated: true, completion: nil)
        } else {
            print("Error -- Camera")
        }
    }
    
    @IBAction func aroundMePressed(_ sender: Any) {
        self.containerSwipeNavigationController?.showEmbeddedView(position: .left)
    }
    
    @IBAction func myTailgatePressed(_ sender: Any) {
        self.containerSwipeNavigationController?.showEmbeddedView(position: .right)
    }
    
}





extension ProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedFeedItem = self.feedItems[indexPath.row]
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let tailgateViewController = mainStoryboard.instantiateViewController(withIdentifier: "TailgateViewController") as! TailgateViewController
        tailgateViewController.tailgate = selectedFeedItem
        tailgateViewController.hasFullAccess = false
        self.present(tailgateViewController, animated: true, completion: nil)
    }
}



extension ProfileViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.feedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // The cell coming back is now a FlickrPhotoCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCell", for: indexPath) as! FeedCollectionViewCell
        
        let currentFeedItem = self.feedItems[indexPath.row]
        
        cell.titleLabel.text = currentFeedItem.name
        cell.imageView.layer.cornerRadius = 0.5 * cell.imageView.layer.bounds.width
        cell.imageView.clipsToBounds = true
        cell.activityTypeIndicator.layer.cornerRadius = 0.5 * cell.activityTypeIndicator.layer.bounds.width
        
        if currentFeedItem.isPublic {
            cell.activityTypeIndicator.backgroundColor = .lavender
        } else {
            cell.activityTypeIndicator.backgroundColor = .red
        }
        
        getUserById(userId: currentFeedItem.ownerId) { (user) in
            DispatchQueue.main.async {
                cell.detailLabel.text = user.name + " - " + currentFeedItem.school.name
                if let profilePicUrl = user.profilePictureUrl {
                    cell.imageView.sd_setImage(with: URL(string: profilePicUrl), completed: nil)
                }
            }
        }
        
        cell.contentView.layer.cornerRadius = 8.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.layer.shadowRadius = 8.0
        cell.layer.shadowOpacity = 0.7
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
        return cell
    }
}



extension ProfileViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width-16, height: 90.0)
    }
}





