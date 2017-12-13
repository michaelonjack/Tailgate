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


//////////////////////////////////////////////////////////////////////////////////////
//
//
//
//
//
func uploadTailgatePictureForUser(userid:String, image:UIImage, completion : @escaping (_ downloadUrl: String?) -> Void) {
    let timestamp = String(UInt64((Date().timeIntervalSince1970 + 62_135_596_800) * 10_000_000))
    let imageUrlsReference = Database.database().reference(withPath: "users/" + userid + "/tailgate/imageUrls")
    let userStorageReference = Storage.storage().reference(withPath: "images/" + userid + "/tailgate/" + timestamp)
    
    let imageMetaData = StorageMetadata()
    imageMetaData.contentType = "image/jpeg"
    
    var imageData = Data()
    imageData = UIImageJPEGRepresentation(image, 1.0)!
    
    userStorageReference.putData(imageData, metadata: imageMetaData) { (metaData, error) in
        if error == nil {
            // Add the image's url to the Firebase database
            let downloadUrl = metaData?.downloadURL()?.absoluteString
            imageUrlsReference.updateChildValues([timestamp: downloadUrl!])
            
            completion(downloadUrl)
        }
    }
}



func getTailgateImageUrlsForUser(userid:String, completion: @escaping (_ urls: [String]) -> Void) {
    var imgUrls:[String] = []
    let imageUrlsReference = Database.database().reference(withPath: "users/" + userid + "/tailgate/imageUrls")
    
    imageUrlsReference.observeSingleEvent(of: .value, with: { (snapshot) in
        if let urlDict = snapshot.value as? [String:AnyObject] {
            for (_, url) in urlDict {
                let imgUrl = url as? String ?? ""
                if imgUrl != "" {
                    imgUrls.append(imgUrl)
                }
            }
        }
        
        completion(imgUrls)
    })
}

