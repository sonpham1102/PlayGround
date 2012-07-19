//
//  PlayGround2Layer.h
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
#import "Rocket.h"

// HelloWorldLayer
@interface PlayGround2Layer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
    Rocket *rocket;
	CCTexture2D *spriteTexture_;	// weak ref
	b2World* world;                 // strong ref
    b2Body* mainBody;
	GLESDebugDraw *m_debugDraw;		// strong ref
    
    UITouch* touchLeft;
    UITouch* touchRight;
    
}

@end
