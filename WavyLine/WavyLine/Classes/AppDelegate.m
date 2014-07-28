//
//  AppDelegate.m
//  WavyLine
//
//  Created by Qing Liu on 5/22/14.
//  Copyright Qing Liu 2014. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "IntroLayer.h"
#import "SimpleAudioEngine.h"
#import "Global.h"

#import "Chartboost.h"
#import "ALSdk.h"
#import "ALInterstitialAd.h"


@implementation MyNavigationController

// The available orientations should be defined in the Info.plist file.
// And in iOS 6+ only, you can override it in the Root View controller in the "supportedInterfaceOrientations" method.
// Only valid for iOS 6+. NOT VALID for iOS 4 / 5.
-(NSUInteger)supportedInterfaceOrientations {
	
	// iPhone only
	if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
		return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
	
	// iPad only
	return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

// Supported orientations. Customize it for your own needs
// Only valid on iOS 4 / 5. NOT VALID for iOS 6.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// iPhone only
	if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
		return UIInterfaceOrientationIsPortrait(interfaceOrientation);
	
	// iPad only
	// iPhone only
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

// This is needed for iOS4 and iOS5 in order to ensure
// that the 1st scene has the correct dimensions
// This is not needed on iOS6 and could be added to the application:didFinish...
-(void) directorDidReshapeProjection:(CCDirector*)director
{
	if(director.runningScene == nil) {
		// Add the first scene to the stack. The director will draw it immediately into the framebuffer. (Animation is started automatically when the view is displayed.)
		// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
		[director runWithScene: [IntroLayer scene]];
	}
}
@end

#define CHARTBOOST_APP_ID           @"537f6e9c89b0bb3ec9a3000f"
#define CHARTBOOST_APP_SIGNATURE    @"e75023d7d0a2c82ab3656c764e144f07fbb7cf3b"

#define BANNER_TYPE  kBanner_Portrait_Bottom
#define BANNER_UNIT_ID @"ca-app-pub-7229793621290802/8100370173"


@implementation AppController

@synthesize window=window_, navController=navController_, director=director_;

+(AppController*) sharedDelegate
{
    return (AppController*)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [ALSdk initializeSdk];
    isBannerShown = NO;
    
	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	
	// CCGLView creation
	// viewWithFrame: size of the OpenGL view. For full screen use [_window bounds]
	//  - Possible values: any CGRect
	// pixelFormat: Format of the render buffer. Use RGBA8 for better color precision (eg: gradients). But it takes more memory and it is slower
	//	- Possible values: kEAGLColorFormatRGBA8, kEAGLColorFormatRGB565
	// depthFormat: Use stencil if you plan to use CCClippingNode. Use Depth if you plan to use 3D effects, like CCCamera or CCNode#vertexZ
	//  - Possible values: 0, GL_DEPTH_COMPONENT24_OES, GL_DEPTH24_STENCIL8_OES
	// sharegroup: OpenGL sharegroup. Useful if you want to share the same OpenGL context between different threads
	//  - Possible values: nil, or any valid EAGLSharegroup group
	// multiSampling: Whether or not to enable multisampling
	//  - Possible values: YES, NO
	// numberOfSamples: Only valid if multisampling is enabled
	//  - Possible values: 0 to glGetIntegerv(GL_MAX_SAMPLES_APPLE)
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565
								   depthFormat:0
							preserveBackbuffer:YES
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];
	
	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];
	
	director_.wantsFullScreenLayout = YES;
	
	// Display FSP and SPF
	[director_ setDisplayStats:NO];
	
	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];
	
	// attach the openglView to the director
	[director_ setView:glView];
	
	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
	//	[director setProjection:kCCDirectorProjection3D];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if ([UIScreen mainScreen].scale == 2.0f && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
    {
        CCLOG(@"iPad Retina Display Not supported");
    }
    else
    {
        if( ! [director_ enableRetinaDisplay:YES] )
        	CCLOG(@"Retina Display Not supported");
    }
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change this setting at any time.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
	
	// Create a Navigation Controller with the Director
	navController_ = [[MyNavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;

	// for rotation and other messages
	[director_ setDelegate:navController_];
	
	// set the Navigation Controller as the root view controller
	[window_ setRootViewController:navController_];
    
    g_fMaginIphone5 = 0;
    g_mySize = [director_ winSize];
    
    //if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
	//{
        g_fx = 1.0f;
        g_fy = 1.0f;
        g_fh = 1.0f;
        
        g_fs = 320.0f / 640.0f * [UIScreen mainScreen].scale;
        g_fsh = 480.0f / 1136.0f * [UIScreen mainScreen].scale;
        
        if (g_mySize.width == 568 || g_mySize.height == 568) {
            g_fy = 568.0f / 480.0f;
            g_fsh = 1.0f;
            g_fMaginIphone5 = 44.0f;
        }
	//}
	/*else
	{
        g_fx = 768.0f / 320.0f;
		g_fy = 1024.0f / 480.0f;
        g_fh = 1024.0f / 480.0f;
        
        g_fs = 768.0f / 640.0f;
        g_fsh = 1024.0f / 1136.0f;
	}*/
    
    [self preloadSound];
    [self initGameCenter];
    loadGameInfo();
	
	// make main window visible
	[window_ makeKeyAndVisible];
	
	return YES;
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];	
	if( [navController_ visibleViewController] == director_ )
		[director_ resume];
    
    Chartboost *cb = [Chartboost sharedChartboost];
    cb.appId = CHARTBOOST_APP_ID;
    cb.appSignature = CHARTBOOST_APP_SIGNATURE;
    [cb startSession];
    [cb cacheInterstitial];
    [cb cacheMoreApps];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

-(void) preloadSound
{
    [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"main.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"hit.mp3"];
}

-(void) unloadSound
{
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"hit.mp3"];
}

- (void) dealloc
{
    [self unloadSound];
    
	[window_ release];
	[navController_ release];
	
	[super dealloc];
}

#pragma mark Google Admob

-(void) createAdmobAds
{
    if (isBannerShown) return;
    
    isBannerShown = YES;
    
    mBannerType = BANNER_TYPE;
    
    // Create a view of the standard size at the bottom of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    
    if(mBannerType <= kBanner_Portrait_Bottom)
        mBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    else
        mBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerLandscape];
    
    // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
    mBannerView.adUnitID = BANNER_UNIT_ID;
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    
    mBannerView.rootViewController = self.navController;
    [self.navController.view addSubview:mBannerView];
    
    // Initiate a generic request to load it with an ad.
    [mBannerView loadRequest:[GADRequest request]];
    
    CGSize s = [CCDirector sharedDirector].winSize;
    
    CGRect frame = mBannerView.frame;
    
    off_x = 0.0f;
    on_x = 0.0f;
    
    switch (mBannerType)
    {
        case kBanner_Portrait_Top:
        {
            off_y = -frame.size.height;
            on_y = 0.0f;
        }
            break;
        case kBanner_Portrait_Bottom:
        {
            off_y = s.height;
            on_y = s.height-frame.size.height;
        }
            break;
        case kBanner_Landscape_Top:
        {
            off_y = -frame.size.height;
            on_y = 0.0f;
        }
            break;
        case kBanner_Landscape_Bottom:
        {
            off_y = s.height;
            on_y = s.height-frame.size.height;
        }
            break;
            
        default:
            break;
    }
    
    frame.origin.y = off_y;
    frame.origin.x = off_x;
    
    mBannerView.frame = frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    frame = mBannerView.frame;
    frame.origin.x = on_x;
    frame.origin.y = on_y;
    
    
    mBannerView.frame = frame;
    [UIView commitAnimations];
}


