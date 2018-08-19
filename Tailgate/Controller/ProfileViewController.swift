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
import VegaScrollFlowLayout

class ProfileViewController: UIViewController {

    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var invitesCollectionView: UICollectionView!
    
    @IBOutlet weak var settingsButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var settingsButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var profilePictureTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var friendsButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var friendsButtonTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var loadingView: UIView!
    
    let refreshControl = UIRefreshControl()
    let currentUserRef = Database.database().reference(withPath: "users/" + getCurrentUserId())
    
    var feedItems:[Tailgate] = []
    var state = CollectionState.loading {
        didSet {
            setCollectionBackgroundView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        state = .loading
        
        self.invitesCollectionView.delegate = self
        self.invitesCollectionView.dataSource = self
        
        let vegaLayout = VegaScrollFlowLayout()
        self.invitesCollectionView.collectionViewLayout = vegaLayout
        vegaLayout.minimumLineSpacing = 15
        vegaLayout.itemSize = CGSize(width: self.invitesCollectionView.frame.width - 16, height: 90)
        vegaLayout.sectionInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        vegaLayout.springHardness = 60
        self.addRefreshControl()
        
        // Get all public tailgates and tailgates the current user is invited to
        getTailgatesToDisplay { (tailgates) in
            self.feedItems = tailgates
            
            if self.feedItems.count > 0 {
                self.state = .populated
            } else {
                self.state = .empty
            }
            
            self.invitesCollectionView.reloadData()
        }
       
        loadProfilePicture()
        
        // Update constraints
        self.settingsButtonLeadingConstraint.updateHorizontalConstantForViewWidth(view: self.view)
        self.friendsButtonTrailingConstraint.updateHorizontalConstantForViewWidth(view: self.view)
        self.settingsButtonTopConstraint.updateVerticalConstantForViewHeight(view: self.view)
        self.profilePictureTopConstraint.updateVerticalConstantForViewHeight(view: self.view)
        self.friendsButtonTopConstraint.updateVerticalConstantForViewHeight(view: self.view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        detectFirstLaunch()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func setCollectionBackgroundView() {
        
        switch state {
        case .loading:
            invitesCollectionView.backgroundView = loadingView
            invitesCollectionView.backgroundView?.isHidden = false
        case .empty:
            invitesCollectionView.backgroundView = emptyView
            invitesCollectionView.backgroundView?.isHidden = false
        default:
            invitesCollectionView.backgroundView?.isHidden = true
            invitesCollectionView.backgroundView = nil
        }
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
    
    func addRefreshControl() {
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            self.invitesCollectionView.refreshControl = self.refreshControl
        } else {
            self.invitesCollectionView.addSubview(self.refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(refreshFeedCollectionView(_:)), for: .valueChanged)
    }
    
    func detectFirstLaunch() {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            print("Not first launch.")
        } else {
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "ProfileToTutorial", sender: nil)
            }
        }
    }
    
    @objc private func refreshFeedCollectionView(_ sender: Any) {
        // Get all public tailgates and tailgates the current user is invited to
        getTailgatesToDisplay { (tailgates) in
            self.feedItems = tailgates
            
            DispatchQueue.main.async {
                self.invitesCollectionView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
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
       
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCell", for: indexPath) as! FeedCollectionViewCell
        
        let currentFeedItem = self.feedItems[indexPath.row]
       
        // Update constraints IF they have not been updated yet
        if cell.imageViewTrailingConstraint.constant == 14 {
            cell.imageViewTrailingConstraint.updateHorizontalConstantForViewWidth(view: self.view)
        }
        if cell.imageViewLeadingConstraint.constant == 12 {
            cell.imageViewLeadingConstraint.updateHorizontalConstantForViewWidth(view: self.view)
        }
        if cell.detailLabelTrailingConstraint.constant == 7.5 {
            cell.detailLabelTrailingConstraint.updateHorizontalConstantForViewWidth(view: self.view)
        }
        if cell.indicatorTrailingConstraint.constant == 5 {
            cell.indicatorTrailingConstraint.updateHorizontalConstantForViewWidth(view: self.view)
        }
        
        cell.titleLabel.text = currentFeedItem.name
        
        cell.imageView.layer.cornerRadius = 0.5 * cell.imageView.layer.bounds.width
        cell.imageView.clipsToBounds = true
        cell.activityTypeIndicator.layer.cornerRadius = 0.5 * cell.activityTypeIndicator.layer.bounds.width
        
        if currentFeedItem.isPublic {
            cell.activityTypeIndicator.backgroundColor = .salmon
        } else {
            cell.activityTypeIndicator.backgroundColor = .cantaloupe
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





