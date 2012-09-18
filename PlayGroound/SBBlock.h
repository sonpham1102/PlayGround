//
//  SBBlock.h
//  PlayGroound
//
//  Created by alex on 12-09-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameCharPhysics.h"

#define SBB_DENSITY 1.0
#define SBB_FRICTION 1.0
#define SBB_RESTITUTION 0.5
#define SBB_LINEAR_DAMP 0.1
#define SBB_ANG_DAMP 0.1
#define SBB_WIDTH 2.0
#define SBB_HEIGHT 1.0

@interface SBBlock : GameCharPhysics
{
    b2World* world;
    float deathTimer;
    b2Vec2 startingLocation;
}

-(id) initWithWorld:(b2World *)theWorld atLocation:(b2Vec2)location;

@end
