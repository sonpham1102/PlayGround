//
//  Paddle.h
//  PlayGroound
//
//  Created by Jason Parlour on 12-09-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameCharPhysics.h"

@interface Paddle : GameCharPhysics {
    b2World* world;
    id<PlayGround4LayerDelegate> delegate;
}

@property (nonatomic, assign) id <PlayGround4LayerDelegate> delegate;

-(id)initWithWorld:(b2World*)theWorld atLocation:(CGPoint)location;

@end
