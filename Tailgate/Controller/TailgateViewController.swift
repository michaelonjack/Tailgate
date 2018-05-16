//
//  TailgateViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/12/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SDWebImage
import YPImagePicker
import AudioToolbox
import NotificationBannerSwift

class TailgateViewController: UIViewController {

    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var invitesButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var privateLabel: UILabel!
    @IBOutlet weak var invitesRightConstraint: NSLayoutConstraint!
    
    fileprivate let reuseIdentifier = "TailgateCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    fileprivate let itemsPerRow: CGFloat = 3
    
    // LocationManager instance used to update the current user's location
    let locationManager = CLLocationManager()
    
    var locationBanner:StatusBarNotificationBanner = StatusBarNotificationBanner(attributedTitle: NSAttributedString(string: "Updating location..."), style: .warning)
    var tailgate: Tailgate!
    var hasFullAccess: Bool! = true
    var imageUrls: [String] = []
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
        imageCollectionView.backgroundView = EmptyBackgroundView(scrollView: self.imageCollectionView, image: UIImage(named: "Football")!, title: "Tailgate Photos", message: "Photos uploaded by you or your invites will show here")
        
        nameLabel.text = tailgate.name
        schoolLabel.text = tailgate.school.name
        privateLabel.text = "Public"
        
        let ownerId = tailgate.ownerId
        getUserById(userId: ownerId!, completion: { (user) in
            DispatchQueue.main.async {
                self.ownerLabel.text = user.name
            }
        })
        
        getTailgateImageUrls(tailgate: self.tailgate!) { imgUrls in
            self.imageUrls = imgUrls
            self.imageCollectionView.reloadData()
        }
        
        if hasFullAccess == false {
            self.backButton.isHidden = true
            self.trashButton.isHidden = true
            self.locationButton.isHidden = true
            self.invitesRightConstraint.isActive = false
            self.invitesButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        } else {
            self.exitButton.isHidden = true
        }
        
