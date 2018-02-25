//
//  FriendsViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 2/21/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController {
    
    @IBOutlet weak var friendsCollectionView: UICollectionView!
    @IBOutlet weak var myFriendsButton: UIButton!
    @IBOutlet weak var findFriendsButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    
    var myFriends:[User] = []
    var allUsers:[User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        friendsCollectionView.delegate = self
        friendsCollectionView.dataSource = self
        
        self.myFriendsButton.setTitleColor(.white, for: .normal)
        self.findFriendsButton.setTitleColor(.lightGray, for: .normal)
        self.searchTextField.attributedPlaceholder = NSAttributedString(string: searchTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor : UIColor.lightGray])
        
        getUsers( completion: { (users) in
            self.allUsers = users
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func exitButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func myFriendsButtonPressed(_ sender: Any) {
        self.findFriendsButton.setTitleColor(.lightGray, for: .normal)
        self.myFriendsButton.setTitleColor(.white, for: .normal)
        self.friendsCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: true)
    }
    
    @IBAction func findFriendsButtonPressed(_ sender: Any) {
        self.myFriendsButton.setTitleColor(.lightGray, for: .normal)
        self.findFriendsButton.setTitleColor(.white, for: .normal)
        self.friendsCollectionView.scrollToItem(at: IndexPath(row: 1, section: 0), at: .left, animated: true)
    }
    
}



extension FriendsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentIndex:Int = Int(self.friendsCollectionView.contentOffset.x / self.friendsCollectionView.frame.size.width)
        
        if currentIndex == 0 {
            self.myFriendsButton.setTitleColor(.white, for: .normal)
            self.findFriendsButton.setTitleColor(.lightGray, for: .normal)
        } else {
            self.myFriendsButton.setTitleColor(.lightGray, for: .normal)
            self.findFriendsButton.setTitleColor(.white, for: .normal)
        }
    }
}



extension FriendsViewController: UICollectionViewDataSource {
    // There’s one search per section, so the number of sections is the count of the searches array
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UsersCell", for: indexPath) as! UsersCollectionViewCell
        
        cell.users = self.allUsers
        cell.userTableView.delegate = cell
        cell.userTableView.dataSource = cell
        cell.userTableView.allowsSelection = false
        cell.userTableView.rowHeight = UITableViewAutomaticDimension
        cell.userTableView.estimatedRowHeight = 90
        cell.userTableView.reloadData()
        cell.userTableView.layer.cornerRadius = 10
        
        return cell
    }
}


extension FriendsViewController : UICollectionViewDelegateFlowLayout {
    // responsible for telling the layout the size of a given cell
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
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
