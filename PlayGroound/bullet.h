//
//  bullet.h
//  PlayGroound
//
//  Created by Jason Parlour on 12-08-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameCharPhysics.h"

@interface bullet : GameCharPhysics {
    b2World *world;
    b2Fixture *sensorFixture;
    float timeTravelled;
    id <PlayGround2LayerDelegate> delegate;
}

@property (nonatomic,readonly) b2Fixture *sensorFixture;
@property (nonatomic, assign) id <PlayGround2LayerDelegate> delegate;

-(id)initWithWorld:(b2World *)theWorld atLoaction:(CGPoint)location;
-(void)updateStateWithDeltaTime:(ccTime)deltaTime;

@end
