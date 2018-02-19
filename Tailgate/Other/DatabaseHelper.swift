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
// uploadProfilePictureForUser
//
// Uploads the parameter UIImage to the user's storage (specified by the userid parameter)
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
// uploadTailgatePicture
//
// Uploads the parameter UIImage to the tailgate storage for the user specified by the userid parameter
// Returns a completion block that gives the images download url
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
// getTailgateImageUrls
//
// Returns the download urls of all images associated with the parameter tailgate
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
// getFlairImageUrls
//
// Returns the download urls of all flair images associated with the parameter school as a tuple
// where tuple.0 = the url of 3x image and tuple.1 = url of 1x image
//
func getFlairImageUrls(school:School, completion: @escaping (_ urls: [(url3x:String, url1x:String)]) -> Void) {
    var imgUrls: [(url3x:String, url1x:String)] = []
    let imageUrlsReference = Database.database().reference(withPath: "schools/" + school.name.replacingOccurrences(of: " ", with: "") + "/flairImageUrls")
    
    imageUrlsReference.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let flair = snapshot.value as? [String:AnyObject] {
            
            for (name, urlPair) in flair {
                print(name)
                var flairPair:(url3x:String, url1x:String) = ("", "")
                /*
                    urlDict should look like:
                    {
                        1x: url1
                        3x: url2
                    }
                */
                if let urlDict = urlPair as? NSDictionary {
                    for (key,value) in urlDict {
                        let key = key as? String ?? ""
                        let value = value as? String ?? ""
                        
                        if key == "3x" {
                            flairPair.url3x = value
                        } else {
                            flairPair.url1x = value
                        }
                    }
                }
                if flairPair.0 != "" {
                    imgUrls.append(flairPair)
                }
            }
        }
        completion(imgUrls)
    })
}



//////////////////////////////////////////////////////////////////////////////////////
//
// getTailgates
//
// Returns all tailgates from the database
//
func getTailgates(completion: @escaping (([Tailgate]) -> Void)) {
    var tailgates:[Tailgate] = []
    let tailgateReference = Database.database().reference(withPath: "tailgates/")
    
    tailgateReference.observeSingleEvent(of: .value, with: { (snapshot) in
        for tailgateSnapshot in snapshot.children {
            let tailgate = Tailgate(snapshot: tailgateSnapshot as! DataSnapshot)
            tailgates.append(tailgate)
        }
        
        completion(tailgates)
    })
}



//////////////////////////////////////////////////////////////////////////////////////
//
// getSchools
//
// Returns all schools from the database
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
// getFood
//
// Returns all food entries in the database
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
// getDrinks
//
// Returns all drinks from the database
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
// getUsers
//
// Returns all users from the database
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
// getSchoolByName
//
// Returns the school with the parameter name
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
// getUserById
//
// Returns with user with the parameter id
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
// getDrinkById
//
// Returns the drink with the parameter id
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
// getFoodById
//
// Returns the food with the parameter id
//
func getFoodById(foodId:String, completion: @escaping ((Food) -> Void)) {
    let foodReference = Database.database().reference(withPath: "food/" + foodId)
    
    foodReference.observeSingleEvent(of: .value, with: { (snapshot) in
        let food = Food(snapshot: snapshot)
        completion(food)
    })
}



//////////////////////////////////////////////////////////////////////////////////////
//
// updateTailgateInvites
//
// Updates the list of invites for the given tailgate
//
func updateTailgateInvites(tailgate:Tailgate, invites:[User]) {
    let tailgateReference = Database.database().reference(withPath: "tailgates/" + tailgate.id)
    
    var inviteDict: [String:String] = [:]
    for invite in invites {
        inviteDict["id"] = invite.uid
    }
    
    tailgateReference.updateChildValues(["invites":inviteDict])
}


