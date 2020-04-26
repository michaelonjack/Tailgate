//
//  FlairViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 4/21/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit
import YPImagePicker
import NotificationBannerSwift

class FlairViewController: UIViewController {
    
    @IBOutlet weak var flairExampleImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change font and color of nav header
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20.0), NSAttributedString.Key.foregroundColor: UIColor.steel]

        // round picture corners
        self.flairExampleImageView.layer.cornerRadius = 8.0
        self.flairExampleImageView.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    @IBAction func questionButtonPressed(_ sender: Any) {
        let alert = createAlert(title: "What's flair?", message: "Flair are the images that represent your schools' tailgates on the map. Add new flair that other users can select when creating their tailgate.")
        
        self.present(alert, animated: true, completion: nil)
    }
    
    

    @IBAction func addFlairButton(_ sender: Any) {
        getCurrentUser { (currentUser) in
            if let schoolName = currentUser.schoolName {
                var ypConfig = YPImagePickerConfiguration()
                ypConfig.library.onlySquare = true
                ypConfig.showsPhotoFilters = true
                ypConfig.library.mediaType = .photo
                ypConfig.screens = [.library]
                
                let picker = YPImagePicker(configuration: ypConfig)
                
                picker.didFinishPicking { items, _ in
                    
                    if let photo = items.singlePhoto {
                        let imageName = currentUser.uid + "-" + getTimestampString()
                        let uploadPath = "images/" + schoolName.replacingOccurrences(of: " ", with: "") + "/submittedFlair/mySchool/" + imageName + ".jpg"
                        
                        uploadImageToStorage(image: photo.image, uploadPath: uploadPath, completion: { (downloadUrl) in
                            // nothing for now!
                        })
                        
                        DispatchQueue.main.async {
                            picker.dismiss(animated: true, completion: nil)
                            let successBanner = NotificationBanner(attributedTitle: NSAttributedString(string: "Flair Submitted"), attributedSubtitle: NSAttributedString(string: "Check back to see if your flair gets selected!"), style: .success)
                            successBanner.show()
                        }
                    } else {
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
