//
//  GameOver.h
//  WavyLine
//
//  Created by Qing Liu on 5/22/14.
//  Copyright 2014 Qing Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameOver : CCLayer {
    CGSize m_size;
    
    CCMenuItem *m_retryItem, *m_scoreItem, *m_adsItem, *m_restorItem;
    CCMenuItemToggle *m_soundItem;
}

+(CCScene *) scene;
-(void) updateMenu;

@end
