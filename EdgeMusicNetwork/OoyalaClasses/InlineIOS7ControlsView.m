//
//  OOInlineIOS7ControlsView.m
//  OoyalaSDK
//
// Copyright (c) 2015 Ooyala, Inc. All rights reserved.
//

#import "InlineIOS7ControlsView.h"
#import "ImagesIOS7.h"
#import "UIUtils.h"
#import <OoyalaSDK/OOTransparentToolbar.h>
#import <OoyalaSDK/iOS7ScrubberSliderFraming.h>
@interface InlineIOS7ControlsView() {
}

@property (nonatomic) CGFloat playpauseScale;
@property (nonatomic) CGFloat ccScale;
@property (nonatomic) CGFloat fullscreenScale;

@property (nonatomic) UIBarButtonItem *fixedSpace;
@property (nonatomic) UIBarButtonItem *flexibleSpace;
@end

@implementation InlineIOS7ControlsView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        // Setup all the constant for inline controls
        CGFloat width = self.bounds.size.width;
        CGRect navigationBarRect;
        if ([UIUtils isIpad]) {
            navigationBarRect = CGRectMake(0, self.bounds.size.height - 50, width, 50);
            _playpauseScale = 2.0;
            _ccScale = 3.0;
            _fullscreenScale = 4.0;
        } else {
            navigationBarRect = CGRectMake(0, self.bounds.size.height - 40, width, 40);
            _playpauseScale = 2.0;
            _ccScale = 4;
            _fullscreenScale = 5.5;
        }
        
        _fullscreenButtonShowing = YES;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        // Create control bar
        self.navigationBar = [[OOTransparentToolbar alloc] initWithFrame:navigationBarRect];
        self.navigationBar.translucent= YES;
        self.navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        _navigationBar.tintColor = [UIColor whiteColor];
        _navigationBar.backgroundColor= [UIColor blackColor];
        
        _fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        
        _flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        //InitializeButtons
        
        _playButton = [[OOPlayPauseButton alloc] initWithScale:2];
        
        _closedCaptionsButton = [[OOClosedCaptionsButton alloc] initWithScale:2.0];
        
        _nextButton = [[UIBarButtonItem alloc]
                       initWithImage:[UIImage imageWithCGImage:[[ImagesIOS7 forwardImage] CGImage]
                                                         scale:2 orientation:UIImageOrientationUp]
                       style:UIBarButtonItemStylePlain
                       target:nil action:nil];
        
        _previousButton = [[UIBarButtonItem alloc]
                           initWithImage:[UIImage imageWithCGImage:[[ImagesIOS7 rewindImage] CGImage]
                                                             scale:2 orientation:UIImageOrientationUp]
                           style:UIBarButtonItemStylePlain
                           target:nil action:nil];
        
        _fullscreenButton= [[OOFullscreenButton alloc] initWithScale:2];
        
        _customFullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_customFullScreenBtn setImage:[ImagesIOS7 expandImage] forState:UIControlStateNormal];
        _customFullScreenBtn.frame = CGRectMake(frame.size.width - 50, 5, 50, 50);
        
        _scrubberSlider = [[OOUIProgressSliderIOS7 alloc] initWithFrame:[self calculateScrubberSliderFrame]];
        _scrubberSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0 , 0, 44.5f, 21.0f)];
        [self.timeLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
        [self.timeLabel setBackgroundColor:[UIColor clearColor]];
        [self.timeLabel setTextColor:[UIColor whiteColor]];
        [self.timeLabel setText:@"0:00"];
        [self.timeLabel setTextAlignment:NSTextAlignmentCenter];
        
        
        _timeBarBtn = [[UIBarButtonItem alloc] initWithCustomView:self.timeLabel];
        
        _slider = [[UIBarButtonItem alloc] initWithCustomView:_scrubberSlider];
        
        [self updateNavigationBar];
        [self addSubview:_navigationBar];
        [self addSubview:_customFullScreenBtn];
    
        [self bringSubviewToFront:_customFullScreenBtn];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}


/**
 * Update navbar when someting is added or removed
 */
- (void) updateNavigationBar{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    //  [items addObject:_flexibleSpace];
    [items addObject:_timeBarBtn];
    [items addObject:_flexibleSpace];
    [items addObject:_previousButton];
    [items addObject:_flexibleSpace];
    [items addObject:_playButton];
    [items addObject:_flexibleSpace];
    [items addObject:_nextButton];
    [items addObject:_flexibleSpace];
    //  [items addObject:_slider];
    
    if (_closedCaptionsButtonShowing) {
        [items addObject:_closedCaptionsButton];
    }
    //  [items addObject:_flexibleSpace];
    //
    //
    //  if (_fullscreenButtonShowing) {
    //    [items addObject:_fullscreenButton];
    //  }
    //
    //  [items addObject:_flexibleSpace];
    
    [_navigationBar setItems:items animated:YES];
    _slider.customView.frame = [self calculateScrubberSliderFrame];
    
    [self setNeedsLayout];
}

/**
 * Called when the navbar is updated, and after the views need to be layed out (layoutSubviews)
 */
-(CGRect)calculateScrubberSliderFrame {
    NSMutableArray *buttonList = [[NSMutableArray alloc] init];
    buttonList = [NSMutableArray arrayWithArray:_navigationBar.items];
    [buttonList removeObject:_slider];
    return [iOS7ScrubberSliderFraming
            calculateScrubberSliderFramewithButtons: buttonList
            baseWidth:_navigationBar.bounds.size.width];
}

- (void)setIsPlayShowing:(BOOL)showing {
    [_playButton setIsPlayShowing:showing];
}

- (void)setFullscreenButtonShowing:(BOOL)showing {
    if(_fullscreenButtonShowing == showing) return;
    _fullscreenButtonShowing = showing;
    [self updateNavigationBar];
}

- (void)setClosedCaptionsButtonShowing:(BOOL)showing {
    if(_closedCaptionsButtonShowing == showing) return;
    _closedCaptionsButtonShowing = showing;
    [self updateNavigationBar];
}

- (void)hide {
  if (self.hideControlsTimer != nil) [self.hideControlsTimer invalidate];
    _navigationBar.alpha = 0;
}

- (void)show {
    
        self.hideControlsTimer = [NSTimer scheduledTimerWithTimeInterval:CONTROLS_HIDE_TIMEOUT target:self selector:@selector(hide) userInfo:nil repeats:NO];
    
    _navigationBar.alpha = 1;
    
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *view in self.subviews) {
        if (CGRectContainsPoint(view.frame, point)) {
            return YES;
        }
    }
    return NO;
}

- (void)changeDoneButtonLanguage:(NSString*)language {
    // Implement this method when inline button's language need to be changed with closed caption
}
@end
