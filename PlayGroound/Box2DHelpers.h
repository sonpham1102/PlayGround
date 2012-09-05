//
//  Box2DHelpers.h
//  SpaceViking
//
//  Created by Ray Wenderlich on 3/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Box2D.h"
#import "GameCharPhysics.h"
#import "GlobalConstants.h"

GameCharPhysics* isBodyCollidingWithObjectType(b2Body *body, 
                                   GameObjType objectTyp);
b2Body* isSensorCollidingWithObjectType(b2Body *body, 
                                     GameObjType objectType,
                                     b2Fixture* fixturee,
                                     b2World *world);
bool isBodyCollidingWithAnything(b2Body *body);