//
//  Rocket.h
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "GlobalConstants.h"
#import "GameCharPhysics.h"
#import "Box2DHelpers.h"


@interface Rocket : GameCharPhysics {
    b2World* world;
    float32 pitchTurn;
    int turnDirection;
    b2Fixture *sensorFixture;
    id <PlayGround2LayerDelegate> delegate;
    BOOL firingLeftRocket;
    BOOL firingRightRocket;
}

@property (nonatomic, readonly) b2Fixture *sensorFixture;
@property (nonatomic, readwrite) float32 pitchTurn;
@property (nonatomic, readwrite) int turnDirection;
@property (nonatomic, assign) id <PlayGround2LayerDelegate> delegate;
@property (nonatomic, readwrite) BOOL firingLeftRocket;
@property (nonatomic, readwrite) BOOL firingRightRocket;

-(void) updateStateWithDeltaTime:(ccTime)deltaTime;
-(id) initWithWorld:(b2World *)theWorld atLocation:(CGPoint)location;
-(void) fireLeftRocket;
-(void) fireRightRocket;
-(void) fireBullet:(ccTime)deltaTime withTarget:(b2Body*)target;

@end
