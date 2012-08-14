//
//  Missle.h
//  PlayGroound
//
//  Created by Jason Parlour on 12-08-14.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameCharPhysics.h"
#import "GlobalConstants.h"
#import "Asteroid.h"

@interface Missle : GameCharPhysics {
    b2World *world;
    Asteroid *target;
    BOOL isDead;
    float timeTravelled;
    id <PlayGround2LayerDelegate> delegate;
}

@property (nonatomic,assign) Asteroid *target;
@property (nonatomic, assign) id <PlayGround2LayerDelegate> delegate;

-(id) initWithWorld:(b2World *)theWorld atLoaction:(b2Vec2)location withTarget:(b2Body*)myTarget;

@end
