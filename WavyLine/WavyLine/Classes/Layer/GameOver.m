//
//  GameOver.m
//  WavyLine
//
//  Created by Qing Liu on 5/22/14.
//  Copyright 2014 Qing Liu. All rights reserved.
//

#import "GameOver.h"
#import "GameLayer.h"
#import "Global.h"
#import "MKStoreManager.h"
#import "AppDelegate.h"
#import "SimpleAudioEngine.h"

#import "Chartboost.h"
#import "ALInterstitialAd.h"


@implementation GameOver

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameOver *layer = [GameOver node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
        
        int random = arc4random() % 2;
        
        if (![MKStoreManager featureAdsPurchased]) {
            if (random == 0)
                [[Chartboost sharedChartboost] showInterstitial];
            else
                [ALInterstitialAd showOver:[[UIApplication sharedApplication] keyWindow]];
        }
        
        if (g_gameOverLayer == nil)
            g_gameOverLayer = self;
        self.touchEnabled = YES;
		// ask director for the window size
		m_size = [[CCDirector sharedDirector] winSize];
        
        if (g_nScore > g_gameInfo.bestScore) {
            g_gameInfo.bestScore = g_nScore;
            saveGameInfo();
        }
        
        addBackground(@"opacity bg", ccp(m_size.width/2, m_size.height/2), self, 0);
        
        addLabel(ccp(m_size.width/2, 362*g_fy), self, @"Game Over", ccWHITE, 44*g_fh, 1);
        addLabel(ccp(m_size.width/2, 265*g_fh+g_fMaginIphone5), self, [NSString stringWithFormat:@"Score: %d", g_nScore], ccWHITE, 22*g_fh, 1);
        addLabel(ccp(m_size.width/2, 224*g_fh+g_fMaginIphone5), self, [NSString stringWithFormat:@"Best: %d", g_gameInfo.bestScore], ccWHITE, 22*g_fh, 1);
        
        [self createMenu];
        
        if (g_bIsSoundOn)
            m_soundItem.selectedIndex = 0;
        else
            m_soundItem.selectedIndex = 1;
	}
	
	return self;
}

-(void) createMenu
{
    m_retryItem = addTextButton(@"Try Again", ccp(m_size.width/2, 158*g_fh+g_fMaginIphone5), 28*g_fh, ccYELLOW, self, @selector(actionRetry:));
    m_scoreItem = addTextButton(@"High Score", ccp(m_size.width/2, 123*g_fh+g_fMaginIphone5), 28*g_fh, ccc3(0, 240, 255), self, @selector(actionScore:));
    m_adsItem = addTextButton(@"Remove Ads", ccp(100*g_fx, 88*g_fh+g_fMaginIphone5), 28*g_fh, ccc3(0, 255, 90), self, @selector(actionAds:));
    m_restorItem = addTextButton(@"Restore", ccp(246*g_fx, 88*g_fh+g_fMaginIphone5), 28*g_fh, ccc3(0, 255, 90), self, @selector(actionRestore:));
    m_restorItem = addTextButton(@"earn coins", ccp(m_size.width/2, 53*g_fh+g_fMaginIphone5), 28*g_fh, ccc3(0, 240, 255), self, @selector(actionRestore:));
    m_soundItem = addToggleButton(@"sound", ccp(292*g_fx, 455*g_fh+2*g_fMaginIphone5), self, @selector(actionSound:));
    
    CCMenu *menu = [CCMenu menuWithItems:m_retryItem, m_scoreItem, m_adsItem, m_restorItem, m_soundItem, nil];
    menu.position = ccp(0, 0);
    [self addChild:menu z:1];
    
    if ([MKStoreManager featureAdsPurchased]) {
        [self updateMenu];
    }
}

-(void) actionRetry:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameLayer scene] ]];
}

-(void) actionScore:(id)sender
{
    AppController *app = [AppController sharedDelegate];
    [app showLeaderboard];
}

-(void) actionAds:(id)sender
{
    if ([MKStoreManager featureAdsPurchased]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Already Purchased" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    [[MKStoreManager sharedManager] buyFeatureAds];
}

-(void) actionRestore:(id)sender
{
    [[MKStoreManager sharedManager] restoreFunc];
}
-(void) earnCoins:(id)sender
{
    
}
-(void) actionSound:(id)sender
{
    g_bIsSoundOn = !g_bIsSoundOn;
    
    if (g_bIsSoundOn) {
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:1.0f];
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:1.0f];
    } else {
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.0f];
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.0f];
    }
}

-(void) updateMenu
{
    m_adsItem.visible = NO;
    m_restorItem.visible = NO;
    
    m_retryItem.position = ccp(m_size.width/2, 149*g_fh+g_fMaginIphone5);
    m_scoreItem.position = ccp(m_size.width/2, 110*g_fh+g_fMaginIphone5);
    
    AppController *app = [AppController sharedDelegate];
    [app dismissAdView];
}

-(void) dealloc
{
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [self removeAllChildrenWithCleanup:YES];
    
    [super dealloc];
}

@end
