//
//  WebserviceManager.swift
//  EdgeMusicNetwork
//
//  Created by Developer II on 6/26/15.
//  Copyright (c) 2015 Angel Jonathan GM. All rights reserved.
//

import UIKit
import Foundation

//let baseURL = "http://52.26.204.115/"
//let baseURL = "http://api01.prd.emn.lemurdance.com/"
//let baseURL = "https://api.edgemusic.com/";
let baseURL = "http://52.42.81.12/~edgemusic/api/v2/api.edgemusicnetwork.com/";
//let baseURL = "http://edgeapi.localhost/"

class WebserviceManager: NSObject{
    
	private let failedURLMessage = "cannot access server's URL"
	
	let channelsURL = baseURL + "channel/"
	let moodsURL = baseURL + "mood/"
	let playlistsURL = baseURL + "playlist/"
	let videoURL = baseURL + "video/"
	let searchMediaURL = baseURL + "search/"
	let userLoginURL = baseURL + "user/login"
  	let fbLoginURL = baseURL + "user/fblogin"
	let userLogoutURL = baseURL + "user/logout"
	let userPasswordURL = baseURL + "user/forgotPassword"
	let userDataURL = baseURL + "user/userData"
	let registerUserURL = baseURL + "user/add"
	let addVideoToUserPlaylist = baseURL + "userPlaylist/addVideo"
	let removeVideoFromUserPlaylist = baseURL + "userPlaylist/removeVideo"
    
    let createUserPlaylistURL = baseURL + "userPlaylist/createPlaylist"
    let getUserPlaylists = baseURL + "userPlaylist/playlist_id_list"
    let addVideoToUserPlaylistNew = baseURL + "userPlaylist/addVideoNew"
    let removeVideoFromUserPlayListNew = baseURL + "userPlaylist/removeVideoNew"
    let getVideoListFromPlaylist = baseURL + "userPlaylist/getVideoList"
    let deletePlaylistURL = baseURL + "userPlaylist/deletePlaylist"
    let renamePlaylistURL = baseURL + "userPlaylist/renamePlaylist"
    let editPlaylistOrderUrl = baseURL + "userPlaylist/editPlaylistOrder"
    
    let userPlaylistVideosURL = baseURL + "userPlaylist/mytunes"
	let updateUserProfileURL = baseURL + "user/edit"
	let updateUserPasswordURL = baseURL + "user/updatePassword"
    let saveUserAvatarURL = baseURL + "user/saveAvatar";
    let saveUserCoverURL = baseURL + "user/saveCover";
    let videoReportURL = baseURL + "user/report";
	
    var registerTask: NSURLSessionUploadTask!;
    var editUserTask: NSURLSessionUploadTask!;
    
    var forgotPasswordTask: NSURLSessionUploadTask!;
    var loginTask: NSURLSessionUploadTask!;
    var fbLoginTask: NSURLSessionUploadTask!;
    var videoReportTask: NSURLSessionUploadTask!;
    
    var addVideoToPlaylistTask: NSURLSessionUploadTask!;
    var removeVideoToPlaylistTask: NSURLSessionUploadTask!;
    
    var currentReport:EMNVideoReport!
    
	func forgotPassword(email: String, completionHandler closure: (success: Bool, message: String?) -> Void) {
		if let url = NSURL(string: userPasswordURL) {
			let queryString = "username=\(email)"
			self.forgotPasswordTask = postDataInURL(url, queryString: queryString, setCookies: false, completionHandler: { (root: NSDictionary) -> Void in
				var success = false
				var message: String?
				if let status = root["status"] as? Int where status == 1 {
					success = true
				} else {
					message = root["message"] as? String
					print("[WSM] failed to send forgotpassword email")
				}
				closure(success: success, message: message)
            });
            self.forgotPasswordTask.resume();
		} else {
			closure(success: false, message: failedURLMessage)
		}
	}
	
	func getItemsInEMNCategory(type: EMNCategoryType, completionHandler closure: (items: [AnyObject]) -> Void) {
		//println("[WSM] getItemsInEMNCategory:completionHandler")
		let urlString: String?
		let name: String
		switch type {
		case .Channel:
			urlString = channelsURL
			name = "list"
		case .Mood:
			urlString = moodsURL
			name = "moodList"
		case .Playlist:
			urlString = playlistsURL
			name = "playlistList"
		}
		if let urlString = urlString, let url = NSURL(string: urlString) {
			getDataFromURL(url, completionHandler: { (root: NSDictionary) -> Void in
				let section = self.getSection(name, inRoot: root)
				let array = self.getDataInSection(section)
				var items: [AnyObject] = [EMNCategory]()
				
				if type == EMNCategoryType.Channel {
					items = self.getChannels(array)
				} else if type == EMNCategoryType.Mood {
					items = self.getMoods(array)
				} else if type == EMNCategoryType.Playlist {
					items = self.getPlaylists(array)
				}
				
				closure(items: items)
			})
		} else {
			closure(items: [AnyObject]())
		}
	}
	
	func getRecommendationsFromVideo(videoId: String, completionHandler closure: (videos: [Video]) -> Void) {
		//println("[WSM] getRecommendationsFromVideo:completionHandler")
		if let url = NSURL(string: videoURL + videoId) {
			getDataFromURL(url, completionHandler: { (root: NSDictionary) -> Void in
				let section = self.getSection("recommendedVideos", inRoot: root)
				let array = self.getDataInSection(section)
				let items = self.getVideos(array)
				closure(videos: items)
			})
		} else {
			closure(videos: [Video]())
		}
	}
	
