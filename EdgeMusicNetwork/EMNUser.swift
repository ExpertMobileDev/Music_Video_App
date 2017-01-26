//
//  User.swift
//  EdgeMusicNetwork
//
//  Created by Angel Jonathan GM on 7/15/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import Foundation

class EMNUser: NSObject {
	
    var id: String?;
    var firstName: String?;
    var lastName: String?;
    var email: String?;
    var zipCode: String?;
    var password: String?;
    var points: String?;
    var birthday: String?;
    var gender: String?;
    var fbDataJson: String?;
    var coverPhotoUrlString: String?;
    var avatarUrlString: String?;
    var trialDaysLeft: String?;
    var subscriptionType: String?;
    
    
    var avatarImage: UIImage?;
    var coverImage: UIImage?;
    
    var retrievedFavorites = false;
    
    var favorites = [Video]();
        
	init(firstName: String, lastName: String, email: String, password: String?) {
        self.subscriptionType = "free";
        self.trialDaysLeft = "14";
        self.points = "0";
        self.firstName = firstName;
        self.lastName = lastName;
        self.email = email;
        self.password = password;
	}
    func encodeWithCoder(encoder:NSCoder){
        
    }
    func addVideoToFavorites(video : Video){
        favorites.append(video);
    }
	
    func removeVideoFromFavorites(video : Video){
        if let index = self.indexOfFavoriteVideo(video)
        {
            favorites.removeAtIndex(index);
        }
    }
    
    func subscriber() -> Bool
    {
        if(self.subscriptionType! == "free"){
            return false;
        }
        return true;
    }
    
    func indexOfFavoriteVideo(video : Video) -> Int?
    {
        var key = 0;
        for favoriteVideo in self.favorites
        {
            if(favoriteVideo.id == video.id){
                return key;
            }
            key += 1;
        }
        return nil;
    }
    
	func asDictionary() -> [String: String] {
        let zipcode = (zipCode != nil) ? zipCode : ""
        let user_gender = (gender != nil) ? gender : ""
        let user_birthday = (birthday != nil) ? birthday : ""
        
        return ["firstName": firstName!, "lastName": lastName!, "email": email!, "password": password!, "gender": user_gender!, "birthday": user_birthday!, "zipcode": zipcode!, "subscriptionType":subscriptionType!,"trialDaysLeft":trialDaysLeft!];
	}
    func getUserWithDictionary(dictUser : NSDictionary) -> EMNUser {
        let userFirstName = (dictUser.objectForKey("firstName") != nil) ? dictUser.objectForKey("firstName") as! String : ""
        let userLastName = (dictUser.objectForKey("lastName") != nil) ? dictUser.objectForKey("lastName") as! String : ""
        let userEmail = (dictUser.objectForKey("email") != nil) ? dictUser.objectForKey("email") as! String : ""
        let userpassword = (dictUser.objectForKey("password") != nil) ? dictUser.objectForKey("password") as! String : ""
        let usergender = (dictUser.objectForKey("gender") != nil) ? dictUser.objectForKey("gender") as! String : ""
        let userbirthday = (dictUser.objectForKey("birthday") != nil) ? dictUser.objectForKey("birthday") as! String : ""
        let userzipcode = (dictUser.objectForKey("zipcode") != nil) ? dictUser.objectForKey("zipcode") as! String : ""
        let usersubscriptionType = (dictUser.objectForKey("subscriptionType") != nil) ? dictUser.objectForKey("subscriptionType") as! String : ""
        let usertrialDaysLeft = (dictUser.objectForKey("trialDaysLeft") != nil) ? dictUser.objectForKey("trialDaysLeft") as! String : ""
        let user = EMNUser(firstName: userFirstName, lastName: userLastName, email: userEmail, password: userpassword)
        user.gender = usergender
        user.birthday = userbirthday
        user.zipCode = userzipcode
        user.subscriptionType = usersubscriptionType
        user.trialDaysLeft = usertrialDaysLeft
        
        return user
    }
	func asQueryString() -> String {
		let p = password ?? "";
        let fn = EMNUtils.encodeString(firstName!);
        let ln = EMNUtils.encodeString(lastName!);
        let em = EMNUtils.encodeString(email!);
        let pw = EMNUtils.encodeString(p);
        let gend = (gender != nil) ? EMNUtils.encodeString(gender!) : "unspecified";
        let bday = (birthday != nil) ? EMNUtils.encodeString(birthday!) : "1990-01-01";
        let zip = (zipCode != nil) ? EMNUtils.encodeString(zipCode!) : "";
        var str = "first_name=\(fn)&last_name=\(ln)&email=\(em)&password=\(pw)&gender=\(gend)&birthday=\(bday)&zipcode=\(zip)";
        if(fbDataJson != nil){
            let encodedStr = EMNUtils.encodeString(fbDataJson!);
            str += "&fb_profile=" + encodedStr;
        }
        if(coverPhotoUrlString != nil){
            let encodedStr = EMNUtils.encodeString(coverPhotoUrlString!);
            str += "&photo=" + encodedStr;
        }
        if(avatarUrlString != nil){
            let encodedStr = EMNUtils.encodeString(avatarUrlString!);
            str += "&avatar=" + encodedStr;
        }
        print("User Query : \(str)")
        return str
	}
    
}
