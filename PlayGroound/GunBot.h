//
//  GunBot.h
//  PlayGroound
//
//  Created by alex on 12-09-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameCharPhysics.h"

@interface GunBot : GameCharPhysics
{
    b2World* world;
    float spinTimer;
    float spinDirection;
}

-(id) initWithWorld:(b2World *)theWorld atLocation:(CGPoint)location;
-(void) setSpinDirection:(float) direction;

@end
