//
//  OOInlineIOS7ViewController.m
//  OoyalaSDK
//
// Copyright (c) 2015 Ooyala, Inc. All rights reserved.
//

#import "InlineIOS7ViewController.h"
#import "InlineIOS7ControlsView.h"

#import <OoyalaSDK/OOUIProgressSliderIOS7.h>
#import <OoyalaSDK/OOVideo.h>
#import "UIUtils.h"
#import <OoyalaSDK/OODebugMode.h>
#import <OoyalaSDK/OOOptions.h>

#import "EdgeOOPlayer.h"

@interface InlineIOS7ViewController() {
  BOOL wasPlaying;
  BOOL seeking;
  CGFloat bottomBarHeight;
}

@property (nonatomic) InlineIOS7ControlsView *controls;
@end

@implementation InlineIOS7ViewController

@dynamic controls;


- (void)viewDidLoad {
  if (self.player == nil) {
//    LOG(@"viewDidLoad while player is nil");
    return;
  }
  
  self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
  
  //add controls
  self.controls = [[InlineIOS7ControlsView alloc] initWithFrame:self.view.bounds];

  [self initializeCoreControls];

  [self initializeFullscreenControls];

  [self initializeInlineControls];

  [super viewDidLoad];
}

- (void) initializeCoreControls {
  self.controls.playButton.target = self.player;
//    [self.controls.playButton ]

  self.controls.closedCaptionsButton.target = self.delegate;
  self.controls.closedCaptionsButton.action = @selector(closedCaptionsSelector);
  
//  self.controls.fullscreenButton.target = self.delegate;
//  self.controls.fullscreenButton.action = @selector(showFullscreen);
   

    
    [self.controls.customFullScreenBtn addTarget:self.delegate action:@selector(showFullscreen) forControlEvents:UIControlEventTouchUpInside];
    
    self.controls.nextButton.target = self.player;
    self.controls.nextButton.action = @selector(nextVideo);
    
    self.controls.previousButton.target = self.player;
    self.controls.previousButton.action = @selector(previousVideo);
    
    self.controls.timeLabel.text  = [NSString stringWithFormat:@"%.2f",self.controls.scrubberSlider.duration];
    //self.controls.timeLabel.text  = [NSString stringWithFormat:@"%.2f",self.controls.scrubberSlider.duration];
  [self.controls.scrubberSlider.scrubber addTarget:self action:@selector(onScrubbingStarted) forControlEvents:UIControlEventTouchDown];
  [self.controls.scrubberSlider.scrubber addTarget:self action:@selector(onScrubbingChanged) forControlEvents:UIControlEventValueChanged];
  [self.controls.scrubberSlider.scrubber addTarget:self action:@selector(onScrubbingEnded) forControlEvents:UIControlEventTouchUpInside];
  [self.controls.scrubberSlider.scrubber addTarget:self action:@selector(onScrubbingEnded) forControlEvents:UIControlEventTouchUpOutside];

  [super viewDidLoad];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAdsLoaded:) name:OOOoyalaPlayerAdsLoadedNotification object:self.player];
}

-(void)onAdsLoaded:(NSNotification*)notification {
  // delay to avoid crashing in the stack of handling the first notification.
  dispatch_async( dispatch_get_main_queue(), ^{
    [self syncUI];
  });
}

- (void) initializeFullscreenControls {
  self.controls.doneButton.target = self.delegate;
  self.controls.doneButton.action = @selector(onFullscreenDoneButtonClick);

  self.controls.videoGravityFillButton.target = self.delegate;
  self.controls.videoGravityFillButton.action = @selector(switchVideoGravity);

  self.controls.videoGravityFitButton.target = self.delegate;
  self.controls.videoGravityFitButton.action = @selector(switchVideoGravity);
}

- (void)initializeInlineControls {
  self.controls.fullscreenButton.target = self.delegate;
  self.controls.fullscreenButton.action = @selector(showFullscreen);
}

- (void)onScrubbingStarted {
  if (self.player == nil) {
    LOG(@"onScrubbingStarted while player is nil");
    return;
  }

  seeking = YES;
}

- (void)onScrubbingChanged {
  if (self.player == nil) {
    LOG(@"onScrubbingChanged while player is nil");
    return;
  }
  if (self.player.seekStyle == OOSeekStyleEnhanced) {
    [self.player seek:self.controls.scrubberSlider.scrubberAbsoluteValue];
  }
}

- (void)onScrubbingEnded {
  if (self.player == nil) {
    LOG(@"onScrubbingEnded while player is nil");
    return;
  }
  if (self.player.seekStyle != OOSeekStyleEnhanced) {
    [self.player seek:self.controls.scrubberSlider.scrubberAbsoluteValue];
  }
  
  seeking = NO;

  [self syncUI];
}

