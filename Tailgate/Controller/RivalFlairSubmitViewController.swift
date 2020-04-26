//
//  RivalFlairSubmitViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 5/16/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit
import YPImagePicker
import NotificationBannerSwift

class RivalFlairSubmitViewController: UIViewController {

    @IBOutlet weak var schoolTable: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var schools: [School] = []
    var searchResults: [School] = []
    var selectedSchool: School!
    var searchText:String = "" {
        didSet {
            if searchText == "" {
                searchResults = schools
            } else {
                searchResults = []
                for school in schools {
                    if school.name.lowercased().range(of: self.searchText.lowercased()) != nil {
                        searchResults.append(school)
                    }
                }
            }
            
            schoolTable.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        schoolTable.delegate = self
        schoolTable.dataSource = self
        searchTextField.delegate = self
        
        
        getSchools(completion: { (schools) in
            self.schools = schools
            self.searchResults = schools
            self.schoolTable.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func submitRivalFlairButtonPressed(_ sender: Any) {
        if let _ = schoolTable.indexPathForSelectedRow {
            var ypConfig = YPImagePickerConfiguration()
            ypConfig.library.onlySquare = true
            ypConfig.showsPhotoFilters = true
            ypConfig.library.mediaType = .photo
            ypConfig.screens = [.library]
            
            let picker = YPImagePicker(configuration: ypConfig)
            
            picker.didFinishPicking { items, _ in
                
                if let photo = items.singlePhoto {
                    let imageName = getCurrentUserId() + "-" + getTimestampString()
                    let uploadPath = "images/" + self.selectedSchool.name.replacingOccurrences(of: " ", with: "") + "/submittedFlair/rival/" + imageName + ".jpg"
                    
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
        }
            
        else {
            let errorAlert = UIAlertController(
                title: "",
                message: "You must select a rival to submit flair",
                preferredStyle: .alert
            )
            
            let closeAction = UIAlertAction(title: "Close", style: .default)
            errorAlert.addAction(closeAction)
            self.present(errorAlert, animated: true, completion:nil)
        }
    }
}



extension RivalFlairSubmitViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedValue = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        
        self.searchText = updatedValue
        return true
    }
    
}



extension RivalFlairSubmitViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedSchool = searchResults[indexPath.row]
    }
    
}



extension RivalFlairSubmitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SchoolTableCell", for: indexPath) as! SchoolTableViewCell
        
        let currSchool = self.searchResults[indexPath.row]
        
        // Reset the recycled cell's label
        cell.schoolNameLabel.text = ""
        
        cell.schoolNameLabel.text = currSchool.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
