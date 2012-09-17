//
//  SmashBallMain.h
//  PlayGroound
//
//  Created by alex on 12-09-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameCharPhysics.h"

#define SBM_RADIUS 2.0
#define SBM_JOINT_OFFSET SBM_RADIUS*0.0
#define SBM_DENSITY 1.0
#define SBM_FRICTION 1.0
#define SBM_RESTITUTION 1.0
#define SBM_LINEAR_DAMP 1.0
#define SBM_ANG_DAMP 1.0

@interface SmashBallMain : GameCharPhysics
{
    b2World* world;
}

-(id) initWithWorld:(b2World *)theWorld atLocation:(b2Vec2)location;

@end