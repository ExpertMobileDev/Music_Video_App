//
//  EdgeOOPlayer.h
//  emn
//
//  Created by Jason Cox on 11/19/15.
//  Copyright © 2015 Angel Jonathan GM. All rights reserved.
//

#import <OoyalaSDK/OOOoyalaPlayer.h>

@interface EdgeOOPlayer : OOOoyalaPlayer
@property(nonatomic, retain) NSArray *playlist;
@property(assign) int playlistIndex;
@property(assign) bool settingNewPlaylist;
@end