        loadProfilePicture()
    }
    
    /////////////////////////////////////////////////////
    //
    // loadProfilePicture
    //
    //  Pulls the user's profile picture from the database if it exists
    //
    func loadProfilePicture() {
        let tailgateOwnerId = self.tailgate.ownerId
        let currentUserReference = Database.database().reference(withPath: "users/" + tailgateOwnerId!)
        
        // Load the stored image
        currentUserReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let storedData = snapshot.value as? NSDictionary
            
            // Load user's profile picture from Firebase Storage if it exists (exists if the user has a profPic URL in the database)
            if snapshot.hasChild("profilePictureUrl") {
                let picUrlStr = storedData?["profilePictureUrl"] as? String ?? ""
                if picUrlStr != "" {
                    let picUrl = URL(string: picUrlStr)
                    self.profilePictureImageView.sd_setImage(with: picUrl, placeholderImage: UIImage(named: "Avatar"))
                    
                    // round picture corners
                    self.profilePictureImageView.layer.cornerRadius = 8.0
                    self.profilePictureImageView.clipsToBounds = true
                }
            } else {
                print("Error -- Loading Profile Picture")
            }
        })
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.containerSwipeNavigationController?.showEmbeddedView(position: .center)
    }
    
    @IBAction func trashButtonPressed(_ sender: UIButton) {
        
        let tailgateReference = Database.database().reference(withPath: "tailgates/" + tailgate.id)
        let userTailgateReference = Database.database().reference(withPath: "users/" + (Auth.auth().currentUser?.uid)! + "/tailgate")
        
        // Remove the invite from each invited user's invite list
        for invite in tailgate.invites {
            let userInviteReference = Database.database().reference(withPath: "users/" + invite.uid + "/invites/" + tailgate.id)
            userInviteReference.removeValue()
        }
        
        // TODO: Do we want to remove the data in the tailgate table or let it persist as a viewable archive?
        // For now we say remove it
        tailgateReference.removeValue()
        
        // Remove the tailgate data from the user reference
        userTailgateReference.removeValue()
        
        // Remove the tailgate annotation from the map view if it exists
        let mapVC:MapViewController =  self.containerSwipeNavigationController?.leftViewController as! MapViewController
        mapVC.removeAnnotation(tailgate: self.tailgate)
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newTailgateViewController = mainStoryboard.instantiateViewController(withIdentifier: "NewTailgateNavigationController") as! UINavigationController
        
        self.containerSwipeNavigationController?.showEmbeddedView(position: .center)
        self.containerSwipeNavigationController?.rightViewController = newTailgateViewController
    }
    
    @IBAction func exitButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        // Only allow the current user to add images to the tailgate if they have
        // full access for they've been invited
        if hasFullAccess == true || self.tailgate.isUserInvited(userId: getCurrentUserId()) {
            var ypConfig = YPImagePickerConfiguration()
            ypConfig.onlySquareImagesFromCamera = true
            ypConfig.onlySquareImagesFromLibrary = true
            ypConfig.showsFilters = true
            ypConfig.showsVideoInLibrary = false
            ypConfig.usesFrontCamera = false
            ypConfig.shouldSaveNewPicturesToAlbum = false
        
            let picker = YPImagePicker(configuration: ypConfig)
            picker.didSelectImage = { image in
                
                let timestamp:String = getTimestampString()
                let tailgateOwnerId:String = self.tailgate.ownerId
                let tailgateId:String = self.tailgate.id
                let uploadPath:String = "images/users/" + tailgateOwnerId + "/tailgate/" + tailgateId + "/" +  timestamp
                uploadImageToStorage(image: image, uploadPath: uploadPath, completion: { (downloadUrl) in
                    if let imageUrl = downloadUrl {
                        
                        let imageUrlsReference = Database.database().reference(withPath: "tailgates/" + self.tailgate.id + "/imageUrls")
                        imageUrlsReference.updateChildValues([timestamp: downloadUrl!])
                        
                        self.imageUrls.append(imageUrl)
                        self.imageCollectionView.reloadData()
                    }
                })
                
                picker.dismiss(animated: true, completion: nil)
            }
            present(picker, animated: true, completion: nil)
        }
        
        else {
            let errorAlert = createAlert(title: "Upload Not Permitted", message: "Only invited users can upload pictures to a tailgate.")
            self.present(errorAlert, animated: true, completion:nil)
        }
    }
    
    
    
    @IBAction func locationButtonPressed(_ sender: Any) {
        if locationServiceIsEnabled() {
            // Create the banner showing the user their location is being retrieved
            self.locationBanner.show()
                
            self.locationManager.delegate = self
            // Request location authorization for the app
            self.locationManager.requestWhenInUseAuthorization()
            // Request a location update
            self.locationManager.requestLocation()
        }
            
        else {
            let locationNotEnabledAlert = UIAlertController(title: "Location Services Disabled", message: "Location Services must be enabled to check in with Thread.",preferredStyle: .alert)
            
            // Close action closes the pop-up alert
            let closeAction = UIAlertAction(title: "Close", style:.default)
            
            locationNotEnabledAlert.addAction(closeAction)
            
            self.present(locationNotEnabledAlert, animated: true, completion: nil)
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier! == "TailgateToInvite" {
            let invitesVC: InvitesViewController = segue.destination as! InvitesViewController
            invitesVC.tailgate = self.tailgate
        }
        
        else if segue.identifier! == "TailgateToSupplies" {
            let suppliesVC: SuppliesViewController = segue.destination as! SuppliesViewController
            suppliesVC.tailgate = self.tailgate
        }
    }
    
}



extension TailgateViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                                 shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // If the tapped image is already the selected, set the largePhotoIndexPath property to nil, otherwise set it to the index path the user just tapped
        selectedImageIndex = selectedImageIndex == indexPath ? nil : indexPath
        return false
    }
}






extension TailgateViewController : CLLocationManagerDelegate {
    
    /////////////////////////////////////////////////////
    //
    //  locationServiceIsEnabled
    //
    //  Returns true if the user has location services enabled, false otherwise
    //
    func locationServiceIsEnabled() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            }
        } else {
            return false
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = manager.location
        self.tailgate.location = location
        
        let mapVC:MapViewController =  self.containerSwipeNavigationController?.leftViewController as! MapViewController
       
        // Remove any existing annotations for this tailgate if they exist
        mapVC.removeAnnotation(tailgate: self.tailgate)
        // Add the tailgate annotation to the map
        if self.tailgate.isPublic == true {
            mapVC.mapView.addAnnotation( TailgateAnnotation(tailgate: self.tailgate) )
        }
        
        // Update tailgate coordinates in database
        let longitude = manager.location?.coordinate.longitude
        let latitude = manager.location?.coordinate.latitude
        Database.database().reference(withPath: "tailgates/" + tailgate.id).updateChildValues(["longitude":longitude!, "latitude":latitude!])
        
        self.locationBanner.dismiss()
        
        let successBanner = NotificationBanner(attributedTitle: NSAttributedString(string: "Location Updated"), attributedSubtitle: NSAttributedString(string: "Your tailgate will now show on the map!"), style: .success)
        successBanner.show()
        
        // Vibrate phone
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
}







extension TailgateViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        if self.imageUrls.count > 0 {
            collectionView.backgroundView?.isHidden = true
        } else {
            collectionView.backgroundView?.isHidden = false
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





extension TailgateViewController : UICollectionViewDelegateFlowLayout {
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
