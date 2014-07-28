//
//  AppDelegate.h
//  WavyLine
//
//  Created by Qing Liu on 5/22/14.
//  Copyright Qing Liu 2014. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "AppSpecificValues.h"

#import "GADBannerView.h"

#import "GameCenterManager.h"
#import <GameKit/GameKit.h>


// Added only for iOS 6 support
@interface MyNavigationController : UINavigationController <CCDirectorDelegate>
@end

@interface AppController : NSObject <UIApplicationDelegate, GameCenterManagerDelegate, GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate>
{
	UIWindow *window_;
	MyNavigationController *navController_;

	CCDirectorIOS	*director_;							// weak ref
    
    GADBannerView *mBannerView;
    CocosBannerType mBannerType;
    float on_x, on_y, off_x, off_y;
    
    BOOL isBannerShown;
    
    GameCenterManager* gameCenterManager_;
	NSString* currentLeaderBoard_;
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) MyNavigationController *navController;
@property (readonly) CCDirectorIOS *director;

@property (nonatomic, retain) GameCenterManager *gameCenterManager;
@property (nonatomic, retain) NSString* currentLeaderBoard;

+(AppController*) sharedDelegate;

#pragma mark Game Center
-(void) submitScore:(int)uploadScore;
-(void) showLeaderboard;
-(void) showAchievements;

#pragma mark Google Admob
-(void) createAdmobAds;
-(void) dismissAdView;


@end
