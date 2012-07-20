//
//  RocketMan.h
//  PlayGroound
//
//  Created by alex on 12-07-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameCharPhysics.h"

@interface RocketMan : GameCharPhysics
{
    b2World* world;
}

-(id) initWithWorld:(b2World *)theWorld atLocation:(CGPoint)location;

@end
