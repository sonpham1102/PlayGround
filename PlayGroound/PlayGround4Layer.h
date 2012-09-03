//
//  PlayGround4Layer.h
//  PlayGroound
//
//  Created by Jason Parlour on 12-09-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "SimpleAudioEngine.h"
#import "GlobalConstants.h"
#import <GameKit/GameKit.h>


@class PlayGroundScene4UILayer;

@interface PlayGround4Layer : CCLayer <PlayGround4LayerDelegate> {
    
    GLESDebugDraw *m_debugDraw;
    PlayGroundScene4UILayer *uiLayer;
    
    b2World* world;
}

-(id)initWithUILayer:(PlayGroundScene4UILayer *)ui;

@end
