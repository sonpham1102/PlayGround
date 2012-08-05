//
//  GameCharPhysics.m
//  PlayGroound
//
//  Created by alex on 12-07-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameCharPhysics.h"

@implementation GameCharPhysics
@synthesize body;
@synthesize destroyMe;

//OVERRIDE if necessary
-(BOOL)mouseJointAccept
{
    return TRUE;
}

@end
