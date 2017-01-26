//
//  EMNUtils.swift
//  emn
//
//  Created by Jason Cox on 9/30/15.
//  Copyright © 2015 Angel Jonathan GM. All rights reserved.
//

import Foundation

let sharedUtils : EMNUtils = EMNUtils()
class EMNUtils:NSObject
{
    
    override init()
    {
        super.init();
    }
    class var sharedInstance : EMNUtils {
        return sharedUtils
    }
    
    class func encodeString(str: String) -> String
    {
        let parsedStr = CFURLCreateStringByAddingPercentEscapes(
            nil,
            str,
            nil,
            "!*'();:@&=+$,/?%#[]", //you can add another special characters
            CFStringBuiltInEncodings.UTF8.rawValue
        );
        return parsedStr as String;
    }
    class func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
}