- (void)syncUI {
  [super syncUI];

  if (self.player == nil) {
    LOG(@"syncUI while player is nil");
    return;
  }

  if (!self.controls)
    return;
  
  //Hiding until we have UX to support it
  //Closed Captions button
  [self updateClosedCaptionsButton];

  // Handle LIVE streams
  self.controls.scrubberSlider.mode = [super sliderMode];
  
  //Handle time
  if (seeking == NO) {
    self.controls.scrubberSlider.duration = self.player.duration;
    self.controls.scrubberSlider.currentTime = self.player.playheadTime;
      
      
    self.controls.scrubberSlider.currentAvailableTime = self.player.bufferedTime;
    self.controls.scrubberSlider.seekableTimeRange = [self.player seekableTimeRange];
    [self.controls.scrubberSlider updateTimeDisplay];
  }
  
  //Handle state
  [self.controls setIsPlayShowing:!self.player.isPlaying];

  if (self.player.isPlaying) {

    if ([self showingAdsWithHiddenControls]) {
      [self hideControls];
    } else if (self.controls.playButton.isPlayShowing) {
      [self.controls.playButton setIsPlayShowing:NO];
      if (self.controls.hidden == NO) {
        [self showControls];
        if (self.hideControlsTimer != nil) {
          [self.hideControlsTimer invalidate];
          self.hideControlsTimer = nil;
        }
      }
    }
  } else if (!self.controls.playButton.isPlayShowing) {
      [self.controls.playButton setIsPlayShowing:YES];
      if (self.controls.hidden == NO) {
        [self showControls];
        if (self.hideControlsTimer != nil) {
          [self.hideControlsTimer invalidate];
          self.hideControlsTimer = nil;
        }
    }
  }

  self.controls.scrubberSlider.scrubber.userInteractionEnabled = self.player.seekable;

  if ((self.player.state == OOOoyalaPlayerStateLoading) && seeking == NO)
    [self.activityView startAnimating];
  else
    [self.activityView stopAnimating];

  self.controls.scrubberSlider.cuePointsAtSeconds = [self.player getCuePointsAtSecondsForCurrentPlayer];
}

- (void) setFullScreenButtonShowing: (BOOL) isShowing {
  [self.controls setFullscreenButtonShowing:isShowing];
}

- (void)hideControls {
  if (self.player == nil) {
    LOG(@"hideControls while player is nil");
    return;
  }

  if (self.hideControlsTimer != nil) {
    [self.hideControlsTimer invalidate];
    self.hideControlsTimer = nil;
  }
  if (self.controls == nil) return;

  [UIView animateWithDuration:0.37
                   animations: ^ {
                     [self.controls hide];
                     if (self.overlay) [self.overlay setAlpha:0];
                     [self setNeedsStatusBarAppearanceUpdate];
                   }
                   completion: ^ (BOOL finished) {
                     if (self.overlay) self.overlay.hidden = YES;
                   }];
  self.controls.hidden = YES;
  [self updateClosedCaptionsPosition];
}

- (void)showControls {
  if (self.player == nil || [self showingAdsWithHiddenControls]) {
    LOG(@"showControls while player is nil");
    return;
  }
  if (!self.isVisible) return;
  if (self.hideControlsTimer != nil) {
    [self.hideControlsTimer invalidate];
    self.hideControlsTimer = nil;
  }
  if (self.controls == nil) return;

  self.controls.hidden = NO;
  if (self.overlay) self.overlay.hidden = NO;
  if (self.player.isPlaying)
    self.hideControlsTimer = [NSTimer scheduledTimerWithTimeInterval:CONTROLS_HIDE_TIMEOUT target:self selector:@selector(hideControls) userInfo:nil repeats:NO];

  [UIView animateWithDuration:0.37
                   animations: ^ {
                     [self.controls show];
                     if (self.overlay) [self.overlay setAlpha:1];
                     [self setNeedsStatusBarAppearanceUpdate];
                   }
                   completion: NULL];
	[self updateClosedCaptionsPosition];
}

- (void)changeButtonLanguage:(NSString*)language {
  // Implement this method when inline button's language need to be changed with closed caption
}

- (void)viewDidAppear:(BOOL)animated {
  [self updateClosedCaptionsPosition];
  [[NSNotificationCenter defaultCenter] postNotificationName:PlayerViewControllerInlineViewVisible object:self];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  [self updateClosedCaptionsPosition];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  [self.delegate didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)updateBottomHeight {
  if (self.player == nil) {
    LOG(@"updateBottomHeight while player is nil");
    return;
  }
  if (!self.controls.hidden) {
		// Check if the bottom bar will overlap with closed captions
  	CGRect videoRect = [self.player videoRect];
    if (self.controls.navigationBar.frame.origin.y < videoRect.origin.y + videoRect.size.height) {
      bottomBarHeight = self.controls.navigationBar.frame.size.height;
    } else {
			bottomBarHeight = 0;
    }
  } else {
  	bottomBarHeight = 0;
  }
}

- (BOOL)showingAdsWithHiddenControls {
  return (self.player.isShowingAd && !self.player.options.showAdsControls);
}

- (void)updateClosedCaptionsPosition {
  if (self.player == nil) {
    LOG(@"updateClosedCaptionsPosition while player is nil");
    return;
  }
  if ([self.delegate isKindOfClass:[PlayerViewController class]]) {
    PlayerViewController *controller = self.delegate;
    [controller updateClosedCaptionsViewPosition:self.controls.navigationBar.frame withControlsHide:self.controls.hidden];
  }
}

- (void)dealloc {
  if (self.hideControlsTimer != nil) {
    [self.hideControlsTimer invalidate];
    self.hideControlsTimer = nil;
  }
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)changeTimerForVideo{
   
    int seconds = fmod(self.controls.scrubberSlider.currentTime, 60.0);
    int minutes = fmod(trunc(self.controls.scrubberSlider.currentTime / 60.0), 60.0);
     if (seconds > 59)
      self.controls.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes+1, 0];
    else
      self.controls.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    
    //NSLog(@"%@",self.controls.timeLabel.text);
  
}
/*
 -(void)setProgressBarFrame:(CGFloat)y{
 CGRect rect = CGRectMake(0, self.controls.navigationBar.frame.origin.y+ self.controls.navigationBar.frame.size.height , self.view.frame.size.width, 10);
 self.controls.progressView.layer.frame = CGRectMake(0, y-5, self.view.frame.size.width, 5);
 }*/
-(void)bringFullScreenButtonToFront{
    [self.controls bringSubviewToFront:self.controls.customFullScreenBtn];
}
@end