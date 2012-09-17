//
//  SmashBallChain.h
//  PlayGroound
//
//  Created by alex on 12-09-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameCharPhysics.h"

#define SBC_DENSITY 1.0
#define SBC_FRICTION 1.0
#define SBC_RESTITUTION 1.0
#define SBC_LINEAR_DAMP 0.1
#define SBC_ANG_DAMP 0.1
#define SBC_WIDTH 1.0
#define SBC_HEIGHT 0.5
#define SBC_JOINT_OFFSET 0.9*SBC_WIDTH/2.0

@interface SmashBallChain : GameCharPhysics
{
    b2World* world;
}

-(id) initWithWorld:(b2World *)theWorld atLocation:(b2Vec2)location;

@end
