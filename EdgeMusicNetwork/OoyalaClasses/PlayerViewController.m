/**
 * @file       OOOoyalaPlayerViewController.m
 * @brief      Implementation of OOOoyalaPlayerViewController
 * @details    OOOoyalaPlayerViewController.m in OoyalaSDK
 * @date       1/9/12
 * @copyright Copyright (c) 2015 Ooyala, Inc. All rights reserved.
 */
#import "PlayerViewController.h"
#import <OoyalaSDK/OOClosedCaptionsSelectorBackgroundViewController.h>
#import "FullScreenIOS7ViewController.h"
#import "InlineIOS7ViewController.h"
#import "FullscreenIOS7ViewController.h"
#import <OoyalaSDK/OOClosedCaptionsSelectorViewController.h>
#import <OoyalaSDK/OOOoyalaAPIClient.h>
#import <OoyalaSDK/OOPlayerDomain.h>
#import <OoyalaSDK/OODebugMode.h>
#import <OoyalaSDK/OOClosedCaptionsView.h>
#import <OoyalaSDK/OOVideo.h>
#import <OoyalaSDK/OOCaption.h>
#import <OoyalaSDK/OOClosedCaptions.h>
//#import <OoyalaSDK/OOOoyalaPlayer+Internal.h>
#import "EdgeOOPlayer.h"

NSString *const EMNTAG = @"PlayerViewController";
NSString *const PlayerViewControllerFullscreenEnter = @"fullscreenEnter";
NSString *const PlayerViewControllerFullscreenExit = @"fullscreenExit";
NSString *const PlayerViewControllerDoneClicked = @"doneClicked";
NSString *const PlayerViewControllerInlineViewVisible = @"fullscreenViewVisible";
NSString *const PlayerViewControllerFullscreenViewVisible = @"inlineViewVisible";

@interface PlayerViewController() {
  BOOL initialLoad;
  UIView* _inlineOverlay;
  UIView* _fullscreenOverlay;
  BOOL fullscreenQueued;
@private
  BOOL isClosedCaptionsEnabled;
  BOOL isFullScreenButtonShowing;
  OOClosedCaptionsStyle *_closedCaptionsStyle;
}

@property (nonatomic, strong) ControlsViewController *fullScreenViewController;
@property (nonatomic, strong) ControlsViewController *inlineViewController;
@property (nonatomic, strong) NSDictionary *defaultLocales;
@property (nonatomic, strong) NSDictionary *currentLocale;
@property (nonatomic, strong) OOClosedCaptionsSelectorViewController *selectorViewController;
@property(nonatomic, strong) OOClosedCaptionsView *closedCaptionsView;

- (void)loadInline;
- (void)loadFullscreen;
- (void)unloadInline;
- (void)unloadFullscreen;
- (void)showFullscreen;
- (void)onFullscreenDoneButtonClick;
- (void)determineControlType;
- (ControlsViewController *)fullscreenViewControllerInstance;
- (ControlsViewController *)inlineViewControllerInstance;
@end

@implementation PlayerViewController

static NSDictionary *defaultLocales = nil;
static NSDictionary *currentLocale = nil;

@synthesize player, initialControlType, fullScreenViewController, inlineViewController;
@synthesize defaultLocales, currentLocale;
@synthesize selectorViewController;

- (id)initWithPlayer:(EdgeOOPlayer *)_player {
  return [self initWithPlayer:_player controlType:OOOoyalaPlayerControlTypeInline];
}

- (id)initWithPlayer:(EdgeOOPlayer *)_player controlType:(OOOoyalaPlayerControlType)_controlType {
  self = [super init];
  if (self) {
    player = _player;
    initialLoad = YES;

    [OODebugMode assert:self.initialControlType == OOOoyalaPlayerControlTypeInline || self.initialControlType == OOOoyalaPlayerControlTypeFullScreen tag:EMNTAG message:[NSString stringWithFormat:@"unexpected: %ld", (long)self.initialControlType]];
    initialControlType = _controlType;
    fullscreenQueued = initialControlType == OOOoyalaPlayerControlTypeFullScreen ? YES : NO;

    //Initialize CC Selector and popup helper
    selectorViewController = [[OOClosedCaptionsSelectorViewController alloc] initWithViewController:self];
    isFullScreenButtonShowing = YES;
    // Set Closed Caption style
    _closedCaptionsStyle = [OOClosedCaptionsStyle new];
    //listen to UIApplicationDidEnterBackgroundNotification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onApplicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onPlayheadUpdated:)
                                                 name:OOOoyalaPlayerTimeChangedNotification
                                               object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onStateChanged:)
                                                 name:OOOoyalaPlayerStateChangedNotification
                                               object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAdStarted:)
                                                 name:OOOoyalaPlayerAdStartedNotification
                                               object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAdTapped:)
                                                 name:OOOoyalaPlayerAdTappedNotification
                                               object:player];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onClosedCaptionLanguageChanged:)
                                                 name:OOOoyalaPlayerLanguageChangedNotification
                                               object:player];

  }

  return self;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

  if (fullscreenQueued) {
    [self loadFullscreen];
    [self setFullscreen:true];
  } else {
    [self loadInline];
    [self setFullscreen:false];
  }
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
}