	func getUserData(completionHandler closure: (user: EMNUser?) -> Void) {
		if let url = NSURL(string: userDataURL) {
			print("[WSM] url: \(url)")
			getDataFromURL(url, completionHandler: { (root: NSDictionary) -> Void in
				let section = self.getSection("userData", inRoot: root)
				let array = self.getDataInSection(section)
				var user: EMNUser?
				if !array.isEmpty, let dict = array[0] as? [String: AnyObject] {
					user = self.getUser(dict)
				}
				/*if !array.isEmpty, let dict = array[0] as? [String: AnyObject] {
					user = EMNUser(firstName: dict["first_name"] as? String ?? "", lastName: dict["last_name"] as? String ?? "", email: dict["email"] as? String ?? "", password: dict["password"] as? String ?? "")
				} else {
					println("[WSM] not a String:String dict")
				}*/
				closure(user: user)
			})
		} else {
			closure(user: nil)
		}
	}
	
	func getVideosInEMNCategoryItem(itemId: String, type: EMNCategoryType, completionHandler closure: (videos: [Video]) -> Void) {
		//println("[WSM] getVideosInEMNCategoryItem:type:completionHandler")
		let urlString: String?
		let name: String
		switch type {
		case .Channel:
			urlString = channelsURL + itemId
			name = "channelDetails"
		case .Mood:
			urlString = moodsURL + itemId
			name = "moodDetails"
		case .Playlist:
			urlString = playlistsURL + itemId
			name = "playlistDetails"
		}
		//println("[WSM] category url: \(url)")
		if let urlString = urlString, let url = NSURL(string: urlString) {
			getDataFromURL(url, completionHandler: { (root) -> Void in
				let section = self.getSection(name, inRoot: root)
				let array = self.getDataInSection(section)
				let videos = self.getVideos(array)
				closure(videos: videos)
			})
		} else {
			closure(videos: [Video]())
		}
	}
	
	func login(email: String, password: String, completionHandler closure: (user: EMNUser?, success: Bool, message: String?) -> Void) {
		if let url = NSURL(string: userLoginURL) {
            let email = EMNUtils.encodeString(email);
            let password = EMNUtils.encodeString(password);
			let queryString = "email=\(email)&password=\(password)"
			self.loginTask = postDataInURL(url, queryString: queryString, setCookies: true, completionHandler: { (root: NSDictionary) -> Void in
				var success = false
				var message: String?
				var user: EMNUser?
				if let status = root["status"] as? Int where status == 1 {
					success = true
					let section = self.getSection("userData", inRoot: root)
					let array = self.getDataInSection(section)
					if !array.isEmpty, let dict = array[0] as? [String: AnyObject] {
                        user = self.getUser(dict);
                        print("Adding user to singleton: \(user)");
                        Singleton.sharedInstance.user = user;
					}
				} else {
					message = root["message"] as? String
					print("[WSM] failed to login: \(message)")
				}
				closure(user: user, success: success, message: message)
            });
            self.loginTask.resume();
		} else {
			closure(user: nil, success: false, message: failedURLMessage)
		}
	}
    
    func fbLogin(email: String, facebook_id: String, fb_profile: String, completionHandler closure: (user: EMNUser?, success: Bool, message: String?) -> Void) {
        if let url = NSURL(string: fbLoginURL) {
            let email = EMNUtils.encodeString(email);
            let facebook_id = EMNUtils.encodeString(facebook_id);
            let fb_profile = EMNUtils.encodeString(fb_profile);
            let queryString = "email=\(email)&password=\(facebook_id)&fb_profile="+fb_profile;
            self.fbLoginTask = postDataInURL(url, queryString: queryString, setCookies: true, completionHandler: { (root: NSDictionary) -> Void in
                var success = false
                var message: String?
                var user: EMNUser?
                if let status = root["status"] as? Int where status == 1 {
                    success = true
                    let section = self.getSection("userData", inRoot: root)
                    let array = self.getDataInSection(section)
                    if !array.isEmpty, let dict = array[0] as? [String: AnyObject] {
                        user = self.getUser(dict)
                        print("Adding user to singleton: \(user)");
                        Singleton.sharedInstance.user = user;
                    }
                } else {
                    message = root["message"] as? String;
                    print("[WSM] failed to login: \(message)");
                }
                closure(user: user, success: success, message: message);
            });
            self.fbLoginTask.resume();
        } else {
            closure(user: nil, success: false, message: failedURLMessage);
        }
    }
	
	func logout(completionHandler closure: (success: Bool, message: String?) -> Void) {
		if let url = NSURL(string: userLogoutURL) {
			getDataFromURL(url, completionHandler: { (root: NSDictionary) -> Void in
                var success = false;
                var message: String?;
				if let status = root["status"] as? Int where status == 1 {
                    success = true;
                    Singleton.sharedInstance.user = nil;
				} else {
					message = root["message"] as? String
					print("[WSM] failed to logout: \(message)")
				}
				closure(success: success, message: message)
			})
		} else {
			closure(success: false, message: failedURLMessage)
		}
	}
	
	func registerUser(user: EMNUser, completionHandler closure: (success: Bool, message: String?) -> Void)  {
		if let url = NSURL(string: registerUserURL) {
			self.registerTask = postDataInURL(url, queryString: user.asQueryString(), setCookies: true, completionHandler: { (root) -> Void in
				var success = false
				var message: String?
                var user: EMNUser?
				if let status = root["status"] as? Int where status == 1 {
					success = true
                    let section = self.getSection("userData", inRoot: root)
                    let array = self.getDataInSection(section)
                    if !array.isEmpty, let dict = array[0] as? [String: AnyObject] {
                        user = self.getUser(dict);
                        user?.points = "2000"
                        print("Adding user to singleton: \(user)");
                        Singleton.sharedInstance.user = user;
                    }
				} else {
					message = root["message"] as? String
					print("[WSM] failed to register user: \(message)")
				}
				closure(success: success, message: message)
            });
            self.registerTask.resume();
		} else {
			closure(success: false, message: failedURLMessage)
		}
	}
    
