//
//  JumperMan.h
//  PlayGroound
//
//  Created by Jason Parlour on 12-09-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalConstants.h"
#import "GameCharPhysics.h"

@interface JumperMan : GameCharPhysics
{
    b2World* world;
    b2Body* head;
    b2Body* torso;
    b2Body* leftUpperArm;
    b2Body* rightUpperArm;
    b2Body* leftLowerArm;
    b2Body* rightLowerArm;
    b2Body* leftUpperLeg;
    b2Body* rightUpperLeg;
    b2Body* leftLowerLeg;
    b2Body* rightLowerLeg;
    float punchTimer;
}

-(id)initWithWorld:(b2World*)theWorld atLocation:(CGPoint)location;

@end
