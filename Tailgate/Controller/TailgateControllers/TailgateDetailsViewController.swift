//
//  TailgateDetailsViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 10/31/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit
import SDWebImage

class TailgateDetailsViewController: UIViewController {

    @IBOutlet weak var organizerContainerView: UIView!
    @IBOutlet weak var organizerTextField: UITextField!
    @IBOutlet weak var nameContainerView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var schoolContainerView: UIView!
    @IBOutlet weak var schoolButton: UIButton!
    @IBOutlet weak var schoolPicker: UIPickerView!
    @IBOutlet weak var schoolPickerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var startTimeContainerView: UIView!
    @IBOutlet weak var startTimeButton: UIButton!
    @IBOutlet weak var startTimeDatePicker: UIDatePicker!
    @IBOutlet weak var startTimeDatePickerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var publicContainerView: UIView!
    @IBOutlet weak var publicButton: UIButton!
    @IBOutlet weak var publicPicker: UIPickerView!
    @IBOutlet weak var publicPickerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    
    var tailgate: Tailgate!
    var schoolPickerValues:[String] = []
    var publicPickerValues:[String] = ["Yes", "No"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        schoolPicker.delegate = self
        schoolPicker.dataSource = self
        publicPicker.delegate = self
        publicPicker.dataSource = self

        addContainerViewBorders()
        initializeFields()
    }
    
    func addContainerViewBorders() {
        let bottomBorder = CALayer()
        let borderWidth = organizerContainerView.frame.width
        let borderHeight = 1.0
        let borderOffset = organizerContainerView.frame.height - CGFloat(borderHeight)
        
        bottomBorder.frame = CGRect(x: 0.0, y: Double(borderOffset), width: Double(borderWidth), height: borderHeight)
        bottomBorder.backgroundColor = UIColor.lightGray.cgColor
        
        let borderThickness:CGFloat = 0.5
        let borderColor = UIColor.lightGray.cgColor
        
        organizerContainerView.layer.addSublayer(CALayer.createBottomBorder(forFrame: organizerContainerView.frame, withThickness: borderThickness, withColor: borderColor))
        nameContainerView.layer.addSublayer(CALayer.createBottomBorder(forFrame: nameContainerView.frame, withThickness: borderThickness, withColor: borderColor))
        schoolContainerView.layer.addSublayer(CALayer.createBottomBorder(forFrame: schoolContainerView.frame, withThickness: borderThickness, withColor: borderColor))
        startTimeContainerView.layer.addSublayer(CALayer.createBottomBorder(forFrame: startTimeContainerView.frame, withThickness: borderThickness, withColor: borderColor))
        publicContainerView.layer.addSublayer(CALayer.createBottomBorder(forFrame: publicContainerView.frame, withThickness: borderThickness, withColor: borderColor))
    }
    
    func initializeFields() {
        organizerTextField.text = tailgate.owner?.name
        nameTextField.text = tailgate.name
        schoolButton.setTitle(tailgate.school.name, for: .normal)
        startTimeButton.setTitle(tailgate.startTimeStr, for: .normal)
        publicButton.setTitle( (tailgate.isPublic ? "Yes" : "No"), for: .normal)
        
        // Disable editing for any user that isn't the owner
        if tailgate.ownerId != getCurrentUserId() {
            updateButton.isHidden = true
            nameTextField.isUserInteractionEnabled = false
            schoolButton.isUserInteractionEnabled = false
            startTimeButton.isUserInteractionEnabled = false
            publicButton.isUserInteractionEnabled = false
        }
        
        updateProfilePicture()
        initializePickers()
    }
    
    func updateProfilePicture() {
        profilePictureButton.clipsToBounds = true
        profilePictureButton.layer.cornerRadius = profilePictureButton.frame.height / 2
        
        if let profilePictureUrlStr = tailgate.owner?.profilePictureUrl, let profilePictureUrl = URL(string: profilePictureUrlStr) {
            profilePictureButton.sd_setImage(with: profilePictureUrl, for: .normal, completed: nil)
        }
    }
    
