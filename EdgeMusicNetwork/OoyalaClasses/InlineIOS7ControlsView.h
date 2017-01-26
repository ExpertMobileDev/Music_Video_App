//
//  OOInlineIOS7ControlsView.h
//  OoyalaSDK
//
// Copyright (c) 2015 Ooyala, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <OoyalaSDK/OOPlayPauseButton.h>
#import <OoyalaSDK/OOClosedCaptionsButton.h>
#import <OoyalaSDK/OOFullscreenButton.h>
#import <OoyalaSDK/OOUIProgressSliderIOS7.h>

static const double CONTROLS_HIDE_TIMEOUT = 5.37;

@interface InlineIOS7ControlsView : UIView



//Navigation Bar
@property (nonatomic) UIToolbar *navigationBar;
@property (nonatomic) UIBarButtonItem *doneButton;
@property (nonatomic) UIBarButtonItem *slider;
@property (nonatomic) OOUIProgressSliderIOS7 *scrubberSlider;
@property (nonatomic) OOFullscreenButton *fullscreenButton;
@property (nonatomic) OOClosedCaptionsButton *closedCaptionsButton;
@property (nonatomic) UIBarButtonItem *videoGravityFillButton;
@property (nonatomic) UIBarButtonItem *videoGravityFitButton;

@property (nonatomic)   UIBarButtonItem *timeBarBtn;
@property(nonatomic)   UILabel* timeLabel;
@property(nonatomic) UIProgressView *progressView;

@property(nonatomic) UIButton * customFullScreenBtn;

@property (nonatomic) UIBarButtonItem *nextButton;
@property (nonatomic) UIBarButtonItem *previousButton;
@property(nonatomic) UIView *customView;

@property (nonatomic) UIToolbar *bottomBarBackground;
@property (nonatomic) OOPlayPauseButton *playButton;
@property (nonatomic) MPVolumeView *volumeButton;
@property (nonatomic) MPVolumeView *airPlayButton;

@property (nonatomic) BOOL fullscreenButtonShowing;
@property (nonatomic) BOOL showsAirPlayButton;
@property (nonatomic) BOOL gravityFillButtonShowing;
@property (nonatomic) BOOL closedCaptionsButtonShowing;

@property (nonatomic) NSTimer *hideControlsTimer;

- (void)setIsPlayShowing:(BOOL)showing;

- (void)hide;
- (void)show;
- (void)changeDoneButtonLanguage:(NSString*)language;

//-(void)changeTimer:(NSString *)timer;
@end
