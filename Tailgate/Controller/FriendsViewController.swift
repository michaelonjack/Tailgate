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
    
    var readyToFilter: Bool = false
    var allUsers:[User] = [] {
        didSet {
            if readyToFilter == true {
                self.notMyFriends = getDifference(array1: allUsers, array2: myFriends)
            } else {
                readyToFilter = true
            }
        }
    }
    var myFriends:[User] = [] {
        didSet {
            if readyToFilter == true {
                self.notMyFriends = getDifference(array1: allUsers, array2: myFriends)
            } else {
                readyToFilter = true
            }
        }
    }
    var notMyFriends:[User] = [] {
        didSet {
            self.searchResults = notMyFriends
            self.friendsCollectionView.reloadData()
        }
    }
    var searchResults:[User] = []
    var searchText:String = "" {
        didSet {
            if searchText == "" {
                searchResults = notMyFriends
            } else {
                searchResults = []
                for user in notMyFriends {
                    if user.name.lowercased().range(of: self.searchText.lowercased()) != nil {
                        searchResults.append(user)
                    }
                }
            }
            
            if let usersCollectionCell = self.friendsCollectionView.cellForItem(at: IndexPath(item: 1, section: 0)) as? UsersCollectionViewCell {
                usersCollectionCell.users = self.searchResults
                usersCollectionCell.userTableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        searchTextField.delegate = self
        
        friendsCollectionView.delegate = self
        friendsCollectionView.dataSource = self
        
        self.myFriendsButton.setTitleColor(.white, for: .normal)
        self.findFriendsButton.setTitleColor(.lightGray, for: .normal)
        self.searchTextField.attributedPlaceholder = NSAttributedString(string: searchTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor : UIColor.lightGray])
        
        getUsers( completion: { (users) in
            self.allUsers = users
        })
        
        getFriends( completion:  { (friends) in
            self.myFriends = friends
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
    
    @IBAction func searchFieldEditingDidBegin(_ sender: Any) {
        self.myFriendsButton.setTitleColor(.lightGray, for: .normal)
        self.findFriendsButton.setTitleColor(.white, for: .normal)
        self.friendsCollectionView.scrollToItem(at: IndexPath(row: 1, section: 0), at: .left, animated: true)
    }
    
    func getDifference(array1:[User], array2:[User]) -> [User] {
        let set1 = Set<User>(array1)
        let set2 = Set<User>(array2)
        
        // Get all users in set1 that are not in set2
        let diff = set1.subtracting(set2)
        
        return Array(diff)
    }
}



extension FriendsViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedValue = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        
        self.searchText = updatedValue
        return true
    }
    
}



extension FriendsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Highlight the header of the currently in view collection cell
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
        
        
        cell.userTableView.delegate = cell
        cell.userTableView.dataSource = cell
        cell.userTableView.allowsSelection = false
        cell.userTableView.rowHeight = UITableViewAutomaticDimension
        cell.userTableView.estimatedRowHeight = 90
        cell.userTableView.layer.cornerRadius = 10
        if indexPath.row == 0 {
            cell.users = self.myFriends
            cell.isMyFriendsCollectionCell = true
        } else {
            cell.users = self.searchResults
            cell.isMyFriendsCollectionCell = false
        }
        cell.userTableView.reloadData()
        
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
