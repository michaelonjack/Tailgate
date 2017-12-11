//
//  DatabaseHelper.swift
//  
//
//  Created by Michael Onjack on 12/10/17.
//

import Foundation
import Firebase

//////////////////////////////////////////////////////////////////////////////////////
//
//
//
//
//
func uploadProfilePictureForUser(userid:String, image:UIImage) {
    let userReference = Database.database().reference(withPath: "users/" + userid)
    let userStorageReference = Storage.storage().reference(withPath: "images/" + userid + "/ProfilePicture")
    
    let imageMetaData = StorageMetadata()
    imageMetaData.contentType = "image/jpeg"
    
    var imageData = Data()
    imageData = UIImageJPEGRepresentation(image, 1.0)!
    
    userStorageReference.putData(imageData, metadata: imageMetaData) { (metaData, error) in
        if error == nil {
            // Add the image's url to the Firebase database
            let downloadUrl = metaData?.downloadURL()?.absoluteString
            userReference.updateChildValues(["profilePictureUrl": downloadUrl!])
            
        }
    }
}
