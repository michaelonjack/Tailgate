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

    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var viewOptionsSelectionIndicator: UIView!
    @IBOutlet weak var selectionIndicatorLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewOptionsCollectionView: UICollectionView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var invitesButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var viewDetailsButton: UIButton!
    @IBOutlet weak var invitesRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var profilePictureTopConstraint: NSLayoutConstraint!
    
    // LocationManager instance used to update the current user's location
    let locationManager = CLLocationManager()
    
    var locationBanner:StatusBarNotificationBanner = StatusBarNotificationBanner(attributedTitle: NSAttributedString(string: "Updating location..."), style: .warning)
    var tailgate: Tailgate!
    var hasFullAccess: Bool! = true
    var tailgatePageViewController: TailgatePageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewOptionsCollectionView.delegate = self
        viewOptionsCollectionView.dataSource = self
        
        if hasFullAccess == false {
            self.backButton.isHidden = true
            self.trashButton.isHidden = true
            self.locationButton.isHidden = true
            self.invitesRightConstraint.isActive = false
            self.invitesButton.centerXAnchor.constraint(equalTo: self.buttonsView.centerXAnchor).isActive = true
        } else {
            self.exitButton.isHidden = true
            self.optionsButton.isHidden = true
        }
        
        // Add border to View Details button
        viewDetailsButton.layer.borderWidth = 1.0
        viewDetailsButton.layer.borderColor = UIColor.lightGray.cgColor
        viewDetailsButton.layer.cornerRadius = 5.0
        
        self.profilePictureTopConstraint.updateVerticalConstantForViewHeight(view: self.view)
        
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
        
        let deleteConfirmationAlert = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this tailgate?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            // Remove the invite from each invited user's invite list
            for invite in self.tailgate.invites {
                let userInviteReference = Database.database().reference(withPath: "users/" + invite.uid + "/invites/" + self.tailgate.id)
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
        deleteConfirmationAlert.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // canceled
        }
        deleteConfirmationAlert.addAction(cancelAction)
        
        self.present(deleteConfirmationAlert, animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func exitButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        // Only allow the current user to add images to the tailgate if they have full access for they've been invited
        if hasFullAccess == true || self.tailgate.isUserInvited(userId: getCurrentUserId()) {
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
                    let timestamp:String = getTimestampString()
                    let tailgateOwnerId:String = self.tailgate.ownerId
                    let tailgateId:String = self.tailgate.id
                    let uploadPath:String = "images/users/" + tailgateOwnerId + "/tailgate/" + tailgateId + "/" +  timestamp
                    uploadImageToStorage(image: photo.image, uploadPath: uploadPath, completion: { (downloadUrl) in
                        if let _ = downloadUrl {
                            
                            let imageUrlsReference = Database.database().reference(withPath: "tailgates/" + self.tailgate.id + "/imageUrls")
                            imageUrlsReference.updateChildValues([timestamp: downloadUrl!])
                        }
                    })
                }
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
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            // Request location authorization for the app
            self.locationManager.requestWhenInUseAuthorization()
            // Request a location update
            self.locationManager.requestLocation()
        }
            
        else {
            let locationNotEnabledAlert = UIAlertController(title: "Location Services Disabled", message: "Location Services must be enabled to check in your tailgate.",preferredStyle: .alert)
            
            // Close action closes the pop-up alert
            let closeAction = UIAlertAction(title: "Close", style:.default)
            
            locationNotEnabledAlert.addAction(closeAction)
            
            self.present(locationNotEnabledAlert, animated: true, completion: nil)
        }
    }
    
    
    
    @IBAction func optionsButtonPressed(_ sender: Any) {
        
        let optionsController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let popoverController = optionsController.popoverPresentationController {
            popoverController.sourceView = (sender as! UIView).superview
            popoverController.sourceRect = (sender as! UIView).frame
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        optionsController.addAction(cancelAction)
        
        // User has requested to block the tailgate owner
        let blockUserAction = UIAlertAction(title: "Block User", style: .destructive) { (action) in
            let blockConfirmationAlert = UIAlertController(title: "Confirm", message: "Are you sure you want to block this user?", preferredStyle: .alert)
            let blockAction = UIAlertAction(title: "Block", style: .destructive) { (action) in
                blockUser(userId: self.tailgate.ownerId)
            }
            blockConfirmationAlert.addAction(blockAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                // canceled
            }
            blockConfirmationAlert.addAction(cancelAction)
            
            self.present(blockConfirmationAlert, animated: true, completion: nil)
        }
        optionsController.addAction(blockUserAction)
        
        // User has requested to report content in a tailgate
        let reportContentAction = UIAlertAction(title: "Report Content", style: .destructive) { (action) in
            self.performSegue(withIdentifier: "TailgateToReport", sender: nil)
        }
        optionsController.addAction(reportContentAction)
        
        // User has requested to open the tailgate in Maps
        let openInMapsAction = UIAlertAction(title: "Open in Maps", style: .default) { (action) in
            if let tailgateCoordinate = self.tailgate.location?.coordinate {
                let destination = MKMapItem(placemark: MKPlacemark(coordinate: tailgateCoordinate))
                destination.name = self.tailgate.name
                
                MKMapItem.openMaps(with: [destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
            }
        }
        optionsController.addAction(openInMapsAction)
        
        self.present(optionsController, animated: true, completion: nil)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier! == "TailgateToInvite" {
            guard let invitesController: InvitesViewController = segue.destination as? InvitesViewController else { return }
            invitesController.tailgate = self.tailgate
        }
        
        else if segue.identifier! == "TailgateToSupplies" {
            guard let suppliesController: SuppliesViewController = segue.destination as? SuppliesViewController else { return }
            suppliesController.tailgate = self.tailgate
        }
            
        else if segue.identifier! == "TailgateToReport" {
            guard let reportController: ReportContentViewController = segue.destination as? ReportContentViewController else { return }
            reportController.tailgate = self.tailgate
        }
            
        else if segue.identifier! == "TailgateToDetails" {
            guard let detailsController: TailgateDetailsViewController = segue.destination as? TailgateDetailsViewController else { return }
            detailsController.tailgate = self.tailgate
        }
        
        // We're using an Embed segue to embed the PageController within our container view so this segue will be called automatically when the TailgateViewController loads
        else if let pageController = segue.destination as? TailgatePageViewController {
            pageController.containerController = self
            tailgatePageViewController = pageController
            
            // Find scroll view to set delegate
            for view in pageController.view.subviews {
                if let scrollView = view as? UIScrollView {
                    scrollView.delegate = self
                    break
                }
            }
        }
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
        
        if let location = manager.location {
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





extension TailgateViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let pageController = tailgatePageViewController else { return }
        
        let scrollViewWidth = scrollView.frame.width
        let scrollViewContentOffset = scrollView.contentOffset.x
        let percentScrolled = (scrollViewContentOffset - scrollViewWidth) / scrollViewWidth
        
        // Scrolling to the right
        if percentScrolled > 0 && pageController.currentIndex < 1 {
            DispatchQueue.main.async {
                self.selectionIndicatorLeadingConstraint.constant = (scrollViewWidth / 2) * percentScrolled
            }
        }
        
        // Scrolling to the left
        else if percentScrolled < 0 && pageController.currentIndex > 0 {
            DispatchQueue.main.async {
                self.selectionIndicatorLeadingConstraint.constant = (scrollViewWidth / 2) - ((scrollViewWidth/2) * percentScrolled * -1)
            }
        }
    }
}






extension TailgateViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            if let controllerToShow = self.tailgatePageViewController?.controllers[0] {
                self.tailgatePageViewController?.setViewControllers([controllerToShow], direction: .reverse, animated: true, completion: { (completed) in
                    // Update the page controller's current index
                    self.tailgatePageViewController?.currentIndex = 0
                })
            }
        } else {
            if let controllerToShow = self.tailgatePageViewController?.controllers[1] {
                self.tailgatePageViewController?.setViewControllers([controllerToShow], direction: .forward, animated: true, completion: { (completed) in
                    // Update the page controller's current index
                    self.tailgatePageViewController?.currentIndex = 1
                })
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
}

extension TailgateViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ViewOptionCell", for: indexPath) as! ImageCollectionViewCell
        
        if indexPath.row == 0 {
            cell.imageView.image = UIImage(named: "Grid")
        } else {
            cell.imageView.image = UIImage(named: "Message")
        }
        
        return cell
    }
}

extension TailgateViewController : UICollectionViewDelegateFlowLayout {
    // responsible for telling the layout the size of a given cell
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Subtract 1 from the height and width so it doesn't complain about the cell being the same size as the container
        return CGSize(width: collectionView.bounds.size.width/2 - 1, height: collectionView.bounds.size.height - 1)
    }
    
    //  returns the spacing between the cells, headers, and footers. A constant is used to store the value
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0;
    }
}




