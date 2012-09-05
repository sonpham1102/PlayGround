//
//  Block.h
//  PlayGroound
//
//  Created by Jason Parlour on 12-09-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameCharPhysics.h"

@interface Block : GameCharPhysics {
    b2World* world;
}

-(id)initWithWorld:(b2World*)theWorld atLocation:(CGPoint)location;

@end