    func initializePickers() {
        // Set the initial date for the date picker to the tailgate start time
        startTimeDatePicker.date = tailgate.startTime
        
        // Set the initial value for the public picker
        if tailgate.isPublic {
            publicPicker.selectRow(0, inComponent: 0, animated: false)
        } else {
            publicPicker.selectRow(1, inComponent: 0, animated: false)
        }
        
        // Get values for the school picker
        getSchools { (schools) in
            var selectedIndex = 0
            var schoolsSorted = schools
            schoolsSorted.sort(by: { $0.name < $1.name })
            
            for (index,school) in schoolsSorted.enumerated() {
                self.schoolPickerValues.append(school.name)
                
                if school.name == self.tailgate.school.name {
                    selectedIndex = index
                }
            }
            
            DispatchQueue.main.async {
                self.schoolPicker.reloadAllComponents()
                self.schoolPicker.selectRow(selectedIndex, inComponent: 0, animated: false)
            }
        }
    }
    
    @IBAction func updatePressed(_ sender: Any) {
        guard let schoolName = schoolButton.titleLabel?.text else { return }
        
        tailgate.name = nameTextField.text ?? ""
        tailgate.startTime = startTimeDatePicker.date
        tailgate.isPublic = (publicButton.titleLabel?.text ?? "") == "Yes"
        
        var updatedValues: [String:Any] = [:]
        updatedValues["name"] = tailgate.name
        updatedValues["isPublic"] = tailgate.isPublic
        updatedValues["startTime"] = tailgate.startTimeDatabaseStr
        updatedValues["school"] = schoolName
        updateValues(forTailgate: tailgate, values: updatedValues)
        
        getSchoolByName(name: schoolName) { (school) in
            self.tailgate.school = school
            
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    

    @IBAction func closePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func nameTextFieldTouchDown(_ sender: Any) {
        self.schoolPickerBottomConstraint.constant = -300
        self.publicPickerBottomConstraint.constant = -300
        self.startTimeDatePickerBottomConstraint.constant = -300
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    @IBAction func startTimeButtonPressed(_ sender: Any) {
        if startTimeDatePickerBottomConstraint.constant != 0 {
            self.schoolPickerBottomConstraint.constant = -300
            self.publicPickerBottomConstraint.constant = -300
            self.startTimeDatePickerBottomConstraint.constant = 0
        } else {
            self.startTimeDatePickerBottomConstraint.constant = -300
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    @IBAction func schoolButtonPressed(_ sender: Any) {
        if schoolPickerBottomConstraint.constant != 0 {
            self.startTimeDatePickerBottomConstraint.constant = -300
            publicPickerBottomConstraint.constant = -300
            self.schoolPickerBottomConstraint.constant = 0
        } else {
            self.schoolPickerBottomConstraint.constant = -300
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    @IBAction func publicButtonPressed(_ sender: Any) {
        if publicPickerBottomConstraint.constant != 0 {
            self.startTimeDatePickerBottomConstraint.constant = -300
            self.schoolPickerBottomConstraint.constant = -300
            publicPickerBottomConstraint.constant = 0
        } else {
            publicPickerBottomConstraint.constant = -300
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    @IBAction func datePickerChanged(_ sender: Any) {
        let selectedDate = startTimeDatePicker.date
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        let startDateStr = formatter.string(from: selectedDate)
        
        DispatchQueue.main.async {
            self.startTimeButton.setTitle(startDateStr, for: .normal)
        }
    }
    
}




extension TailgateDetailsViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.schoolPicker {
            return self.schoolPickerValues[row]
        } else if pickerView == self.publicPicker {
            return self.publicPickerValues[row]
        }
        
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.schoolPicker {
            self.schoolButton.setTitle(self.schoolPickerValues[row], for: .normal)
        } else if pickerView == self.publicPicker {
            self.publicButton.setTitle(self.publicPickerValues[row], for: .normal)
        }
    }
}

extension TailgateDetailsViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.schoolPicker {
            return self.schoolPickerValues.count
        } else if pickerView == self.publicPicker {
            return self.publicPickerValues.count
        }
        
        return 0
    }
}
