//
//  OOFullScreenIOS7ViewControlerViewController.h
//  OoyalaSDK
//
// Copyright (c) 2015 Ooyala, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ControlsViewController.h"

@protocol FullscreenProtocol <NSObject>
@required
-(void)removingFullScreen;

@end

@interface FullScreenIOS7ViewController : ControlsViewController
@property(nonatomic, weak) id<FullscreenProtocol> doneDelegate;
@end

