//
//  EdgeOOPlayer.m
//  emn
//
//  Created by Jason Cox on 11/19/15.
//  Copyright © 2015 Angel Jonathan GM. All rights reserved.
//  NO ADS SET: 632d6b243d554e35b373da1dca2fafc3
// GIMA AD SET: 21e06d195d5147d4b16b55fdacdda2a4

#import "EdgeOOPlayer.h"
#import "emn-Swift.h"
#define kUserAdSet @"632d6b243d554e35b373da1dca2fafc3"
#define kTrialAdSet @"21e06d195d5147d4b16b55fdacdda2a4"

@implementation EdgeOOPlayer

- (void)play;
{
    if(self.settingNewPlaylist == YES){
        self.settingNewPlaylist = NO;
        if([[[Singleton sharedInstance] user] subscriber] == YES){
            [super setEmbedCode:[[self playlist] objectAtIndex:self.playlistIndex] adSetCode:kUserAdSet];
        }else{
            //[super setEmbedCode:[[self playlist] objectAtIndex:self.playlistIndex]];
            [super setEmbedCode:[[self playlist] objectAtIndex:self.playlistIndex] adSetCode:kTrialAdSet];
        }
    }
    [super play];
}

/**
 * Tries to set the current video to the next video in the OOChannel or ChannetSet
 * @returns a BOOL indicating that the item was successfully changed
 */
- (BOOL)nextVideo;
{
    if(self.playlist.count > self.playlistIndex+1){
        self.playlistIndex++;
    }
    bool ret = YES;
    if([[[Singleton sharedInstance] user] subscriber]){
        ret = [super setEmbedCode:[[self playlist] objectAtIndex:self.playlistIndex] adSetCode:kUserAdSet];
    }else{
        ret = [super setEmbedCode:[[self playlist] objectAtIndex:self.playlistIndex] adSetCode:kTrialAdSet];
    }
    [super play];
    return ret;
}

/**
 * Tries to set the current video to the previous video in the OOChannel or ChannetSet
 * @returns a BOOL indicating that the item was successfully changed
 */
- (BOOL)previousVideo;
{
    if(self.playlistIndex > 0){
        self.playlistIndex--;
    }
    bool ret = YES;
    if([[[Singleton sharedInstance] user] subscriber]){
        ret = [super setEmbedCode:[[self playlist] objectAtIndex:self.playlistIndex] adSetCode:kUserAdSet];
    }else{
        ret = [super setEmbedCode:[[self playlist] objectAtIndex:self.playlistIndex] adSetCode:kTrialAdSet];
    }
    [super play];
    return ret;
}

@end
