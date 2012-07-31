//
//  Rocket.h
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameCharPhysics.h"
#import "Box2DHelpers.h"


@interface Rocket : GameCharPhysics {
    b2World* world;
}

-(void) updateStateWithDeltaTime:(ccTime)deltaTime;
-(id) initWithWorld:(b2World *)theWorld atLocation:(CGPoint)location;
-(void) fireLeftRocket;
-(void) fireRightRocket;

@end
