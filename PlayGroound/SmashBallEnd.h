//
//  SmashBallEnd.h
//  PlayGroound
//
//  Created by alex on 12-09-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameCharPhysics.h"

#define SBE_RADIUS 1.0
#define SBE_JOINT_OFFSET 0.0*SBE_RADIUS
#define SBE_DENSITY 1.0
#define SBE_FRICTION 1.0
#define SBE_RESTITUTION 1.0
#define SBE_LINEAR_DAMP 1.0
#define SBE_ANG_DAMP 1.0

@interface SmashBallEnd : GameCharPhysics
{
    b2World* world;
}

-(id) initWithWorld:(b2World *)theWorld atLocation:(b2Vec2)location;

@end
