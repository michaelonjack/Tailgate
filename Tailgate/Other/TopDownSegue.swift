//
//  TopDownSegue.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/10/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import UIKit

class TopDownSegue: UIStoryboardSegue {
    let duration: TimeInterval = 0.5
    let delay: TimeInterval = 0
    let animationOptions: UIView.AnimationOptions = [.curveEaseInOut]
    
    override func perform() {
        // get views
        let sourceView = source.view
        let destinationView = destination.view
        
        // get screen height
        let screenHeight = UIScreen.main.bounds.size.height
        destinationView?.transform = CGAffineTransform(translationX: 0, y: -screenHeight)
        
        // add destination view to view hierarchy
        UIApplication.shared.keyWindow?.insertSubview(destinationView!, aboveSubview: sourceView!)
        
        // animate
        UIView.animate(withDuration: duration, delay: delay, options: animationOptions, animations: {
            destinationView?.transform = CGAffineTransform.identity
        }) { (_) in
            self.source.present(self.destination, animated: false, completion: nil)
        }
    }
}