-(void) dismissAdView
{
    if (mBannerView)
    {
        [UIView animateWithDuration:0.5
                              delay:0.1
                            options: UIViewAnimationCurveEaseOut
                         animations:^
         {
             CGRect frame = mBannerView.frame;
             frame.origin.y = off_y;
             frame.origin.x = off_x;
             mBannerView.frame = frame;
         }
                         completion:^(BOOL finished)
         {
             [mBannerView setDelegate:nil];
             [mBannerView removeFromSuperview];
             mBannerView = nil;
             
         }];
    }
}

#pragma mark - Game Center

-(BOOL) initGameCenter
{
	if (self.gameCenterManager != nil)
		return NO;
    self.currentLeaderBoard = kEasyLeaderboardID;
    
	if ([GameCenterManager isGameCenterAvailable]) {
		self.gameCenterManager = [[GameCenterManager alloc] init];
		[self.gameCenterManager setDelegate:self];
		[self.gameCenterManager authenticateLocalUser];
        
        return YES;
	} else {
        NSString *message = @"This IOS version is not available Game Center.";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message!" message:message delegate:self cancelButtonTitle:@"YES" otherButtonTitles: nil];
        alert.tag = 1;
        [alert show];
    }
    
    return NO;
}

-(void) showLeaderboard
{
	GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
    
	if (leaderboardViewController != NULL) {
		leaderboardViewController.category = self.currentLeaderBoard;
		leaderboardViewController.timeScope = GKLeaderboardTimeScopeAllTime;
		leaderboardViewController.leaderboardDelegate = self;
        
        [self.navController presentViewController:leaderboardViewController animated:YES completion:nil];
	}
}

-(void) showAchievements
{
	GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
    
	if (achievements != NULL) {
		achievements.achievementDelegate = self;
		[self.navController presentViewController:achievements animated:YES completion:nil];
	}
}

-(void)submitScore:(int)uploadScore
{
	if( uploadScore > 0) {
        if ([GameCenterManager isGameCenterAvailable]) {
            [self.gameCenterManager reportScore:uploadScore  forCategory: self.currentLeaderBoard];
            [self.gameCenterManager reloadHighScoresForCategory:self.currentLeaderBoard];
        }
	}
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	[self.navController dismissViewControllerAnimated:YES completion:nil];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	[self.navController dismissViewControllerAnimated:YES completion:nil];
}

#pragma makr GameCenterManager protocol

-(void) scoreReported:(NSError*) error
{
    NSString *message = @"Score submited succesfully to Game Center.";
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!" message:message delegate:self cancelButtonTitle:@"YES" otherButtonTitles: nil];
    //    alert.tag = 1;
    //    [alert show];
    //    [alert release];
    NSLog(@"%@", message);
}

-(void) processGameCenterAuth:(NSError*) error
{
    if (error == NULL) {
        NSLog(@"Game Center Auth success!");
    }
    else {
        NSLog(@"Game Center Auth faild!");
    }
}

-(void) reloadScoresComplete:(GKLeaderboard*)leaderBoard error:(NSError*)error
{
    if (error == NULL) {
        NSLog(@"Game Center reload socores success!");
    }
    else {
        NSLog(@"Game Center reload socores faild!");
    }
}


@end
