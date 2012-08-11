//
//  Asteroid.h
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-31.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameCharPhysics.h"

@interface Asteroid : GameCharPhysics {
    b2World *world;
    BOOL isDead;
    id <PlayGround2LayerDelegate> delegate;
    CGPoint explodeLocation;
}

@property (nonatomic, assign) id <PlayGround2LayerDelegate> delegate;

-(id)initWithWorld:(b2World *)theWorld atLoaction:(CGPoint)location;

@end
