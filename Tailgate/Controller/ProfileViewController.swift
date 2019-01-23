//
//  ProfileViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/10/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import UIKit
import FirebaseDatabase
import YPImagePicker
import SDWebImage

class ProfileViewController: UIViewController {

    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var detailsView: ProfileDetailsView!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var loadingView: UIView!
    @IBOutlet weak var friendsButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var reloadButton: UIButton!
    
    let refreshControl = UIRefreshControl()
    let currentUserRef = Database.database().reference(withPath: "users/" + getCurrentUserId())
    
    var feedItems:[Tailgate] = []
    var schools:[School] = []
    var showExploreViewAnimator: UIViewPropertyAnimator!
    var panDirection: ScrollDirection = .undefined
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.clipsToBounds = true
        
        // Get all public tailgates and tailgates the current user is invited to
        getTailgatesToDisplay { (tailgates) in
            self.feedItems = tailgates
            self.detailsView.feedCollectionView.reloadData()
        }
        
        getSchools { (schools) in
            self.schools = schools
            self.detailsView.exploreCollectionView.reloadData()
        }
        
        loadProfilePicture()
        initDetailsView()
        initButtonsView()
        initAnimator()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        detectFirstLaunch()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func initDetailsView() {
        detailsView.feedCollectionView.delegate = self
        detailsView.feedCollectionView.dataSource = self
        
        detailsView.exploreCollectionView.delegate = self
        detailsView.exploreCollectionView.dataSource = self
        
        detailsView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(detailsViewPanned(gesture:))))
        
    }
    
    
    func initButtonsView() {
        buttonsView.layer.cornerRadius = view.frame.height * 0.06 / 2
        buttonsView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        buttonsView.clipsToBounds = true
        
        guard let friendsImage = UIImage(named: "Friends") else { return }
        guard let settingsImage = UIImage(named: "Settings") else { return }
        guard let reloadImage = UIImage(named: "Reload") else { return }
        
        friendsButton.setImage(friendsImage.withRenderingMode(.alwaysTemplate), for: .normal)
        settingButton.setImage(settingsImage.withRenderingMode(.alwaysTemplate), for: .normal)
        reloadButton.setImage(reloadImage.withRenderingMode(.alwaysTemplate), for: .normal)
        
        friendsButton.tintColor = .gray
        settingButton.tintColor = .gray
        reloadButton.tintColor = .gray
    }
    
    
    func initAnimator() {
        showExploreViewAnimator = UIViewPropertyAnimator(duration: 1, curve: .easeOut, animations: { [weak self] in
            guard let _self = self else { return }
            
            _self.detailsView.exploreView.alpha =  1
            _self.profilePictureButton.transform = _self.profilePictureButton.transform.scaledBy(x: 0.953, y: 0.953)
        })
        
        showExploreViewAnimator.pausesOnCompletion = true
    }
    
    
    @objc func detailsViewPanned(gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            containerSwipeNavigationController?.onPanGestureTriggered(sender: gesture)
            return
        case .ended:
            panDirection = .undefined
            containerSwipeNavigationController?.onPanGestureTriggered(sender: gesture)
            return
        case .changed:
            let gestureTranslation = gesture.translation(in: detailsView)
            
            if panDirection == .undefined {
                if abs(gestureTranslation.x) > abs(gestureTranslation.y) {
                    panDirection = .horizontal
                } else {
                    panDirection = .vertical
                }
            }
            
            // The detail view should only be panned in the vertical direction so if we detect a significant change in the horizontal direction, delegate to the swipe controller's gesture handler
            if panDirection == .horizontal {
                containerSwipeNavigationController?.onPanGestureTriggered(sender: gesture)
                return
            }
            
            let viewCurrentMinY = detailsView.frame.minY
            let lowestAllowedY = view.frame.height / 3.5
            let highestAllowedY = view.frame.height / 2.0
            
            if (viewCurrentMinY + gestureTranslation.y < highestAllowedY && gestureTranslation.y > 0)
                || (viewCurrentMinY + gestureTranslation.y > lowestAllowedY && gestureTranslation.y < 0) {
                showExploreViewAnimator.fractionComplete = (highestAllowedY - viewCurrentMinY) / (highestAllowedY - lowestAllowedY)
                
                detailsView.transform = detailsView.transform.translatedBy(x: 0, y: gestureTranslation.y)
            } else if gestureTranslation.y > 0 {
                // Completely hide the Explore View once we've reached the bottom
                showExploreViewAnimator.fractionComplete = 0
            }
            
        default:
            return
        }
        
        gesture.setTranslation(CGPoint(x: 0, y: 0), in: detailsView)
    }
    
    
    /////////////////////////////////////////////////////
    //
    // loadProfilePicture
    //
    //  Pulls the user's profile picture from the database if it exists
    //
    func loadProfilePicture() {
        
        profilePictureButton.transform = profilePictureButton.transform.scaledBy(x: 1.05, y: 1.05)
        
        // Load the stored image
        currentUserRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let storedData = snapshot.value as? NSDictionary
            
            // Load user's profile picture from Firebase Storage if it exists (exists if the user has a profPic URL in the database)
            if snapshot.hasChild("profilePictureUrl") {
                let picUrlStr = storedData?["profilePictureUrl"] as? String ?? ""
                if picUrlStr != "" {
                    let picUrl = URL(string: picUrlStr)
                    self.profilePictureButton.sd_setImage(with: picUrl, for: .normal, placeholderImage: UIImage(named: "Avatar"))
                }
            } else {
                print("Error -- Loading Profile Picture")
            }
        })
    }
    
    
    func detectFirstLaunch() {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            //print("Not first launch.")
        } else {
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "ProfileToTutorial", sender: nil)
            }
        }
    }
    
    
    @IBAction func profilePicturePressed(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            var ypConfig = YPImagePickerConfiguration()
            ypConfig.onlySquareImagesFromCamera = true
            ypConfig.library.onlySquare = true
            ypConfig.showsFilters = true
            ypConfig.library.mediaType = .photo
            ypConfig.usesFrontCamera = false
            ypConfig.shouldSaveNewPicturesToAlbum = false
            
            let picker = YPImagePicker(configuration: ypConfig)
            picker.didFinishPicking { items, _ in
                
                if let photo = items.singlePhoto {
                    // Sets the user's profile picture to be this image
                    self.profilePictureButton.setImage(photo.image, for: .normal)
                    self.profilePictureButton.imageView?.contentMode = .scaleAspectFill
                    
                    let uploadPath = "images/users/" + getCurrentUserId() + "/ProfilePicture"
                    uploadImageToStorage(image: photo.image, uploadPath: uploadPath, completion: { (downloadUrl) in
                        updateValueForCurrentUser(key: "profilePictureUrl", value: downloadUrl!)
                    })
                }
                
                picker.dismiss(animated: true, completion: nil)
            }
            present(picker, animated: true, completion: nil)
        } else {
            print("Error -- Camera")
        }
    }
    
    
    @IBAction func reloadButtonPressed(_ sender: Any) {
        // Animate the button spin
        UIView.animate(withDuration: 0.2, animations: {
            self.reloadButton.transform = self.reloadButton.transform.rotated(by: CGFloat.pi)
        }) { (_) in
            UIView.animate(withDuration: 0.2, animations: {
                self.reloadButton.transform = self.reloadButton.transform.rotated(by: CGFloat.pi)
            })
        }
        
        // Reload the basic details view
        detailsView.reloadBasicDetailsView()
        
        // Reload the feed collection view
        getTailgatesToDisplay { (tailgates) in
            self.feedItems = tailgates
            self.detailsView.feedCollectionView.reloadData()
        }
    }
}



