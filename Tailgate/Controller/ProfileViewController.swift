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

class ProfileViewController: UIViewController {

    @IBOutlet weak var profilePictureButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        self.performSegue(withIdentifier: "ProfileToMap", sender: nil)
    }
    

}
