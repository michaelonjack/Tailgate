//
//  CreateTailgateFlairViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 2/18/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

class CreateTailgateFlairViewController: UIViewController {

    @IBOutlet weak var flairCollectionView: UICollectionView!
    
    var tailgateName: String!
    var tailgateSchool: School!
    var isPublic: Bool!
    var startTime: Date!
    var supplies:[Supply]!
    var selectedFlairUrl:String = ""
    var flairImageUrls: [(url3x:String, url1x:String)] = []
    
    fileprivate let reuseIdentifier = "FlairCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    fileprivate let itemsPerRow: CGFloat = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()

        flairCollectionView.delegate = self
        flairCollectionView.dataSource = self
        
        getFlairImageUrls(school: tailgateSchool) { (imgUrls) in
            self.flairImageUrls = imgUrls
            self.flairCollectionView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func nextPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "FlairToInvites", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let invitesVC: CreateTailgateInvitesViewController = segue.destination as! CreateTailgateInvitesViewController
        
        invitesVC.tailgateName = self.tailgateName
        invitesVC.tailgateSchool = self.tailgateSchool
        invitesVC.isPublic = self.isPublic
        invitesVC.startTime = self.startTime
        invitesVC.supplies = self.supplies
        invitesVC.flairUrl = self.selectedFlairUrl
    }
}





extension CreateTailgateFlairViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! HighlightableImageCollectionViewCell
        cell.isSelected = true
        
        self.selectedFlairUrl = self.flairImageUrls[indexPath.row].url1x
        return true
    }
}




extension CreateTailgateFlairViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.flairImageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // The cell coming back is now a FlickrPhotoCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! HighlightableImageCollectionViewCell
        cell.imageView.sd_setImage(with: URL(string: self.flairImageUrls[indexPath.row].url3x), completed: nil)
        
        return cell
    }
}



extension CreateTailgateFlairViewController : UICollectionViewDelegateFlowLayout {
    // responsible for telling the layout the size of a given cell
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
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

