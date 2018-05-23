//
//  GamedayContainerViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 5/19/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

class GamedayContainerViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var navigationCollectionView: UICollectionView!
    
    let navigationButtons:[String] = ["SIGNS", "SCHEDULE", "FLAIR"]
    var gameDayPageViewController: GamedayPageViewController?
    var lastSelectedButtonIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationCollectionView.delegate = self
        self.navigationCollectionView.dataSource = self
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.navigationCollectionView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.navigationCollectionView.backgroundView = blurEffectView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let pageController = segue.destination as? GamedayPageViewController {
            self.gameDayPageViewController = pageController
            pageController.containerController = self
        }
    }
    
}



extension GamedayContainerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectNavigationCell(indexPath: indexPath)
        
        // If the selected index is to the right of the current index, animate a scroll forward
        if self.lastSelectedButtonIndex < indexPath.row {
            var i = self.lastSelectedButtonIndex + 1
            while i <= indexPath.row {
                if let nextController = self.gameDayPageViewController?.controllers[i] {
                    self.gameDayPageViewController?.setViewControllers([nextController], direction: .forward, animated: true, completion: nil)
                }
                i = i + 1
            }
        }
        
        // If the selected index is to the left of the current index, animate a scroll backward
        else if self.lastSelectedButtonIndex > indexPath.row {
            var i = self.lastSelectedButtonIndex - 1
            while i >= indexPath.row {
                if let nextController = self.gameDayPageViewController?.controllers[i] {
                    self.gameDayPageViewController?.setViewControllers([nextController], direction: .reverse, animated: true, completion: nil)
                }
                i = i - 1
            }
        }
        
        self.lastSelectedButtonIndex = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! LabelCollectionViewCell
        
        // Change the label color to show the cell was deselected
        cell.label.textColor = .nickel
    }
    
    func selectNavigationCell(indexPath: IndexPath) {
        for i in 0...self.navigationButtons.count-1 {
            
            let cell = self.navigationCollectionView.cellForItem(at: IndexPath(item: i, section: 0)) as! LabelCollectionViewCell
            
            if indexPath.row == i {
                self.navigationCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                cell.label.textColor = .black
            }
            
            else {
                self.navigationCollectionView.deselectItem(at: indexPath, animated: true)
                cell.label.textColor = .nickel
            }
        }
    }
}



extension GamedayContainerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.navigationButtons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NavigationCell", for: indexPath) as! LabelCollectionViewCell
        
        cell.label.text = self.navigationButtons[indexPath.row]
        if let selectedIndexes = collectionView.indexPathsForSelectedItems, selectedIndexes.count == 0, indexPath.row == 1 {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            cell.label.textColor = .black
        }
        
        return cell
    }
}


extension GamedayContainerViewController : UICollectionViewDelegateFlowLayout {
    // responsible for telling the layout the size of a given cell
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width/3, height: collectionView.bounds.size.height)
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