- (void)loadFullscreen {
  if (!fullScreenViewController) {
    fullScreenViewController = [[FullScreenIOS7ViewController alloc] initWithControlsType:OOOoyalaPlayerControlTypeFullScreen player:self.player overlay:_fullscreenOverlay delegate:self];
  }

  [self presentViewController:fullScreenViewController animated:NO completion:^(void) {
    if( [self.player isShowingAdWithCustomControls] ) {
      [fullScreenViewController hideControls];
      [fullScreenViewController setIsVisible:NO];
    }
    else {
      [fullScreenViewController showControls];
      [fullScreenViewController setIsVisible:YES];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:PlayerViewControllerFullscreenEnter object:self];
  }];
}

- (void)loadInline {
  if (!inlineViewController) {
    inlineViewController = [[InlineIOS7ViewController alloc] initWithControlsType:OOOoyalaPlayerControlTypeInline player:self.player overlay:_inlineOverlay delegate:self];
  }

  inlineViewController.view.frame = self.view.bounds;

  [self addChildViewController:inlineViewController];
  [self.view addSubview:inlineViewController.view];
  if( [self.player isShowingAdWithCustomControls] ) {
    [inlineViewController hideControls];
    [inlineViewController setIsVisible:NO];
  }
  else {
    [inlineViewController showControls];
    [inlineViewController setIsVisible:YES];
  }

  [player setVideoGravity:OOOoyalaPlayerVideoGravityResizeAspect];  // make sure video is normal gravity

  //If we tried to hide the fullscreen button before, make sure it's hidden now
  if (isFullScreenButtonShowing == NO) {
    [inlineViewController setFullScreenButtonShowing:isFullScreenButtonShowing ];
  }
}

- (void) unloadFullscreen {
  fullscreenQueued = NO;
  if (self.isFullscreen) {
    [self dismissViewControllerAnimated:NO completion:^(void) {
      [[NSNotificationCenter defaultCenter] postNotificationName:OOOoyalaPlayerViewControllerFullscreenExit object:self];
    }];
  }
}

- (void) unloadInline {
  [inlineViewController removeFromParentViewController];
  [inlineViewController.view removeFromSuperview];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  initialLoad = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (BOOL)isFullscreen {
  return
    self.fullScreenViewController != nil &&
    self.fullScreenViewController == self.presentedViewController;
}

- (void)setFullscreen:(BOOL)fullscreen {
    if (self.isFullscreen)
    {
      if (!fullscreen) { // exiting full screen
        [self unloadFullscreen];
      }
    }
    else {
      if (fullscreen) {
        [self unloadInline];
        [self loadFullscreen];
      } else {
        [self unloadFullscreen];
        [self loadInline];
      }
    }
}

- (void)stateChanged:(NSNotification*)notification {
  //viewWillAppear is not fired in 4.3.  Assume that it happens after first state change event.
  initialLoad = NO;
  [self viewDidAppear:NO];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:OOOoyalaPlayerStateChangedNotification object:player];
}

- (void)showFullscreen {
  [self setFullscreen:YES];
}

- (void)onFullscreenDoneButtonClick {
  [[NSNotificationCenter defaultCenter] postNotificationName:PlayerViewControllerDoneClicked object:self];
  [self setFullscreen:NO];
}

- (void)setFullScreenButtonShowing:(BOOL) showing {
    isFullScreenButtonShowing = showing;
    [inlineViewController setFullScreenButtonShowing: showing];
}

- (ControlsViewController *)getControls {
  if (self.isFullscreen)
    return fullScreenViewController;
  else
    return inlineViewController;
}

- (void)showControls {
  if (self.isFullscreen)
    [fullScreenViewController showControls];
  else
    [inlineViewController showControls];
}

- (void)hideControls {
  if (self.isFullscreen)
    [fullScreenViewController hideControls];
  else
    [inlineViewController hideControls];
}