    func reportVideoWatched(report: EMNVideoReport, completionHandler closure: (success: Bool, message: String? ) -> Void) {
        self.currentReport = report
        if let url = NSURL(string: videoReportURL) {
            let queryString = report.asQueryString();
            print("\n\n\n\n\n\n\n\nURL: \(url) querystring: \(queryString)\n\n\n\n\n\n\n");
            self.videoReportTask = postDataInURL(url, queryString: queryString, setCookies: false, completionHandler: {
                (root) -> Void in
                var success = false
                var message: String?
                if let status = root["status"] as? Int where status == 1 {
                    success = true
                    self.updateUserPoints()
                } else {
                    message = root["message"] as? String
                    print("[WSM] failed to register user: \(message)")
                }
                closure(success: success, message: message)
            });
            self.videoReportTask.resume();
        }
    }
    func updateUserPoints() {
        let report : EMNVideoReport!
        if (self.currentReport != nil) {
            report = self.currentReport
        }else if (Singleton.sharedInstance.currentReport != nil) {
            report = Singleton.sharedInstance.currentReport
        }else{
            return
        }
        
        let videoSecs = report?.quarterSeconds
        if videoSecs == 0 {
            return
        }
        let videoDuration = report?.video.duration
        let testValue = float_t(float_t(videoSecs!) / float_t(videoDuration! * 4))
        var percentageWatched : float_t = testValue * 100
        if percentageWatched > 100{
            percentageWatched = 100
        }
        if percentageWatched < 0 {
            percentageWatched = 0
        }
        var points : Int = 0
        if Singleton.sharedInstance.user.subscriber() == true {
            if(percentageWatched < 25) {
                points = 0
            }else if(percentageWatched >= 25 && percentageWatched < 50){
                points = 200
            }else if (percentageWatched >= 50 && percentageWatched < 75) {
                points = 400
            }else if (percentageWatched >= 75 && percentageWatched < 95) {
                points = 600
            }else  {
                points = 800
            }
        }else {
            if(percentageWatched < 25) {
                points = 0
            }else if(percentageWatched >= 25 && percentageWatched < 50){
                points = 100
            }else if (percentageWatched >= 50 && percentageWatched < 75) {
                points = 200
            }else if (percentageWatched >= 75 && percentageWatched < 95) {
                points = 300
            }else  {
                points = 400
            }
        }
        
        if points > 0 {
            let pointsString = Singleton.sharedInstance.user.points
            var valuesString = Int(pointsString!)
            valuesString = valuesString! + points
            let str_ = NSString(format: "%d", valuesString!) as String
            Singleton.sharedInstance.user.points = str_
            if (report != nil) {
                Singleton.sharedInstance.removeVideoReportForVideo(report.video)
                Singleton.sharedInstance.currentReport?.currentQuarterSeconds = 0;
                Singleton.sharedInstance.currentReport?.quarterSeconds = 0;
//                Singleton.sharedInstance.currentReport = nil
            }
        } else {
            if (report != nil) {
                Singleton.sharedInstance.removeVideoReportForVideo(report.video)
                Singleton.sharedInstance.currentReport?.currentQuarterSeconds = 0;
                Singleton.sharedInstance.currentReport?.quarterSeconds = 0;
//                Singleton.sharedInstance.currentReport = nil
            }
            return;
        }   
        
        
        
    }
    func addVideoToUserPlaylist(user: EMNUser, video: Video)
    {
        if let url = NSURL(string: addVideoToUserPlaylist) {
            let queryString = "video_id=\(video.id)"
            let task = postDataInURL(url, queryString: queryString, setCookies: true, completionHandler: nil);
            task.resume();
        }
    }
//    func addVideoToUserPlaylist(user: EMNUser, video: Video, playlist_name: String)
//    {
//        if let url = NSURL(string: addVideoToUserPlaylist) {
//            let queryString = "video_id=\(video.id)&playlist_name=\(playlist_name)"
//            let task = postDataInURL(url, queryString: queryString, setCookies: true, completionHandler: nil);
//            task.resume();
//        }
//    }
    
    func removeVideoFromUserPlaylist(user: EMNUser, video: Video)
    {
        if let url = NSURL(string: removeVideoFromUserPlaylist) {
            let queryString = "video_id=\(video.id)"
            let task = postDataInURL(url, queryString: queryString, setCookies: true, completionHandler: nil);
            task.resume();
        }
    }
    
