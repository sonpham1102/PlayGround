//
//  PlayGround1Layer.h
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "RocketMan.h"
#import "PanRayCastCallback.h"

// HelloWorldLayer
@interface PlayGround1Layer : CCLayer
{
	CCTexture2D *spriteTexture_;	// weak ref
	b2World* world;					// strong ref
	GLESDebugDraw *m_debugDraw;		// strong ref
    RocketMan* rocketMan;
    b2Body* endZoneSensor;
    CGPoint cameraTarget;
    
    CGPoint debugLineStartPoint;
    CGPoint debugLineEndPoint;

//    PanRayCastCallback *_panRaycastCallback;
}

-(void) handlePan:(CGPoint) startPoint endPoint:(CGPoint) endPoint;
-(void) handleTap:(CGPoint) tapPoint;


@end

