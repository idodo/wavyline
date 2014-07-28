//
//  GameLayer.h
//  WavyLine
//
//  Created by Qing Liu on 5/22/14.
//  Copyright 2014 Qing Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameLayer : CCLayer {
  
    CGSize m_size;
    bool m_bGameStarted;
    
    CCLabelTTF *m_lblScore;
    CCSprite *m_player, *m_touchPad;
    CCSprite *m_background;
    CCSprite *m_path[2];
    NSMutableArray *_pathArray;
}

+(CCScene *) scene;

@end
