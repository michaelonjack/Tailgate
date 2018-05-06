//
//  BiometricIDAuth.swift
//  Tailgate
//
//  Created by Michael Onjack on 5/5/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import Foundation
import LocalAuthentication

class BiometricIDAuth {
    let context = LAContext()
    var loginReason = "Logging in with Touch ID"
    
    func getSupportedBiometricType() -> LABiometryType {
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType
    }
    
    
    /////////////////////////////////////////////////////
    //
    //  canEvaluatePolicy
    //
    //  Returns true if the current user's device supports biometric IDs
    //
    func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    
    
    /////////////////////////////////////////////////////
    //
    //  authenticateUser
    //
    //  Authenicate the current user using biometrics if available
    //
    func authenticateUser(completion: @escaping (String?) -> Void) {
        // check whether the device is capable of biometric authentication
        guard canEvaluatePolicy() else {
            completion("Touch ID not available")
            return
        }
        
        // If the device does support biometric ID, then prompt the user for their biometric info
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: loginReason) { (success, evaluateError) in
            
            if success {
                DispatchQueue.main.async {
                    // User authenticated successfully, take appropriate action
                    completion(nil)
                }
            } else {
                let message: String
                
                switch evaluateError {
                    case LAError.authenticationFailed?:
                        message = "There was a problem verifying your identity."
                    case LAError.userCancel?:
                        message = "Authentication canceled."
                    case LAError.userFallback?:
                        message = "Authentication canceled."
                    case LAError.biometryNotAvailable?:
                        message = "Face ID/Touch ID is not available."
                    case LAError.biometryNotEnrolled?:
                        message = "Face ID/Touch ID is not set up."
                    case LAError.biometryLockout?:
                        message = "Face ID/Touch ID is locked."
                    default:
                        message = "Face ID/Touch ID may not be configured"
                }
                
                completion(message)
            }
        }
    }
}
