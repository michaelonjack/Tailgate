//
//  SettingsSchoolViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 4/15/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

class SettingsSchoolViewController: UIViewController {

    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var schoolsCollectionView: UICollectionView!
    
    var schools:[School] = []
    var presentingController: UIViewController?
    var schoolName:String?
    var selectedSchool:School?
    
    fileprivate let reuseIdentifier = "SchoolCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    fileprivate let itemsPerRow: CGFloat = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()

        schoolsCollectionView.delegate = self
        schoolsCollectionView.dataSource = self
        
        schoolNameLabel.text = schoolName
        
        getSchools { (schools) in
            self.schools = schools
            self.schoolsCollectionView.reloadData()
        }
        
        // Change font and color of nav header
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22.0), NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func updateButtonPressed(_ sender: Any) {
        updateValueForCurrentUser(key: "school", value: self.schoolNameLabel.text ?? "")
        
        // Update the Settings table
        if let presentingController = self.presentingController as? SettingsViewController {
            presentingController.loadData()
            self.navigationController?.popViewController(animated: true)
        }
    }
}





extension SettingsSchoolViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! HighlightableImageCollectionViewCell
        cell.isSelected = true
        
        self.selectedSchool = self.schools[indexPath.row]
        self.schoolNameLabel.text = self.schools[indexPath.row].name
        return true
    }
}




extension SettingsSchoolViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.schools.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! HighlightableImageCollectionViewCell
        
        cell.borderColor = UIColor(red:0.98, green:0.50, blue:0.45, alpha:1.0)
        
        let currentSchool = self.schools[indexPath.row]
        cell.imageView.sd_setImage(with: URL(string: currentSchool.logoUrl!), completed: nil)
        
        return cell
    }
}



extension SettingsSchoolViewController : UICollectionViewDelegateFlowLayout {
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
