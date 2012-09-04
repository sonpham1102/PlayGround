//
//  GBEnemy.h
//  PlayGroound
//
//  Created by alex on 12-09-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameCharPhysics.h"
#import "GlobalConstants.h"

@interface GBEnemy : GameCharPhysics
{
    b2World* world;
    b2Body* target;
}
-(id) initWithWorld:(b2World *)theWorld atLocation:(b2Vec2)location withTargetBody:(b2Body*) theTarget;

@end
