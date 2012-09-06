//
//  Block.h
//  PlayGroound
//
//  Created by Jason Parlour on 12-09-06.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameCharPhysics.h"

@interface BreakBlock : GameCharPhysics {
    b2World* world;
}

-(id)initWithWorld:(b2World*)theWorld atLocation:(CGPoint)location;

@end
