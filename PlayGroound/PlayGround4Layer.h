//
//  PlayGround4Layer.h
//  PlayGroound
//
//  Created by Jason Parlour on 12-09-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "GlobalConstants.h"
#import "CCLayer.h"
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "SimpleAudioEngine.h"
#import "Paddle.h"
#import "Ball.h"

#import "Level4ContactListener.h"

@class PlayGroundScene4UILayer;

@interface PlayGround4Layer : CCLayer <PlayGround4LayerDelegate> {
    
    GLESDebugDraw *m_debugDraw;
    
    PlayGroundScene4UILayer *uiLayer;
    
    b2World* world;
    
    Level4ContactListener* contactListener;
    
    Paddle* thePaddle;
    Ball* theBall;
    
    UITouch* leftTouch;
    UITouch* rightTouch;
    CGPoint leftTouchPos;
    CGPoint rightTouchPos;
    
    CCSpriteBatchNode *sceneSpriteBatchNode;
}

@property (nonatomic, readonly) CGPoint leftTouchPos;
@property (nonatomic, readonly) CGPoint rightTouchPos;

-(id)initWithUILayer:(PlayGroundScene4UILayer *)ui;

@end
