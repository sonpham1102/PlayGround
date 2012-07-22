//
//  Obstale.h
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameCharPhysics.h"

@interface Obstacle : GameCharPhysics {
    b2World *world;
}

-(id)initWithWorld:(b2World *)theWorld atLoaction:(CGPoint)location;

@end
