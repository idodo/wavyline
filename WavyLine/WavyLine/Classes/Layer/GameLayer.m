//
//  GameLayer.m
//  WavyLine
//
//  Created by Qing Liu on 5/22/14.
//  Copyright 2014 Qing Liu. All rights reserved.
//

#import "GameLayer.h"
#import "GameOver.h"
#import "Global.h"

#import "AppDelegate.h"
#import "MKStoreManager.h"
#import "SimpleAudioEngine.h"


@implementation GameLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
        
        self.touchEnabled = YES;
		// ask director for the window size
		m_size = [[CCDirector sharedDirector] winSize];        
        
        g_nScore = 0;
        m_bGameStarted = false;
        g_bIsGameOver = false;
        
        m_background = addBackground(@"game bg", ccp(m_size.width/2, m_size.height/2), self, 0);
        
        CCSprite *header = addBackground(@"header", ccp(m_size.width/2, m_size.height), self, 3);
        header.anchorPoint = ccp(0.5, 1.0);
        m_touchPad = addBackground(@"touch-pad", ccp(m_size.width/2, 50*g_fh), self, 3);
        if ([MKStoreManager featureAdsPurchased])
            m_touchPad.position = ccp(m_size.width/2, 0);
        m_touchPad.anchorPoint = ccp(0.5, 0);
        
        m_player = addSprite(@"player", ccp(m_size.width/2, 148.0f*g_fy), self, 2);        
		
        m_lblScore = addLabel(ccp(m_size.width/2, 467.0f*g_fh+2*g_fMaginIphone5), self, @"0", ccWHITE, 18*g_fh, 4);
        addLabel(ccp(m_size.width/2, 449.0f*g_fh+2*g_fMaginIphone5), self, [NSString stringWithFormat:@"Best: %d", g_gameInfo.bestScore], ccWHITE, 14*g_fh, 4);
        
        m_path[0] = addBackground(@"path0", ccp(m_size.width/2, m_size.height/2), self, 1);
        int index = arc4random() % 23 + 1;
        m_path[1] = addBackground([NSString stringWithFormat:@"path%d", index], ccp(m_size.width/2, m_size.height*3/2-g_fh), self, 1);
        //index = arc4random() % 23 + 1;
        //m_path[2] = addBackground([NSString stringWithFormat:@"path%d", index], ccp(m_size.width/2, m_size.height*5/2-2*g_fh), self, 1);
        
        _pathArray = [[NSMutableArray alloc] init];
        
        for (int i = 1; i <= 23; i++) {
            CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"path%d.png", i]];
            [_pathArray addObject:texture];
        }
	}
	
	return self;
}

-(void) onEnter
{
    [super onEnter];
    
    if (![MKStoreManager featureAdsPurchased]) {
        AppController *app = [AppController sharedDelegate];
        [app createAdmobAds];
    }
}

-(void) scoreCounter:(ccTime)dt
{
    g_nScore++;
    
    [m_lblScore setString:[NSString stringWithFormat:@"%d", g_nScore]];
}

-(void) tick:(ccTime)dt
{
    if ([self checkRoadOut]) {
        [self gameOver];
        return;
    }
    
    for (int i = 0; i < 3; i++) {
        m_path[i].position = ccp(m_path[i].position.x, m_path[i].position.y - MOVE_INTERVAL);
        
        if (m_path[i].position.y > m_size.height*3/2) {
            m_path[i].visible = NO;
        } else {
            m_path[i].visible = YES;
        }
        
        if (m_path[i].position.y <= -m_size.height) {
            int index = arc4random() % 23;
            CCTexture2D *texture = (CCTexture2D *)[_pathArray objectAtIndex:index];
            
            [m_path[i] setTexture:texture];
            m_path[i].position = ccp(m_path[i].position.x, m_path[i].position.y + 3*m_size.height-6*g_fh);
        }
    }
}

