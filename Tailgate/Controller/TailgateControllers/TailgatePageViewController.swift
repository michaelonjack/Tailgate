//
//  TailgatePageViewController.swift
//  Tailgate
//
//  Created by Michael Onjack on 10/28/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

class TailgatePageViewController: UIPageViewController {
    
    weak var containerController:TailgateViewController!
    var currentIndex = 0
    var pendingIndex = 0
    
    lazy var controllers: [UIViewController] = {
        let photosController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TailgatePhotosViewController")
        if let photosController = photosController as? TailgatePhotosViewController {
            photosController.tailgate = containerController.tailgate
        }
        
        let messagesController:UIViewController = TailgateMessagesViewController()
        if let messagesController = messagesController as? TailgateMessagesViewController {
            messagesController.tailgate = containerController.tailgate
        }
        
        let messagesDeniedController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TailgateMessagesDeniedViewController")
    
        // If the current user is not invited to the tailgate, hide the messages
        if containerController.tailgate.isUserInvited(userId: getCurrentUserId()) || containerController.tailgate.isOwner(userId: getCurrentUserId()) {
            return [photosController, messagesController]
        } else {
            return [photosController, messagesDeniedController]
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self

        // This sets up the first view that will show up on our page control
        setViewControllers([controllers[0]], direction: .forward, animated: true, completion: nil)
    }

}



extension TailgatePageViewController: UIPageViewControllerDelegate {
    
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
        }
    }
}




extension TailgatePageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let controllerIndex = controllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = controllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return nil
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
            return nil
        }
        
        guard controllers.count > nextIndex else {
            return nil
        }
        
        return controllers[nextIndex]
    }
}

