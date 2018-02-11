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
func uploadTailgatePicture(tailgate:Tailgate, userid:String, image:UIImage, completion : @escaping (_ downloadUrl: String?) -> Void) {
    let timestamp = String(UInt64((Date().timeIntervalSince1970 + 62_135_596_800) * 10_000_000))
    let imageUrlsReference = Database.database().reference(withPath: "tailgates/" + tailgate.id + "/imageUrls")
    let userStorageReference = Storage.storage().reference(withPath: "images/" + userid + "/tailgate/" + tailgate.id + "/" +  timestamp)
    
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



//////////////////////////////////////////////////////////////////////////////////////
//
//
//
//
//
func getTailgateImageUrls(tailgate:Tailgate, completion: @escaping (_ urls: [String]) -> Void) {
    var imgUrls:[String] = []
    let imageUrlsReference = Database.database().reference(withPath: "tailgates/" + tailgate.id + "/imageUrls")
    
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



//////////////////////////////////////////////////////////////////////////////////////
//
//
//
//
//
func getSchools(completion: @escaping (([School]) -> Void)) {
    var schools:[School] = []
    let schoolReference = Database.database().reference(withPath: "schools/")
    
    schoolReference.observeSingleEvent(of: .value, with: { (snapshot) in
        for schoolSnapshot in snapshot.children {
            let school = School(snapshot: schoolSnapshot as! DataSnapshot)
            schools.append(school)
        }
        
        completion(schools)
    })
}


//////////////////////////////////////////////////////////////////////////////////////
//
//
//
//
//
func getFood(completion: @escaping (([Food]) -> Void)) {
    var foods:[Food] = []
    let foodReference = Database.database().reference(withPath: "food/")
    
    foodReference.observeSingleEvent(of: .value, with: { (snapshot) in
        for foodSnapshot in snapshot.children {
            let food = Food(snapshot: foodSnapshot as! DataSnapshot)
            foods.append(food)
        }
        
        completion(foods)
    })
}



//////////////////////////////////////////////////////////////////////////////////////
//
//
//
//
//
func getDrinks(completion: @escaping (([Drink]) -> Void)) {
    var drinks:[Drink] = []
    let drinkReference = Database.database().reference(withPath: "drinks/")
    
    drinkReference.observeSingleEvent(of: .value, with: { (snapshot) in
        for drinkSnapshot in snapshot.children {
            let drink = Drink(snapshot: drinkSnapshot as! DataSnapshot)
            drinks.append(drink)
        }
        
        completion(drinks)
    })
}



//////////////////////////////////////////////////////////////////////////////////////
//
//
//
//
//
func getUsers(completion: @escaping (([User]) -> Void)) {
    var users:[User] = []
    let userReference = Database.database().reference(withPath: "users/")
    
    userReference.observeSingleEvent(of: .value, with: { (snapshot) in
        for userSnapshot in snapshot.children {
            let user = User(snapshot: userSnapshot as! DataSnapshot)
            users.append(user)
        }
        
        completion(users)
    })
}



//////////////////////////////////////////////////////////////////////////////////////
//
//
//
//
//
func getSchoolByName(name:String, completion: @escaping ((School) -> Void)) {
    let schoolPath = name.replacingOccurrences(of: " ", with: "")
    let schoolReference = Database.database().reference(withPath: "schools/" + schoolPath)
    
    schoolReference.observeSingleEvent(of: .value, with: { (snapshot) in
        let school = School(snapshot: snapshot)
        completion(school)
    })
}




//////////////////////////////////////////////////////////////////////////////////////
//
//
//
//
//
func getUserById(userId:String, completion: @escaping ((User) -> Void)) {
    let userReference = Database.database().reference(withPath: "users/" + userId)
    
    userReference.observeSingleEvent(of: .value, with: { (snapshot) in
        let user = User(snapshot: snapshot)
        completion(user)
    })
}



//////////////////////////////////////////////////////////////////////////////////////
//
//
//
//
//
func getDrinkById(drinkId:String, completion: @escaping ((Drink) -> Void)) {
    let drinkReference = Database.database().reference(withPath: "drinks/" + drinkId)
    
    drinkReference.observeSingleEvent(of: .value, with: { (snapshot) in
        let drink = Drink(snapshot: snapshot)
        completion(drink)
    })
}



//////////////////////////////////////////////////////////////////////////////////////
//
//
//
//
//
func getFoodById(foodId:String, completion: @escaping ((Food) -> Void)) {
    let foodReference = Database.database().reference(withPath: "food/" + foodId)
    
    foodReference.observeSingleEvent(of: .value, with: { (snapshot) in
        let food = Food(snapshot: snapshot)
        completion(food)
    })
}