-(void) update:(ccTime)delta
{
    if (m_path[0].position.y <= -m_size.height/2) {
        int index = arc4random() % 23;
        CCTexture2D *pathTexture = (CCTexture2D *)[_pathArray objectAtIndex:index];
        [m_path[0] setTexture:pathTexture];
        m_path[0].position = ccp(m_path[0].position.x, m_path[0].position.y + 2*m_size.height-3*g_fh);
    } else if (m_path[1].position.y <= -m_size.height/2) {
        int index = arc4random() % 23;
        CCTexture2D *pathTexture = (CCTexture2D *)[_pathArray objectAtIndex:index];
        [m_path[1] setTexture:pathTexture];
        m_path[1].position = ccp(m_path[1].position.x, m_path[1].position.y + 2*m_size.height-3*g_fh);
    }
    
    m_path[0].position = ccp(m_path[0].position.x, m_path[0].position.y - MOVE_INTERVAL);
    m_path[1].position = ccp(m_path[1].position.x, m_path[1].position.y - MOVE_INTERVAL);
    
    CCRenderTexture *texture = [CCRenderTexture renderTextureWithWidth:m_size.width height:m_size.height pixelFormat:kCCTexture2DPixelFormat_RGBA4444];
    [texture begin];
    
    [m_path[0] visit];
    [m_path[1] visit];
    
    ccColor4B *buffer = malloc(sizeof(ccColor4B));
    
    CGPoint location = ccp(m_player.position.x*CC_CONTENT_SCALE_FACTOR(), m_player.position.y*CC_CONTENT_SCALE_FACTOR());
    glReadPixels((GLint)location.x, (GLint)location.y, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    ccColor4B color = buffer[0];
    
    if (color.r == 0 && color.g == 0 && color.b == 0) {
        [self gameOver];
    }
    
    [texture end];
}

-(BOOL) checkRoadOut
{
    ccColor4B *buffer = malloc(sizeof(ccColor4B));
    
    CGPoint location = ccp((m_player.position.x-m_player.boundingBox.size.width/2)*CC_CONTENT_SCALE_FACTOR(), m_player.position.y*CC_CONTENT_SCALE_FACTOR());
    glReadPixels((GLint)location.x-1, (GLint)location.y, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    ccColor4B color1 = buffer[0];
    
    location = ccp((m_player.position.x+m_player.boundingBox.size.width/2)*CC_CONTENT_SCALE_FACTOR(), m_player.position.y*CC_CONTENT_SCALE_FACTOR());
    glReadPixels((GLint)location.x+1, (GLint)location.y, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    ccColor4B color2 = buffer[0];
    
    location = ccp(m_player.position.x*CC_CONTENT_SCALE_FACTOR(), (m_player.position.y-m_player.boundingBox.size.height/2)*CC_CONTENT_SCALE_FACTOR());
    glReadPixels((GLint)location.x, (GLint)location.y-1, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    ccColor4B color3 = buffer[0];
    
    location = ccp(m_player.position.x*CC_CONTENT_SCALE_FACTOR(),  (m_player.position.y+m_player.boundingBox.size.height/2)*CC_CONTENT_SCALE_FACTOR());
    glReadPixels((GLint)location.x, (GLint)location.y+1, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    ccColor4B color4 = buffer[0];
    
//    NSString *str = [NSString stringWithFormat:@"R:%d G:%d B:%d", color.r, color.g, color.b];
//    NSLog(@"%@", str);
    
    if ((color1.r == 255 && color1.g == 255 && color1.b == 255) &&
        (color2.r == 255 && color2.g == 255 && color2.b == 255) &&
        (color3.r == 255 && color3.g == 255 && color3.b == 255) &&
        (color4.r == 255 && color4.g == 255 && color4.b == 255)) {
        return YES;
    }
    
    return NO;
}

-(void) gameOver
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"hit.mp3"];
    
    [self unscheduleAllSelectors];
    
    GameOver *gameOver = [[GameOver alloc] init];
    [self addChild:gameOver z:10];
    [gameOver release];
}

#pragma mark - Touch Events

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (g_bIsGameOver) return;
    
    UITouch *touch = [touches anyObject];
    
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    if (location.y >= m_touchPad.position.y && location.y <= m_touchPad.position.y + m_touchPad.boundingBox.size.height) {
        if (!m_bGameStarted) {
            m_bGameStarted = true;
            
            //[self schedule:@selector(tick:)];
            [self schedule:@selector(update:)];
            [self schedule:@selector(scoreCounter:) interval:0.2f];
        }
        
        m_player.position = ccp(location.x, m_player.position.y);
    }
}

-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (g_bIsGameOver) return;
    
    UITouch *touch = [touches anyObject];
    
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    if (location.y >= m_touchPad.position.y && location.y <= m_touchPad.position.y + m_touchPad.boundingBox.size.height) {
        m_player.position = ccp(location.x, m_player.position.y);
    }
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //[self gameOver];
}

-(void) dealloc
{
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [self removeAllChildrenWithCleanup:YES];
    
    [super dealloc];
}


@end