extension ProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == detailsView.exploreCollectionView {
            guard let mapViewController = containerSwipeNavigationController?.leftViewController as? MapViewController else { return }
            
            let school = self.schools[indexPath.row]
            
            if let latitude = school.latitude, let longitude = school.longitude {
                let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                mapViewController.centerMapOnLocation(location: location)
                
                containerSwipeNavigationController?.showEmbeddedView(position: .left)
            }
        } else {
            let selectedFeedItem = self.feedItems[indexPath.row]
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let tailgateViewController = mainStoryboard.instantiateViewController(withIdentifier: "TailgateViewController") as! TailgateViewController
            tailgateViewController.tailgate = selectedFeedItem
            tailgateViewController.hasFullAccess = false
            self.present(tailgateViewController, animated: true, completion: nil)
        }
    }
}



extension ProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == detailsView.exploreCollectionView {
            return schools.count
        } else {
            return feedItems.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == detailsView.exploreCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exploreCell", for: indexPath)
            
            guard let imageCell = cell as? ExploreCollectionViewCell else { return cell }
            imageCell.imageView.contentMode = .scaleAspectFill
            imageCell.layer.cornerRadius = (collectionView.frame.height * 0.667 - 4) / 4
            imageCell.backgroundColor = .white
            imageCell.clipsToBounds = true
            
            let school = schools[indexPath.row]
            
            if let schoolLogoUrlStr = school.logoUrl {
                let schoolLogoUrl = URL(string: schoolLogoUrlStr)
                imageCell.imageView.sd_setImage(with: schoolLogoUrl, completed: nil)
            }
            
            return imageCell
        }
        
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "feedCell", for: indexPath)
            
            guard let imageCell = cell as? FeedCollectionViewCell else { return cell }
            imageCell.imageView.contentMode = .scaleAspectFill
            imageCell.layer.cornerRadius = (collectionView.frame.height - 4) / 4
            imageCell.backgroundColor = .white
            imageCell.clipsToBounds = true
            
            let feedItem = feedItems[indexPath.row]
            
            getUserById(userId: feedItem.ownerId) { (user) in
                if let profilePictureUrlStr = user.profilePictureUrl {
                    let profilePictureUrl = URL(string: profilePictureUrlStr)
                    imageCell.imageView.sd_setImage(with: profilePictureUrl, completed: nil)
                }
                
                imageCell.detailsLabel.text = user.name + "\n" + feedItem.startTimeStr
            }
            
            return imageCell
        }
    }
    
    
}



extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == detailsView.exploreCollectionView {
            return CGSize(width: collectionView.frame.height / 1.5, height: collectionView.frame.height / 1.5 - 4)
        } else {
            return CGSize(width: collectionView.frame.height, height: collectionView.frame.height - 4)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
    }
}
