//
//  Global.m
//  WavyLine
//
//  Created by Qing Liu on 5/22/14.
//  Copyright (c) 2014 Qing Liu. All rights reserved.
//

#import "Global.h"


CGFloat g_fx = 1.0f;
CGFloat g_fy = 1.0f;

CGFloat g_fs = 1.0f;
CGFloat g_fh = 1.0f;
CGFloat g_fsh = 1.0f;

CGFloat g_fMaginIphone5 = 0;
CGSize  g_mySize;

int     g_nScore = 0;
bool    g_bIsGameOver = false;
bool    g_bIsSoundOn = true;

GameOver *g_gameOverLayer = nil;
struct GAME_INFO g_gameInfo;

BOOL loadGameInfo()
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *szFile = [documentsDirectory stringByAppendingPathComponent: @"gameInfo.dat"];
	
	FILE *fp = fopen([szFile cStringUsingEncoding:NSASCIIStringEncoding], "rb+");
	
	if (fp == nil)
    {
        g_gameInfo.bestScore = 0;
    }
    else
    {
        fread(&g_gameInfo, sizeof(struct GAME_INFO), 1, fp);
    }
	
	fclose(fp);
    
    return TRUE;
}

BOOL saveGameInfo()
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *szFile = [documentsDirectory stringByAppendingPathComponent:@"gameInfo.dat"];
	
	FILE *fp = fopen([szFile cStringUsingEncoding:NSASCIIStringEncoding],"wb+");
	
	if (fp == nil)
		return FALSE;
    
    fwrite(&g_gameInfo, sizeof(struct GAME_INFO), 1, fp);
    
    fclose(fp);
    
    return TRUE;
}

CCSprite *addBackground(NSString *sName, CGPoint pos, id target, int zOrder)
{
    CCSprite *sprite;
    
    sprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@.png", sName]];
    sprite.scaleX = g_fs;
    sprite.scaleY = g_fsh;
    
    sprite.position = pos;
    [target addChild:sprite z:zOrder];
    
    return sprite;
}

CCSprite *addSprite(NSString *sName, CGPoint pos, id target, int zOrder)
{
    CCSprite *sprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@.png", sName]];
    sprite.scale = g_fs;
    
    sprite.position = pos;
    [target addChild:sprite z:zOrder];
    
    return sprite;
}

CCMenuItemImage *addButton(NSString* btnName, CGPoint pos, id target, SEL selector)
{
    CCMenuItemImage *item;
    
    item = [CCMenuItemImage itemWithNormalImage:[NSString stringWithFormat:@"bt_%@.png", btnName] selectedImage:[NSString stringWithFormat:@"bt_%@_d.png", btnName] target:target selector:selector];
    item.scale = g_fs;
    item.position = pos;
    
    return item;
}

CCMenuItemImage *addSingleButton(NSString* btnName, CGPoint pos, id target, SEL selector)
{
    CCMenuItemImage *item;
    
    item = [CCMenuItemImage itemWithNormalImage:[NSString stringWithFormat:@"bt_%@.png", btnName] selectedImage:[NSString stringWithFormat:@"bt_%@.png", btnName] target:target selector:selector];
    item.scale = g_fs;
    item.position = pos;
    
    return item;
}

CCMenuItemImage *addFullButton(NSString* btnName, CGPoint pos, id target, SEL selector, BOOL isSingle)
{
    CCMenuItemImage *item;
    
    if (isSingle) {
        item = [CCMenuItemImage itemWithNormalImage:[NSString stringWithFormat:@"bt_%@.png", btnName] selectedImage:[NSString stringWithFormat:@"bt_%@.png", btnName] disabledImage:[NSString stringWithFormat:@"bt_%@_no.png", btnName] target:target selector:selector];
    } else {
        item = [CCMenuItemImage itemWithNormalImage:[NSString stringWithFormat:@"bt_%@.png", btnName] selectedImage:[NSString stringWithFormat:@"bt_%@_d.png", btnName] disabledImage:[NSString stringWithFormat:@"bt_%@_no.png", btnName] target:target selector:selector];
    }
    item.scale = g_fs;
    item.position = pos;
    
    return item;
}

CCMenuItem *addTextButton(NSString* strLabel, CGPoint pos, CGFloat fontSize, ccColor3B color, id target, SEL selector)
{
    CCMenuItem *item;
    
    item = [CCMenuItemFont itemWithString:strLabel target:target selector:selector];
    [(CCMenuItemFont*)item setFontSize:fontSize];
    [(CCMenuItemFont*)item setColor:color];
    item.position = pos;
    
    return item;
}

CCMenuItemToggle *addToggleButton(NSString *btnName, CGPoint pos, id target, SEL selector)
{
    CCMenuItemToggle *item;
    CCMenuItemImage *itemOn, *itemOff;
    
    itemOn = [CCMenuItemImage itemWithNormalImage:[NSString stringWithFormat:@"btn-%@-on.png", btnName] selectedImage:[NSString stringWithFormat:@"btn-%@-on.png", btnName]];
    
    itemOff = [CCMenuItemImage itemWithNormalImage:[NSString stringWithFormat:@"btn-%@-off.png", btnName] selectedImage:[NSString stringWithFormat:@"btn-%@-off.png", btnName]];
    
    item = [CCMenuItemToggle itemWithTarget:target selector:selector items:itemOn, itemOff, nil];
    item.scale = g_fs;
    item.position = pos;
    
    return item;
}


CCLabelTTF *addLabel(CGPoint pos, CCNode *scene, NSString *str, ccColor3B color, CGFloat fontSize, int zOrder)
{
    CCLabelTTF *lblStr = [CCLabelTTF labelWithString:str fontName:FONT_NAME fontSize:fontSize];
    lblStr.color = color;
    lblStr.position = pos;
    [scene addChild:lblStr z:zOrder];
    
    return lblStr;
}