- (void)switchVideoGravity {
  if(player.videoGravity == OOOoyalaPlayerVideoGravityResizeAspect) {
    [player setVideoGravity:OOOoyalaPlayerVideoGravityResizeAspectFill];
  } else {
    [player setVideoGravity:OOOoyalaPlayerVideoGravityResizeAspect];
  }

  if (self.isFullscreen) {
    [fullScreenViewController syncUI];
    [fullScreenViewController switchVideoGravity];
  }
}

  // This should be called by the UI when the closed captions button is clicked
- (void) closedCaptionsSelector {
  OOClosedCaptionsSelectorBackgroundViewController* backgroundViewController = [[OOClosedCaptionsSelectorBackgroundViewController alloc] initWithSelectorView:selectorViewController];
  if (self.isFullscreen) {
    [self.presentedViewController presentViewController:backgroundViewController animated:YES completion:nil];
  } else {
    [self.inlineViewController presentViewController:backgroundViewController animated:YES completion:nil];
  }
}

- (void)determineControlType {
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    initialControlType = OOOoyalaPlayerControlTypeFullScreen;
  } else {
    initialControlType = OOOoyalaPlayerControlTypeInline;
  }
  //disable this logic for now
//  controlType = OOOoyalaPlayerControlTypeInline;
}

- (UIView *)inlineOverlay {
  return _inlineOverlay;
}

- (void) setInlineOverlay:(UIView *)_overlay {
  _inlineOverlay = _overlay;
  if(inlineViewController) {
    inlineViewController.overlay = _inlineOverlay;
  }
}

- (UIView *)fullscreenOverlay {
  return _fullscreenOverlay;
}

- (void) setFullscreenOverlay:(UIView *)_overlay {
  _fullscreenOverlay = _overlay;
  if(fullScreenViewController) {
    fullScreenViewController.overlay = _fullscreenOverlay;
  }
}

- (void) setFullScreenViewController:(ControlsViewController *)controller {
  fullScreenViewController = controller;
}

- (void) setInlineViewController:(ControlsViewController *)controller {
  inlineViewController = controller;
}

- (void)changeLanguage: (NSString *)language {
  if(!defaultLocales) {
    [PlayerViewController loadDefaultLocale];
  }

  if (language == nil) {
    [PlayerViewController loadDeviceLanguage];
  } else if ([defaultLocales objectForKey:language]) {
    [PlayerViewController useLanguageStrings:[PlayerViewController getLanguageSettings:language]];
  } else {
    [PlayerViewController chooseBackupLanguage:language];
  }
  if (fullScreenViewController) {
    [fullScreenViewController changeButtonLanguage:language];
  }

  [self refreshClosedCaptionsView];
}

// Choose a default language when there is not specific dialect for that language
// If there is not default language for a language then we choose English
// For example: choose “ja" as language when there is no ”ja_A“, however if there is
// even no "ja" we should always choose "en"
+ (void) chooseBackupLanguage:(NSString*) language {
  BOOL matched = NO;
  NSArray* array = [language componentsSeparatedByString:@"_"];
  NSString* basicLanguage = array[0];
  for (NSString* key in defaultLocales) {
    if([key isEqualToString:basicLanguage]) {
      [PlayerViewController useLanguageStrings:[PlayerViewController getLanguageSettings:key]];
      matched = YES;
      break;
    }
  }
  if (!matched) {
    [PlayerViewController useLanguageStrings:[PlayerViewController getLanguageSettings:@"en"]];
  }
}

+ (void)loadDefaultLocale{
  NSArray *keys = [NSArray arrayWithObjects:@"LIVE", @"Done", @"Languages", @"Learn More", @"Ready to cast videos from this app", @"Disconnect", @"Connect To Device", nil];
  NSDictionary *en = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"LIVE", @"Done", @"Languages", @"Learn More", @"Ready to cast videos from this app", @"Disconnect", @"Connect To Device", nil] forKeys:keys];
  NSDictionary *ja = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"ライブ", @"完了", @"言語", @"さらに詳しく", @"このアプリからビデオをキャストできます", @"切断", @"デバイスに接続", nil] forKeys:keys];
  NSDictionary *es = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"En vivo", @"Hecho", @"Idioma", @"Más información", @"Listo para trasmitir videos desde esta aplicación", @"Desconectar", @"Conectar al dispositivo", nil] forKeys:keys];
  
  defaultLocales = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:en, ja, es, nil] forKeys:[NSArray arrayWithObjects:@"en", @"ja", @"es", nil]];
}

+ (void)loadDeviceLanguage{
  if(!defaultLocales) {
    [self loadDefaultLocale];
  }
  NSString* language =[[NSLocale preferredLanguages] objectAtIndex:0];
  if ([defaultLocales objectForKey:language]) {
    [self useLanguageStrings:[defaultLocales objectForKey:language]];
  } else {
    [self chooseBackupLanguage:language];
  }
}

