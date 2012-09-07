//
//  GBVortex.h
//  PlayGroound
//
//  Created by alex on 12-09-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameCharPhysics.h"

@interface GBVortex : GameCharPhysics
{
    b2World *world;
    float lifeTimer;
}

-(id) initWithWorld:(b2World *)theWorld atLocation:(b2Vec2)location;
-(void)updateStateWithDeltaTime:(ccTime)deltaTime;

@end
