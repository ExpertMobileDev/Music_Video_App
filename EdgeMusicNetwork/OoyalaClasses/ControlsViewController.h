/**
 * @class      OOControlsViewController OOControlsViewController.h "OOControlsViewController.h"
 * @brief      OOControlsViewController
 * @details    OOControlsViewController.h in OoyalaSDK
 * @date       2/23/12
 * @copyright Copyright (c) 2015 Ooyala, Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "InlineIOS7ControlsView.h"
#import "PlayerViewController.h"

@class EdgeOOPlayer;

@interface ControlsViewController : UIViewController

@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) EdgeOOPlayer *player;
@property (nonatomic, weak) UIView *overlay;
@property (nonatomic) UIActivityIndicatorView *activityView;
@property (nonatomic) InlineIOS7ControlsView *controls;
@property (nonatomic) bool isVisible;
@property (nonatomic) NSTimer *hideControlsTimer;

- (id) initWithControlsType:(OOOoyalaPlayerControlType)controlsType player:(EdgeOOPlayer *)player  overlay:(UIView *) overlay delegate:(id)delegate;

- (void)showControls;
- (void)hideControls;
- (void)syncUI;


//Hide and show the full screen button on the inline view
- (void)setFullScreenButtonShowing: (BOOL) isShowing;

- (OOUIProgressSliderMode) sliderMode;

// Change the language of controls when close caption changed
- (void)changeButtonLanguage:(NSString*)language;

// Switch the gravity for full screen mode.
- (void)switchVideoGravity;

- (void)updateClosedCaptionsPosition;

// calculate and set visibility of CC button.
- (void)updateClosedCaptionsButton;

// toggle the control buttons.
- (void)toggleControls;

@end
