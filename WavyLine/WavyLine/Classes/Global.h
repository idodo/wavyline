//
//  Global.h
//  WavyLine
//
//  Created by Qing Liu on 5/22/14.
//  Copyright (c) 2014 Qing Liu. All rights reserved.
//


#ifndef _GLOBAL_H_
#define _GLOBAL_H_

#import <Foundation/Foundation.h>
#import "cocos2d.h"


#define FONT_NAME @"Impact"
#define MOVE_INTERVAL   2.0f*g_fh


struct GAME_INFO {
    int bestScore;
};


extern CGFloat  g_fx;
extern CGFloat  g_fy;

extern CGFloat  g_fs;
extern CGFloat  g_fh;
extern CGFloat  g_fsh;

extern CGFloat  g_fMaginIphone5;
extern CGSize   g_mySize;

extern int      g_nScore;
extern bool     g_bIsGameOver;
extern bool     g_bIsSoundOn;

@class GameOver;
extern GameOver *g_gameOverLayer;
extern struct GAME_INFO g_gameInfo;

BOOL loadGameInfo();
BOOL saveGameInfo();

CCSprite *addBackground(NSString *sName, CGPoint pos, id target, int zOrder);
CCSprite *addSprite(NSString *sName, CGPoint pos, id target, int zOrder);

CCMenuItemImage *addButton(NSString* btnName, CGPoint pos, id target, SEL selector);
CCMenuItemImage *addSingleButton(NSString* btnName, CGPoint pos, id target, SEL selector);
CCMenuItemImage *addFullButton(NSString* btnName, CGPoint pos, id target, SEL selector, BOOL isSingle);

CCMenuItem *addTextButton(NSString* strLabel, CGPoint pos, CGFloat fontSize, ccColor3B color, id target, SEL selector);
CCMenuItemToggle *addToggleButton(NSString *btnName, CGPoint pos, id target, SEL selector);

CCLabelTTF *addLabel(CGPoint pos, CCNode *scene, NSString *str, ccColor3B color, CGFloat fontSize, int zOrder);


#endif