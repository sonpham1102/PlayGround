//
//  PlayGround6Layer.h
//  PlayGroound
//
//  Created by Jason Parlour on 12-09-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "GameCharPhysics.h"

#define PTM_RATIO (IS_IPAD() ? (8.0*1024.0/480.0) : 8.0)

@interface PlayGround6Layer : CCLayer
{
	CCTexture2D *spriteTexture_;	// weak ref
	b2World* world;					// strong ref
	GLESDebugDraw *m_debugDraw;		// strong ref
    
    CCSpriteBatchNode *sceneSpriteBatchNode;
}

-(void) handlePan:(CGPoint) startPoint endPoint:(CGPoint) endPoint;
-(void) handleTap:(CGPoint) tapPoint;
-(void) handleRotation:(float) angleDelta;
-(void) handleLongPress:(BOOL) continueFiring;

@end
