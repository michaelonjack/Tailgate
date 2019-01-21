//
//  GamedayPageViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 5/19/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

class GamedayPageViewController: UIPageViewController {
    
    var containerController:GamedayContainerViewController!
    var currentIndex = 1
    var pendingIndex = 1
    
    lazy var controllers: [UIViewController] = {
        let scheduleController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GamedayScheduleViewController")
        let signsController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GamedaySignsViewController")
        let flairController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FlairNavigationController")
        let rankingsController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GamedayRankingsViewController")
        
        return [rankingsController, signsController, scheduleController, flairController]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        self.dataSource = self
        
        // This sets up the first view that will show up on our page control
        setViewControllers([controllers[2]], direction: .forward, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}



extension GamedayPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if pendingViewControllers.count > 0  {
            let pendingController = pendingViewControllers[0]
            if let index = self.controllers.index(of: pendingController) {
                self.pendingIndex = index
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            self.currentIndex = self.pendingIndex
            self.containerController.lastSelectedButtonIndex = self.pendingIndex
            self.containerController.selectNavigationCell(indexPath: IndexPath(item: self.pendingIndex, section: 0))
        }
    }
}




extension GamedayPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let controllerIndex = controllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = controllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return controllers.last
        }
        
        guard controllers.count > previousIndex else {
            return nil
        }
        
        return controllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let controllerIndex = controllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = controllerIndex + 1
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard controllers.count != nextIndex else {
            return controllers.first
        }
        
        guard controllers.count > nextIndex else {
            return nil
        }
        
        return controllers[nextIndex]
    }
}
