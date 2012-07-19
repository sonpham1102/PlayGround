//
//  GameCharPhysics.h
//  PlayGroound
//
//  Created by alex on 12-07-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameChar.h"
#import "Box2D.h"

@interface GameCharPhysics : GameChar
{
    b2Body *body;
}

@property (assign) b2Body *body;

//return true to accept the mouse joint
//return false to reject the mouse joint
-(BOOL)mouseJointAccept;

@end
