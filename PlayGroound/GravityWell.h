//
//  GravityWell.h
//  PlayGroound
//
//  Created by alex on 12-08-09.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameCharPhysics.h"

@interface GravityWell : GameCharPhysics
{
    b2World *world;
    bool forceOn;
    b2Vec2 directionVector;
}

//location should be in meters so that this object doesn't need the know that layer's PTM_RATIO
-(id)initWithWorld:(b2World*)theWorld atLocation:(b2Vec2) location withRadius:(float) radius;

@end

