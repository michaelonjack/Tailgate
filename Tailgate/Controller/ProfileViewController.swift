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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.invitesCollectionView.delegate = self
        self.invitesCollectionView.dataSource = self
        let vegaLayout = VegaScrollFlowLayout()
        self.invitesCollectionView.collectionViewLayout = vegaLayout
        vegaLayout.minimumLineSpacing = 15
        vegaLayout.itemSize = CGSize(width: self.invitesCollectionView.frame.width - 16, height: 100)
        vegaLayout.sectionInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        vegaLayout.springHardness = 60
       
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
                
                uploadProfilePictureForUser(userid: (Auth.auth().currentUser?.uid)!, image: image)
                
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
        return false
    }
}



extension ProfileViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // The cell coming back is now a FlickrPhotoCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCell",
                                                      for: indexPath) as! FeedCollectionViewCell
        cell.titleLabel.text = "Testinggggg"
        cell.detailLabel.text = "blah blah blah blah"
        cell.imageView.layer.cornerRadius = 0.5 * cell.imageView.layer.bounds.width
        cell.imageView.clipsToBounds = true
        
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





