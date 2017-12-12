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

class ProfileViewController: UIViewController {

    @IBOutlet weak var profilePictureButton: UIButton!
    let currentUserRef = Database.database().reference(withPath: "users/" + (Auth.auth().currentUser?.uid)!)
    let currentUserStorageRef = Storage.storage().reference(withPath: "images/" + (Auth.auth().currentUser?.uid)!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProfilePicture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            ypConfig.showsVideo = false
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
        self.containerSwipeNavigationController?.showEmbeddedView(position: .right)
    }
    
    @IBAction func myTailgatePressed(_ sender: Any) {
        self.containerSwipeNavigationController?.showEmbeddedView(position: .left)
    }
    
}
