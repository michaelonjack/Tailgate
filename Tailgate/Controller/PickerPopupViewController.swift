//
//  WeekPickerPopupViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 9/10/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

protocol PickerPopupDelegate {
    func selectPressed(popupController:PickerPopupViewController, selectedIndex:Int, selectedValue:String)
}

class PickerPopupViewController: UIViewController {
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var pickerPopupDelegate: PickerPopupDelegate?
    var values:[String]?
    var initialIndex:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        picker.delegate = self
        picker.dataSource = self
        
        popupView.layer.cornerRadius = 10
        popupView.layer.masksToBounds = true
        
        if let index = initialIndex {
            self.picker.selectRow(index, inComponent: 0, animated: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectButtonPressed(_ sender: Any) {
        
        pickerPopupDelegate?.selectPressed(popupController: self, selectedIndex: picker.selectedRow(inComponent: 0), selectedValue: values![picker.selectedRow(inComponent: 0)])
    }
    

    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}






extension PickerPopupViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return values![row]
    }
}



extension PickerPopupViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let values = values {
            return values.count
        } else {
            return 0
        }
    }
    
    
}