    func getUserFavoriteVideos(completionHandler closure: (videos: [Video]) -> Void) {
            if let url = NSURL(string: userPlaylistVideosURL) {
            getDataFromURL(url, completionHandler: { (root) -> Void in
                let section = self.getSection("mytunes", inRoot: root)
                let array = self.getDataInSection(section)
                let videos = self.getVideos(array)
                closure(videos: videos)
            })
        } else {
            closure(videos: [Video]())
        }
    }
	func getVideoListFromPlaylist(playlistId : String,completionHandler closure: (videos: [Video]) -> Void) {
        if let url = NSURL(string: getVideoListFromPlaylist) {
            let queryString = "playlistId=\(playlistId)"
            let task = postDataInURL(url, queryString: queryString, setCookies: true, completionHandler: { (root) -> Void in
                let section = self.getSection("mytunes", inRoot: root)
                let array = self.getDataInSection(section)
                let videos = self.getVideos(array)
                closure(videos: videos)
            });
            task.resume();
        }
    }
    func removeVideoFromUserPlayListNew(playlistId : String, video : Video, closure: (result: String) -> Void) {
        if let url = NSURL(string: removeVideoFromUserPlayListNew) {
            let queryString = "playlistId=\(playlistId)&video_id=\(video.id)";
            let task = postDataInURL(url, queryString: queryString, setCookies: true, completionHandler: { (root) -> Void in
                if let status = root["status"] {
                    if status as! Int == 1 {
                        closure(result: "Success");
                    } else {
                        closure(result: "Failed");
                    }
                } else {
                    closure(result: "Failed");
                }
            });
            task.resume();
        }
    }
    func addVideoToUserPlaylistNew( playlistId : String, video : Video) {
        if let url = NSURL(string: addVideoToUserPlaylistNew) {
            let queryString = "playlistId=\(playlistId)&video_id=\(video.id)";
            let task = postDataInURL(url, queryString: queryString, setCookies: true, completionHandler:nil);
            task.resume();
        }
    }
    func getUserPlaylists(completionHandler closure: (playlists: [NSDictionary]) -> Void) {
        if let url = NSURL(string: getUserPlaylists) {
            getDataFromURL(url, completionHandler: { (root) -> Void in
                let section = self.getSection("playlist_id_list", inRoot: root)
                let array = self.getDataInSection(section)
                closure(playlists: array);
            });
        }else {
            closure(playlists: [NSDictionary]());
        }
    }
    func createUserPlaylistURL( playlistName : String, completionHandler closure: (success : Bool, message : String?, root: [NSDictionary]) -> Void) {
        if let url = NSURL(string: createUserPlaylistURL) {
            var queryString : String = ""
            if Singleton.sharedInstance.user != nil {
                let user = Singleton.sharedInstance.user
                let userId = user.id
//                queryString = "playlist_name=" + playlistName + "&" + "userId=" + userId
                queryString = "playlist_name=\(playlistName)&userId=\(userId!)"
            } else {
                queryString = "playlist_name=\(playlistName)";
            }
            let task = postDataInURL(url, queryString: queryString, setCookies: true, completionHandler: { (root) -> Void in
                var success = false
                var message : String?
                var playlistArry = [NSDictionary]()
                if let status = root["status"] as? Int where status == 1 {
                    success = true
                    let section = self.getSection("newlist", inRoot: root)
                    playlistArry = self.getDataInSection(section)
                    
                } else {
                    message = root["message"] as? String
                    print("[WSM] failed to register user: \(message)")
                }
                closure(success: success, message: message, root: playlistArry)
            });
            task.resume();
//            let request = NSMutableURLRequest(URL: url)
//            request.HTTPMethod = "POST"
//            request.HTTPBody = queryString.dataUsingEncoding(NSUTF8StringEncoding)
//            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
//                NSLog("log");
//                var root = NSDictionary()
//                if data != nil && data!.length > 0 {
//                    if let e = error {
//                        print("[WSM] error: \(e)")
//                    } else {
//                        do {
//                            let r = try NSJSONSerialization.JSONObjectWithData(data!, options:[]) as! [NSObject: AnyObject]
//                            self.postCookies(response!);
//                            root = r as NSDictionary;
//                        } catch let parseError {
//                            let s = NSString(data: data!, encoding: NSUTF8StringEncoding);
//                            print("[WSM] - UNABLE TO PARSE JSON: \(s)");
//                            print(parseError);
//                        }
//                        print("[WSM] - ROOT \(root)");
//                    }
//                } else {
//                    if(data != nil){
//                        let s = NSString(data: data!, encoding: NSUTF8StringEncoding)
//                        print("[WSM] Response: \(s)");
//                    }
//                    if let e = error {
//                        print("[WSM] failed to get main data back from POST. Error: \(e)")
//                    } else {
//                        print("[WSM] no data back from POST")
//                    }
//                }
//                NSURLSession.sharedSession().finishTasksAndInvalidate()
//                if let closure = closure {
//                    closure(root: root)
//                }
//            };

//            task.resume();
        }
    }
    func deletePlaylist(playlistId :String, completionHandler closure:(result : String, root : [NSDictionary]) ->Void) {
        if let url = NSURL(string: deletePlaylistURL) {
            let queryString = "playlist_id=\(playlistId)"
            let task = postDataInURL(url, queryString: queryString, setCookies: true, completionHandler: { (root) -> Void in
                NSLog("Log");
                if let status = root["status"] {
                    if status as! Int == 1 {
                        let section = self.getSection("updated_result", inRoot: root)
                        let array = self.getDataInSection(section)
                        closure(result: "Success", root: array);
                    } else {
                        closure(result: "Failed",root: []);
                    }
                } else {
                    closure(result: "Failed",root: []);
                }
//                let section = self.getSection("mytunes", inRoot: root)
//                let array = self.getDataInSection(section)
//                let videos = self.getVideos(array)
//                closure(videos: videos)
            });
            task.resume();
        }
    }
    func renamePlaylist(playlistId :String, playlistName : String, completionHandler closure:(result : String, root : [NSDictionary]) ->Void) {
        if let url = NSURL(string: renamePlaylistURL) {
            let queryString = "playlist_id=\(playlistId)&playlist_name=\(playlistName)"
            let task = postDataInURL(url, queryString: queryString, setCookies: true, completionHandler: { (root) -> Void in
                NSLog("Log");
                if let status = root["status"] {
                    if status as! Int == 1 {
                        let section = self.getSection("rename_result", inRoot: root)
                        let array = self.getDataInSection(section)
                        closure(result: "Success", root: array);
                    } else {
                        closure(result: "Failed",root: []);
                    }
                } else {
                    closure(result: "Failed",root: []);
                }
                //                let section = self.getSection("mytunes", inRoot: root)
                //                let array = self.getDataInSection(section)
                //                let videos = self.getVideos(array)
                //                closure(videos: videos)
            });
            task.resume();
        }
    }
    func editPlaylistOrder(videos : [Video],playlist:Playlist,  completionHandler closure : (result : String) -> Void){
        if let url = NSURL(string: editPlaylistOrderUrl){
            
            if videos.count > 0 {
                var queryString = "playlist_id=\(playlist.id)&count=\(videos.count)&";
                for i in 0  ..< videos.count {
                    let video = videos[i];
                    let video_key = NSString(format: "video%d",i) as String
                    if i == videos.count - 1 {
                        queryString = "\(queryString)\(video_key)=\(video.id)"
                    } else {
                        queryString = "\(queryString)\(video_key)=\(video.id)&"
                    }
                }
                let task = postDataInURL(url, queryString: queryString, setCookies: true, completionHandler: { (root) -> Void in
                    NSLog("Log");
                    if let status = root["status"] {
                        if status as! Int == 1 {
                            closure(result: "Success");
                        } else {
                            closure(result: "Failed");
                        }
                    } else {
                        closure(result: "Failed");
                    }
                    
                });
                task.resume();
            } else {
                closure(result: "Failed");
            }
            
        }else {
            closure(result: "Failed");
        }
    }
	func searchForMediaMatching(searchString: String, completionHandler closure: (itemsDictionary: [String: [AnyObject]]) -> Void) {
		
        let escapedString = EMNUtils.encodeString(searchString);
		if let url = NSURL(string: searchMediaURL + escapedString) where !searchString.isEmpty {
			getDataFromURL(url, completionHandler: { (root: NSDictionary) -> Void in
				let sections = self.getSections(root)
				var itemsDictionary = [String: [AnyObject]]()
				for section in sections {
					if let name = section["name"] as? String {
						let array = self.getDataInSection(section)
						var items: [AnyObject]?
						var key: String?
						
						switch name {
						case "channelSearchResults":
							print("[WSM] getting channels list")
							key = "Channels"
							items = self.getChannels(array)
						case "moodSearchResults":
							print("[WSM] getting moods list")
							key = "Moods"
							items = self.getMoods(array)
						case "playlistSearchResults":
							print("[WSM] getting playlists list")
							key = "Playlists"
							items = self.getPlaylists(array)
						case "videoSearchResults":
							print("[WSM] getting videos list")
							key = "Videos"
							items = self.getVideos(array)
						default:
							print("[WSM] getting something else not implemented")
							break
						}
						
						if let items = items where items.count > 0 {
							itemsDictionary[key!] = items
						}
					}
				}
				closure(itemsDictionary: itemsDictionary)
			})
		} else {
			closure(itemsDictionary: [String: [AnyObject]]())
		}
	}
    func upgradePremiumUser(user: EMNUser, completionHandler closure: (success: Bool, message: String?) -> Void){
        if let url = NSURL(string: updateUserProfileURL) {
            var queryString = user.asQueryString()
            queryString += "&upgradeIAPSubscription=" + EMNUtils.encodeString(String(true));
            self.editUserTask = postDataInURL(url, queryString: queryString, setCookies: true, completionHandler: { (root) -> Void in
                var success = false
                var message: String?
                if let status = root["status"] as? Int where status == 1 {
                    success = true
                } else {
                    message = root["message"] as? String
                    print("[WSM] failed to edit user: \(message)")
                }
                closure(success: success, message: message)
            });
            self.editUserTask.resume();
        } else {
            closure(success: false, message: failedURLMessage)
        }
    }
    //cancelSubscription
    func downgradeBasicUser(user: EMNUser, completionHandler closure: (success: Bool, message: String?) -> Void){
        if let url = NSURL(string: updateUserProfileURL) {
            var queryString = user.asQueryString()
            queryString += "&cancelIAPSubscription=" + EMNUtils.encodeString(String(true));
            self.editUserTask = postDataInURL(url, queryString: queryString, setCookies: true, completionHandler: { (root) -> Void in
                var success = false
                var message: String?
                if let status = root["status"] as? Int where status == 1 {
                    success = true
                } else {
                    message = root["message"] as? String
                    print("[WSM] failed to edit user: \(message)")
                }
                closure(success: success, message: message)
            });
            self.editUserTask.resume();
        } else {
            closure(success: false, message: failedURLMessage)
        }
    }
	func updateUserProfile(user: EMNUser, completionHandler closure: (success: Bool, message: String?) -> Void)  {
		if let url = NSURL(string: updateUserProfileURL) {
			self.editUserTask = postDataInURL(url, queryString: user.asQueryString(), setCookies: true, completionHandler: { (root) -> Void in
				var success = false
				var message: String?
				if let status = root["status"] as? Int where status == 1 {
					success = true
				} else {
					message = root["message"] as? String
					print("[WSM] failed to edit user: \(message)")
				}
				closure(success: success, message: message)
            });
            self.editUserTask.resume();
		} else {
			closure(success: false, message: failedURLMessage)
		}
	}
    
