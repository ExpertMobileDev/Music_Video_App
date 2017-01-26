//
//  TextFieldValidationsManager.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 7/15/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit

enum TextFieldValidationResult: Int {
	case OK
	case EMPTY
	case NOT_MINIMUM
	case NOT_MAXIMUM
	//case SPECIAL
	//case SPACE
	//case EMAIL
}

class TextFieldValidationsManager: NSObject {
	
	let maxLength = 64
	let minLength = 6
	let minNameLength = 1
	
	func removeWhiteSpacesInString(string: String) -> String {
		let components = string.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).filter({!$0.characters.isEmpty})
		return components.joinWithSeparator("")
	}
	
	func isContentValid (textField: String ) -> TextFieldValidationResult {
		//var errorState: TextFieldValidationResult
		var auxTextField = ""
		auxTextField = removeWhiteSpacesInString(textField)
		if auxTextField.isEmpty {
			return TextFieldValidationResult.EMPTY
		} else if auxTextField.characters.count < minLength {
			return TextFieldValidationResult.NOT_MINIMUM
		} else if auxTextField.characters.count > maxLength {
			return TextFieldValidationResult.NOT_MAXIMUM
		} else {
			return TextFieldValidationResult.OK
		}
	}
	
	func isContentValidForNamesAndSurnames (textField: String ) -> TextFieldValidationResult {
		//var errorState: TextFieldValidationResult
		var auxTextField = ""
		auxTextField = removeWhiteSpacesInString(textField)
		if auxTextField.isEmpty {
			return TextFieldValidationResult.EMPTY
		} else if auxTextField.characters.count < minNameLength {
			return TextFieldValidationResult.NOT_MINIMUM
		} else if auxTextField.characters.count > maxLength {
			return TextFieldValidationResult.NOT_MAXIMUM
		} else {
			return TextFieldValidationResult.OK
		}
	}
	
	func isValidEmail(testString:String) -> Bool {
		let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
		let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
		return emailTest.evaluateWithObject(testString)
	}
	
	func isOnlyAlphabetic(textField: UITextField) -> Bool {
		let digits = NSCharacterSet.decimalDigitCharacterSet()
		for tempUnicodeChar in textField.text!.unicodeScalars {
			if digits.longCharacterIsMember(tempUnicodeChar.value) {
				return false
			}
		}
		return true
	}
	
	func detectSpecialCharacters(testString:String) -> Bool {
		let regex = try! NSRegularExpression(pattern: ".*[^A-Za-z0-9].*", options: [])
		if regex.firstMatchInString(testString, options: [], range: NSMakeRange(0, testString.characters.count)) != nil {
			return true
			
		} else {
			return false
		}
	}
	
	func detectWhiteSpaces(testString : String)->Bool  {
		let whitespace = NSCharacterSet.whitespaceCharacterSet()
		
		let phrase = "Test case"
		let range = phrase.rangeOfCharacterFromSet(whitespace)
		
		// range will be nil if no whitespace is found
		if let _ = range {
			return true
		}
		else {
			return false
		}
	}
	
	func isSameContent(firstTextField: UITextField, secondTextField: UITextField) -> Bool {
		if firstTextField.text == secondTextField.text {
			return true
		} else {
			return false
		}
	}
	
	func errorMessageForIssueInTextField (kindOfIssue: String, texfieldName: String) -> String {
		var errorMessageString = ""
		if kindOfIssue == "notsamestring" {
			errorMessageString = "Password must be the same in both fields"
		} else if kindOfIssue == "minNamelength" {
			errorMessageString = "\(texfieldName) is too short(minimum is \(minNameLength) characters)"
		} else if kindOfIssue == "minlength" {
			errorMessageString = "\(texfieldName) is too short (minimum is \(minLength) characters)"
		} else if kindOfIssue == "maxlength" {
			errorMessageString = "\(texfieldName) is too long (maximum is \(maxLength) characters)"
		} else if kindOfIssue == "empty" {
			errorMessageString = "\(texfieldName) is required and can't be empty"
		} else if kindOfIssue == "stringhasnumbers" {
			errorMessageString = "\(texfieldName) must only contain alphabetic characters"
		} else if kindOfIssue == "email"{
			errorMessageString = "Please enter your email in the format someone@example.com"
		} else if kindOfIssue == "special"{
			errorMessageString = "Please do not use special characters (example:$%&?!@)"
		} else if kindOfIssue == "space"{
			errorMessageString = "Please do not use white spaces"
		}
		return errorMessageString
	}
	
}