+ (void)useLanguageStrings:(NSDictionary *)strings {
  if(!defaultLocales) {
    [self loadDefaultLocale];
  }
  currentLocale = strings;
}

+ (NSDictionary*)currentLanguageSettings {
  if(!defaultLocales) {
    [self loadDefaultLocale];
  }
  if (!currentLocale) {
    [self loadDeviceLanguage];
  }
  return currentLocale;
}

 + (NSDictionary*)getLanguageSettings:(NSString *)language {
 if(!defaultLocales) {
 [self loadDefaultLocale];
 }
 return [defaultLocales objectForKey:language];
 }

- (ControlsViewController *)fullscreenViewControllerInstance {
  return [[FullScreenIOS7ViewController alloc] init];
}

- (ControlsViewController *)inlineViewControllerInstance {
  return [[InlineIOS7ViewController alloc] init];
}

- (BOOL)prefersStatusBarHidden {
  return [self.parentViewController prefersStatusBarHidden];
}

- (void)dealloc {
  LOG(@"PlayerViewController.dealloc %@", [self description]);
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark ClosedCaptions
- (void)onApplicationDidBecomeActive:(NSNotification *)notification {
  if (self.closedCaptionsView != nil) {
    [_closedCaptionsStyle updateStyle];
    [self.closedCaptionsView setStyle:_closedCaptionsStyle];
  }
}

- (void)onPlayheadUpdated:(NSNotification *)notification {
  [self displayCurrentClosedCaption];
}

- (void)onAdStarted:(NSNotification *)notification {
  [self removeClosedCaptionsView];
}

- (void)onAdTapped:(NSNotification *)notification {
  [[self getControls] toggleControls];
}

- (void)onStateChanged:(NSNotification *)notification {
  [self refreshClosedCaptionsView];
}

- (void)addClosedCaptionsView {
  [self removeClosedCaptionsView];

  if (self.player.currentItem.hasClosedCaptions && self.player.closedCaptionsLanguage) {
    _closedCaptionsView = [[OOClosedCaptionsView alloc] initWithFrame:self.player.videoRect];
    _closedCaptionsView.style = _closedCaptionsStyle;
    [[self getControls] updateClosedCaptionsPosition];
    [player.view addSubview:_closedCaptionsView];
  }
}

- (void)refreshClosedCaptionsView {
  if (self.player.isShowingAd) {
    [self removeClosedCaptionsView];
  } else {
    [self addClosedCaptionsView];
  }
}

- (void)removeClosedCaptionsView {
  if (_closedCaptionsView) {
    [_closedCaptionsView removeFromSuperview];
    _closedCaptionsView = nil;
  }
}

- (void)displayCurrentClosedCaption {
  if ([self shouldShowClosedCaptions]) {
    if (_closedCaptionsView.caption == nil || self.player.playheadTime < _closedCaptionsView.caption.begin || self.player.playheadTime > _closedCaptionsView.caption.end) {
      OOCaption *caption =
        [self.player.currentItem.closedCaptions captionForLanguage:self.player.closedCaptionsLanguage time:self.player.playheadTime];
      _closedCaptionsView.caption = caption;
    }
  } else {
    _closedCaptionsView.caption = nil;
  }
}

- (BOOL)shouldShowClosedCaptions {
  return self.player.closedCaptionsLanguage != nil &&
         self.player.currentItem.hasClosedCaptions &&
         ![self.player.closedCaptionsLanguage isEqualToString: OOLiveClosedCaptionsLanguage] &&
         ![player isInCastMode];
}

- (void)setClosedCaptionsPresentationStyle: (OOClosedCaptionPresentation) presentationStyle {
  self.closedCaptionsStyle.presentation = presentationStyle;
  [self.closedCaptionsView setStyle:self.closedCaptionsStyle];
}

- (void)onClosedCaptionLanguageChanged:(NSNotification *)notification {
  if([self shouldShowClosedCaptions]) {
    [self removeClosedCaptionsView];
  }
  [self changeLanguage:self.player.closedCaptionsLanguage];

  [_closedCaptionsView setCaption:nil];
  [self displayCurrentClosedCaption];
}

- (void)updateClosedCaptionsViewPosition:(CGRect)bottomControlsRect withControlsHide:(BOOL)hidden {
  CGRect videoRect = [self.player videoRect];
  if (!hidden) {
    if (bottomControlsRect.origin.y < videoRect.origin.y + videoRect.size.height) {
      videoRect.size.height = videoRect.size.height - (videoRect.origin.y + videoRect.size.height - bottomControlsRect.origin.y);
    }
  }
  [self.closedCaptionsView setFrame:videoRect];
}

@end