	func downloadImage2(url: NSURL?, completionHandler closure: (image: UIImage?) -> Void) {
		//println("[WSM] downloadImage:completionHandler:")
		if let url = url {
			//println("[WSM] url: \(url), can be opened? \(UIApplication.sharedApplication().canOpenURL(url))")
            
            let URLCache = NSURLCache(memoryCapacity: 20 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: "ImageDownloadCache");
            /*
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration();
            configuration.timeoutIntervalForRequest = 15;
            configuration.requestCachePolicy = NSURLRequestCachePolicy.ReturnCacheDataElseLoad;
            configuration.URLCache = URLCache;
			let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
            */
            let session = NSURLSession.sharedSession();
            let urlRequest = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 30.0);
            if let response = URLCache.cachedResponseForRequest(urlRequest) {
                //print("[WS] Downloading image: \(url.absoluteString) complete");
                let image = UIImage(data: response.data)
                closure(image: image);
                return;
            }
            let task = session.dataTaskWithURL(url, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
				var image: UIImage?
				if data?.length > 0 {
                    image = UIImage(data: data!);
                }else{
                    image = UIImage(named: "logo_small");
                    print("[WSM] downloaded image failed from URL: \(url)");
                }
                print("[WS] Downloading image: \(url.absoluteString) complete");
				closure(image: image)
			})
			task.resume()
		} else {
			//println("[WSM] invalid url. Using app's generic image")
			closure(image: nil)
		}
	}

	private func getDataFromURL(url: NSURL, completionHandler closure: (root: NSDictionary) -> Void) {
		print("[WSM] url: \(url)")
        /*
		let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
		configuration.timeoutIntervalForRequest = 15
		let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        */
        let session = NSURLSession.sharedSession();
		let task = session.dataTaskWithURL(url, completionHandler: {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            var root = NSDictionary();
			if ( data != nil && data!.length > 0) {
				if let e = error {
					print("[WSM] error: \(e)")
				} else {
                    /*
                    if let r = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as? NSDictionary {
                        root = r
                    }
                    */
                    do {
                        let r = try NSJSONSerialization.JSONObjectWithData(data!, options:[]) as! [NSObject: AnyObject]
                        root = r as NSDictionary;
                        //print("[WSM] - ROOT \(root)");
                    } catch let parseError {
                        let s = NSString(data: data!, encoding: NSUTF8StringEncoding);
                        print("[WSM] - UNABLE TO PARSE JSON: \(s)");
                        print(parseError);
                    }
				}
			} else {
				if let e = error {
					print("[WSM] failed to get main data back. Error: \(e)")
				} else {
					print("[WSM] no data back")
				}
			}
			session.finishTasksAndInvalidate()
			closure(root: root)
        });
		task.resume()
	}
		
	private func getChannels(array: [NSDictionary]) -> [Channel] {
		var items = [Channel]()
		for item in array {
			let category = Channel(id: item["id"] as? String ?? "", name: item["name"] as? String ?? "", thumbnailURL: item["thumbnail"] as? String ?? "", imageURL: item["image"] as? String ?? "")
			items += [category]
		}
		
		return items
	}
	
	private func getMoods(array: [NSDictionary]) -> [Mood] {
		var items = [Mood]()
		for item in array {
			let category = Mood(id: item["id"] as? String ?? "", name: item["name"] as? String ?? "", thumbnailURL: item["thumbnail"] as? String ?? "", imageURL: item["image"] as? String ?? "")
			items += [category]
		}
		
		return items
	}
	
	private func getPlaylists(array: [NSDictionary]) -> [Playlist] {
		var items = [Playlist]()
		for item in array {
			let category = Playlist(id: item["id"] as? String ?? "", name: item["name"] as? String ?? "", thumbnailURL: item["thumbnail"] as? String ?? "", imageURL: item["image"] as? String ?? "")
			items += [category]
		}
		
		return items
	}
    
    private func getDataInSection(section: NSDictionary) -> [NSDictionary] {
        if let data = section["data"] as? [NSDictionary] {
            return data
        }
        if let data = section["data"] as? NSDictionary {
            return [data];
        }
        print("[WSM] failed to find data in section: \(section)");
        return [NSDictionary]()
    }
	
	private func getSection(name: String, inRoot root: NSDictionary) -> NSDictionary {
		let sections = getSections(root)
		
		if sections.count > 0 {
			for section in sections {
				if let sectionName = section["name"] as? String where sectionName == name {
					return section
				}
			}
		}
		
		print("[WSM] failed to find section \(name)")
		return NSDictionary()
	}
	
	private func getSections(root: NSDictionary) -> [NSDictionary] {
		if let sections = root["sections"] as? [NSDictionary] {
			return sections
		}
		
		print("[WSM] failed to find sections")
		return [NSDictionary]()
	}
	
	private func getUser(dict: [String: AnyObject]) -> EMNUser {
        let user = EMNUser(firstName: dict["first_name"] as? String ?? "", lastName: dict["last_name"] as? String ?? "", email: dict["email"] as? String ?? "", password: "");
        user.points = dict["points"] as? String ?? "";
        let temp = dict["points"] as? String;
        print("Points: \(user.points) dict points: \(temp)");
        user.avatarUrlString = dict["avatar"] as? String ?? nil;
        user.coverPhotoUrlString = dict["photo"] as? String ?? nil;
        user.trialDaysLeft = dict["trial_days"] as? String ?? "0";
        user.birthday = dict["birthday"] as? String ?? "";
        user.gender = dict["gender"] as? String ?? "male";
        user.zipCode = dict["zipcode"] as? String ?? "";
        user.id = dict["id"] as? String ?? "";
        user.subscriptionType = dict["subscription_type"] as? String ?? "free";
        return user
	}
	
	private func getVideos(array: [NSDictionary]) -> [Video] {
		var items = [Video]()
		for item in array {
			let video = Video(id: item["id"] as? String ?? "", name: item["name"] as? String ?? "", thumbnailURL: item["thumbnail_url"] as? String ?? "", mediaId: item["media_id"] as? String ?? "", duration: Int((item["duration"] as? String ?? "")) ?? 0, description: item["description"] as? String ?? "", views: Int((item["views"] as? String ?? "")) ?? 0, ooyalaId: item["ooyalaid"] as? String ?? "", artistName: item["metadata_artist"] as? String ?? "", genre: item["metadata_genre"] as? String ?? "",
                points: item["points"] as? String ?? "none", tag: item["tags"] as? String ?? ""
            )
            video.fbLink = NSURL(string: item["fb_share"] as? String ?? "")
            video.itunesUrlString = item["itunes_link"] as? String ?? nil;
            video.amazonUrlString = item["amazon_link"] as? String ?? nil;
            video.isEMG = video.isEMGTag()
			items += [video]
		}
		
		return items
	}
    private func postDataInURLForPlaylist(url: NSURL, queryString: String, setCookies: Bool, completionHandler closure: ((root: NSDictionary) -> Void)?) -> NSURLSessionUploadTask {
        let session = NSURLSession.sharedSession();
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        print("[WSM] posting data to: \(url), parameters: \(queryString)")
        let task = session.uploadTaskWithRequest(request, fromData: queryString.dataUsingEncoding(NSUTF8StringEncoding), completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            var root = NSDictionary()
            if data != nil && data!.length > 0 {
                if let e = error {
                    print("[WSM] error: \(e)")
                } else {
                    do {
                        let r = try NSJSONSerialization.JSONObjectWithData(data!, options:[]) as! NSDictionary
//                        self.postCookies(response!);
                        root = r ;
                    } catch let parseError {
                        let s = NSString(data: data!, encoding: NSUTF8StringEncoding);
                        print("[WSM] - UNABLE TO PARSE JSON: \(s)");
                        print(parseError);
                    }
                    print("[WSM] - ROOT \(root)");
                }
            } else {
                if(data != nil){
                    let s = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("[WSM] Response: \(s)");
                }
                if let e = error {
                    print("[WSM] failed to get main data back from POST. Error: \(e)")
                } else {
                    print("[WSM] no data back from POST")
                }
            }
            session.finishTasksAndInvalidate()
            if let closure = closure {
                closure(root: root)
            }
        });
        return task
    }
    
	private func postCookies(response: NSURLResponse) {
		if let httpResp = response as? NSHTTPURLResponse {
			let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields((httpResp.allHeaderFields as? [String:String])!, forURL: response.URL!) as [NSHTTPCookie]
			NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookies(cookies, forURL: response.URL!, mainDocumentURL: nil)
			for cookie in cookies {
				var cookieProps = [String: AnyObject]()
				cookieProps[NSHTTPCookieName] = cookie.name
				cookieProps[NSHTTPCookieValue] = cookie.value
				cookieProps[NSHTTPCookieDomain] = cookie.domain
				cookieProps[NSHTTPCookiePath] = cookie.path
				cookieProps[NSHTTPCookieVersion] = cookie.version
				cookieProps[NSHTTPCookieExpires] = NSDate().dateByAddingTimeInterval(63072000) // 2 years
				let newCookie = NSHTTPCookie(properties: cookieProps)
				NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(newCookie!)
				print("[WSM] cookie name: \(cookie.name), value: \(cookie.value)")
			}
		}
	}
    

    //This is to uplaod a file to the server... 
    //Couldn't figure out how to hack the code above to accept this shit...
    
    private func postDataInURL(url: NSURL, queryString: String, setCookies: Bool, completionHandler closure: ((root: NSDictionary) -> Void)?) -> NSURLSessionUploadTask {
        let session = NSURLSession.sharedSession();
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        print("[WSM] posting data to: \(url), parameters: \(queryString)")
        let task = session.uploadTaskWithRequest(request, fromData: queryString.dataUsingEncoding(NSUTF8StringEncoding), completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            var root = NSDictionary()
            if data != nil && data!.length > 0 {
                if let e = error {
                    print("[WSM] error: \(e)")
                } else {
                    do {
                        let r = try NSJSONSerialization.JSONObjectWithData(data!, options:[]) as! [NSObject: AnyObject]
                        self.postCookies(response!);
                        root = r as NSDictionary;
                    } catch let parseError {
                        let s = NSString(data: data!, encoding: NSUTF8StringEncoding);
                        print("[WSM] - UNABLE TO PARSE JSON: \(s)");
                        print(parseError);
                    }
                    print("[WSM] - ROOT \(root)");
                }
            } else {
                if(data != nil){
                    let s = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("[WSM] Response: \(s)");
                }
                if let e = error {
                    print("[WSM] failed to get main data back from POST. Error: \(e)")
                } else {
                    print("[WSM] no data back from POST")
                }
            }
            session.finishTasksAndInvalidate()
            if let closure = closure {
                closure(root: root)
            }
        });
        return task;
    }
    func createAvatarRequest(avatar: UIImage) -> NSURLRequest {
        let boundary = generateBoundaryString()
        let url = NSURL(string: saveUserAvatarURL);
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = createBodyWithParameters(avatar, avatarOrCover: "avatar")
        return request
    }
    func createCoverRequest(cover: UIImage) -> NSURLRequest {
        let boundary = generateBoundaryString()
        let url = NSURL(string: saveUserCoverURL);
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = createBodyWithParameters(cover, avatarOrCover: "cover")
        return request
    }
    
    /// Create body of the multipart/form-data request
    ///
    /// :param: parameters   The optional dictionary containing keys and values to be passed to web service
    /// :param: filePathKey  The optional field name to be used when uploading files. If you supply paths, you must supply filePathKey, too.
    /// :param: paths        The optional array of file paths of the files to be uploaded
    /// :param: boundary     The multipart/form-data boundary
    ///
    /// :returns:            The NSData of the body of the request
    
    func createBodyWithParameters(var img : UIImage, avatarOrCover : String) -> NSData {
        var sizeChange = CGSizeMake(300.0, 300.0);
        if(avatarOrCover == "avatar"){
            sizeChange = CGSizeMake(300.0, 300.0);
        }else{
            sizeChange = CGSizeMake(1702.0, 630.0);
        }
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        img.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        img = UIGraphicsGetImageFromCurrentImageContext()
        
        let body = NSMutableData();
        let data = UIImageJPEGRepresentation(img, 0.6);
        let mimetype = contentTypeForImageData(data!);
        let boundary = generateBoundaryString();
        let filename = avatarOrCover + mimetype["ext"]!;
        body.appendData("\r\n--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!);
        body.appendData("Content-Disposition: form-data; name=\"test\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!);
        body.appendData("Hello World".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        body.appendData("\r\n--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!);
        body.appendData("Content-Disposition: form-data; name=\"\(avatarOrCover)\"; filename=\"\(filename)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Type: application/octet-stream\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(data!)
        body.appendData("\r\n--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        return body
    }
    
    /// Create boundary string for multipart/form-data request
    ///
    /// :returns:            The boundary string that consists of "Boundary-" followed by a UUID string.
    
    func generateBoundaryString() -> String {
        return "---------------------------14737809831466499882746641449";
    }
    
    func contentTypeForImageData(data: NSData) -> [String: String] {
            return ["mime":"image/jpg","ext":".jpg"];
    }
    
    func saveAvatar(avatar : UIImage, completionHandler closure: ((root: NSDictionary) -> Void)?) {
        let session = NSURLSession.sharedSession();
        let request = createAvatarRequest(avatar);
        print("[WSM] posting avatar to server")
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            var root = NSDictionary()
            if data != nil && data!.length > 0 {
                if let e = error {
                    print("[WSM] error: \(e)")
                } else {
                    do {
                        let r = try NSJSONSerialization.JSONObjectWithData(data!, options:[]) as! [NSObject: AnyObject]
                        self.postCookies(response!);
                        root = r as NSDictionary;
                    } catch let parseError {
                        let s = NSString(data: data!, encoding: NSUTF8StringEncoding);
                        print("[WSM] - UNABLE TO PARSE JSON: \(s)");
                        print(parseError);
                    }
                    print("[WSM] - ROOT \(root)");
                }
            } else {
                if(data != nil){
                    let s = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("[WSM] Response: \(s)");
                }
                if let e = error {
                    print("[WSM] failed to get main data back from POST. Error: \(e)")
                } else {
                    print("[WSM] no data back from POST")
                }
            }
            session.finishTasksAndInvalidate()
            if let closure = closure {
                closure(root: root)
            }
        })
        task.resume()
    }
    func updateUserPassword(password: String, completionHandler closure: (success: Bool, message: String?) -> Void)  {
        if let url = NSURL(string: updateUserPasswordURL) {
            let p = EMNUtils.encodeString(password);
            self.editUserTask = postDataInURL(url, queryString: "password="+p, setCookies: true, completionHandler: { (root) -> Void in
                var success = false
                var message: String?
                if let status = root["status"] as? Int where status == 1 {
                    success = true
                } else {
                    message = root["message"] as? String
                    print("[WSM] failed to edit user: \(message)")
                }
                closure(success: success, message: message)
            });
            self.editUserTask.resume();
        } else {
            closure(success: false, message: failedURLMessage)
        }
    }
    func saveCover(cover : UIImage, completionHandler closure: ((root: NSDictionary) -> Void)?) {
        let session = NSURLSession.sharedSession();
        let request = createCoverRequest(cover);
        print("[WSM] posting cover to server")
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            var root = NSDictionary()
            if data != nil && data!.length > 0 {
                if let e = error {
                    print("[WSM] error: \(e)")
                } else {
                    do {
                        let r = try NSJSONSerialization.JSONObjectWithData(data!, options:[]) as! [NSObject: AnyObject]
                        self.postCookies(response!);
                        root = r as NSDictionary;
                    } catch let parseError {
                        let s = NSString(data: data!, encoding: NSUTF8StringEncoding);
                        print("[WSM] - UNABLE TO PARSE JSON: \(s)");
                        print(parseError);
                    }
                    print("[WSM] - ROOT \(root)");
                }
            } else {
                if(data != nil){
                    let s = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("[WSM] Response: \(s)");
                }
                if let e = error {
                    print("[WSM] failed to get main data back from POST. Error: \(e)")
                } else {
                    print("[WSM] no data back from POST")
                }
            }
            session.finishTasksAndInvalidate()
            if let closure = closure {
                closure(root: root)
            }
        })
        task.resume()
    }

}
//extension WebserviceManager : NSURLSessionDelegate {
//    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
//        NSLog("downloaded.")
//    }
//}