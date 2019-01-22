//
//  InterfaceHelper.swift
//  Tailgate
//
//  Created by Michael Onjack on 3/25/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

func createAlert(title: String, message: String) -> UIAlertController {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let closeAction = UIAlertAction(title: "Close", style: .default)
    alert.addAction(closeAction)
    
    return alert
}



extension NSLayoutConstraint {
    func updateVerticalConstantForViewHeight(view:UIView) {
        let heightMultiplier = view.bounds.height / 667
        self.constant = self.constant * heightMultiplier
    }
    
    func updateHorizontalConstantForViewWidth(view:UIView) {
        let widthMultiplier = view.bounds.width / 375
        self.constant = self.constant * widthMultiplier
    }
}



extension CALayer {
    static func createBottomBorder(forFrame frame: CGRect, withThickness thickness: CGFloat, withColor color: CGColor) -> CALayer {
        let bottomBorder = CALayer()
        let borderWidth = frame.width
        let borderHeight = thickness
        let borderOffset = frame.height - thickness
        
        bottomBorder.frame = CGRect(x: 0.0, y: Double(borderOffset), width: Double(borderWidth), height: Double(borderHeight))
        bottomBorder.backgroundColor = color
        
        return bottomBorder
    }
    
    static func createTopBorder(forFrame frame: CGRect, withThickness thickness: CGFloat, withColor color: CGColor) -> CALayer {
        let bottomBorder = CALayer()
        let borderWidth = frame.width
        bottomBorder.frame = CGRect(x: 0.0, y: 0.0, width: Double(borderWidth), height: Double(thickness))
        bottomBorder.backgroundColor = color
        
        return bottomBorder
    }
}



class PaddedTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10);
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}




class DropDownButton: UIButton {
    
    var dropDownView: DropDownView!
    var dropDownViewHeightConstraint: NSLayoutConstraint!
    var isDropDownOpen: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMoveToSuperview() {
        if let superview = self.superview {
            dropDownView = DropDownView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0 ))
            dropDownView.translatesAutoresizingMaskIntoConstraints = false
            
            superview.addSubview(dropDownView)
            superview.bringSubviewToFront(dropDownView)
            
            dropDownView.topAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            dropDownView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            dropDownView.widthAnchor.constraint(equalToConstant: 150).isActive = true
            dropDownViewHeightConstraint = dropDownView.heightAnchor.constraint(equalToConstant: 0)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isDropDownOpen == false {
            isDropDownOpen = true
            
            // Be sure constraint is deactivated, then activate it
            NSLayoutConstraint.deactivate([self.dropDownViewHeightConstraint])
            self.dropDownViewHeightConstraint.constant = self.dropDownView.tableView.contentSize.height
            NSLayoutConstraint.activate([self.dropDownViewHeightConstraint])
            
            // Animate the activation of the constraints we just put into place
            UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.dropDownView.layoutIfNeeded()
                self.dropDownView.center.y += self.dropDownView.frame.height / 2
            }, completion: nil)
        }
        
        else {
            isDropDownOpen = false
            
            // Be sure constraint is deactivated, then activate it
            NSLayoutConstraint.deactivate([self.dropDownViewHeightConstraint])
            self.dropDownViewHeightConstraint.constant = 0
            NSLayoutConstraint.activate([self.dropDownViewHeightConstraint])
            
            // Animate the activation of the constraints we just put into place
            UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.dropDownView.center.y -= self.dropDownView.frame.height / 2
                self.dropDownView.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
}



class DropDownView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    var dropDownOptions: [String] = []
    var tableView = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
        tableView.layer.masksToBounds = true
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        tableView.layer.borderWidth = 1.0
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(tableView)
        tableView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dropDownOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel?.text = dropDownOptions[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 10, weight: .ultraLight)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(dropDownOptions[indexPath.row])
    }
    
}


enum ScrollDirection {
    case horizontal
    case vertical
    case undefined
}

enum TableState {
    case loading
    case populated
    case empty
    case error(Error)
}

enum CollectionState {
    case loading
    case populated
    case empty
    case error(Error)
}





