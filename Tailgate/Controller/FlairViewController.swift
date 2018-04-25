//
//  FlairViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 4/21/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit
import YPImagePicker

class FlairViewController: UIViewController {
    
    @IBOutlet weak var flairExampleImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // round picture corners
        self.flairExampleImageView.layer.cornerRadius = 8.0
        self.flairExampleImageView.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func addFlairButton(_ sender: Any) {
        getCurrentUser { (currentUser) in
            if let schoolName = currentUser.schoolName {
                var ypConfig = YPImagePickerConfiguration()
                ypConfig.onlySquareImagesFromLibrary = true
                ypConfig.showsFilters = true
                ypConfig.showsVideoInLibrary = false
                ypConfig.screens = [.library]
                
                let picker = YPImagePicker(configuration: ypConfig)
                
                picker.didSelectImage = { image in
                    
                    let imageName = currentUser.uid + "-" + getTimestampString()
                    let uploadPath = "images/" + schoolName.replacingOccurrences(of: " ", with: "") + "/submittedFlair/mySchool/" + imageName + ".jpg"
                    
                    uploadImageToStorage(image: image, uploadPath: uploadPath, completion: { (downloadUrl) in
                        // nothing for now!
                    })
                    
                    DispatchQueue.main.async {
                        picker.dismiss(animated: true, completion: nil)
                    }
                }
                
                DispatchQueue.main.async {
                    self.present(picker, animated: true, completion: nil)
                }
            } else {
                let noSchoolAlert = createAlert(title: "You Didn't Choose a School!", message: "You must pick your school in the Settings before you can submit flair.")
                DispatchQueue.main.async {
                    self.present(noSchoolAlert, animated: true, completion: nil)
                }
            }
        }
    }
}
