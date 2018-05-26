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



extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}



extension UIColor {
    static let lavender = UIColor(red:0.72, green:0.56, blue:0.90, alpha:1.0)
    static let steel = UIColor(red:0.475635, green:0.475647, blue:0.47564, alpha:1.0)
    static let salmon = UIColor(red: 1.0, green: 0.493272, blue: 0.473998, alpha: 1.0)
    static let cantaloupe = UIColor(red: 1.0, green: 0.832346, blue: 0.473206, alpha: 1.0)
    static let nickel = UIColor(red: 0.574149, green: 0.574162, blue: 0.574155, alpha: 1.0)
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



extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}



class EmptyBackgroundView: UIView {
    private var owner: UIScrollView!
    private var imageView: UIImageView!
    private var titleLabel: UILabel!
    private var messageLabel: UILabel!
    
    var didSetupConstraints = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(scrollView:UIScrollView, image: UIImage, title: String, message: String) {
        super.init(frame: CGRect.zero)
        self.owner = scrollView
        self.backgroundColor = UIColor(red:0.94, green:0.95, blue:0.96, alpha:1.0)
        
        self.imageView = UIImageView(frame: CGRect.zero)
        self.imageView.image = image
        self.imageView.contentMode = .scaleAspectFit
        
        self.titleLabel = UILabel(frame: CGRect.zero)
        self.titleLabel.text = title
        self.titleLabel.textAlignment = .center
        self.titleLabel.textColor = .black
        self.titleLabel.numberOfLines = 0
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.titleLabel.minimumScaleFactor = 0.2
        self.titleLabel.font = UIFont.systemFont(ofSize: 23.0, weight: .light)
        
        self.messageLabel = UILabel(frame: CGRect.zero)
        self.messageLabel.text = message
        self.messageLabel.textAlignment = .center
        self.messageLabel.textColor = .lightGray
        self.messageLabel.numberOfLines = 0
        self.messageLabel.adjustsFontSizeToFitWidth = true
        self.messageLabel.minimumScaleFactor = 0.2
        self.messageLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .light)
        
        addSubview(self.imageView)
        addSubview(self.titleLabel)
        addSubview(self.messageLabel)
    }
    
    override func updateConstraints() {
        
        if !didSetupConstraints {
            self.owner.setNeedsLayout()
            self.owner.layoutIfNeeded()
            
            self.translatesAutoresizingMaskIntoConstraints = false
            self.imageView.translatesAutoresizingMaskIntoConstraints = false
            self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
            self.messageLabel.translatesAutoresizingMaskIntoConstraints = false
            
            self.widthAnchor.constraint(equalTo: self.owner.widthAnchor).isActive = true
            self.heightAnchor.constraint(equalTo: self.owner.heightAnchor).isActive = true
            self.centerXAnchor.constraint(equalTo: self.owner.centerXAnchor).isActive = true
            self.centerYAnchor.constraint(equalTo: self.owner.centerYAnchor).isActive = true
            
            self.imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            self.imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: (-0.212431 * self.frame.height)).isActive = true
            self.imageView.widthAnchor.constraint(equalToConstant: self.frame.height / 2.5).isActive = true
            self.imageView.heightAnchor.constraint(equalToConstant: self.frame.height / 2.5).isActive = true
            
            self.titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            self.titleLabel.widthAnchor.constraint(equalToConstant: self.frame.width / 1.5).isActive = true
            self.titleLabel.heightAnchor.constraint(equalToConstant: self.frame.height / 10).isActive = true
            self.titleLabel.topAnchor.constraint(equalTo: self.imageView.topAnchor, constant: (self.frame.height / 2.5) + 15).isActive = true
            
            self.messageLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            self.messageLabel.widthAnchor.constraint(equalToConstant: self.frame.width / 1.5).isActive = true
            self.messageLabel.heightAnchor.constraint(equalToConstant: self.frame.height / 6).isActive = true
            self.messageLabel.topAnchor.constraint(equalTo: self.titleLabel.topAnchor, constant: self.frame.height / 15).isActive = true
            
            didSetupConstraints = true
        }
        
        super.updateConstraints()
    }
}



class PaddedTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10);
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
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
            superview.bringSubview(toFront: dropDownView)
            
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










