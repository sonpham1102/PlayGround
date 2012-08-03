//
//  Box2DHelpers.h
//  SpaceViking
//
//  Created by Ray Wenderlich on 3/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Box2D.h"
#import "GlobalConstants.h"

bool isBodyCollidingWithObjectType(b2Body *body, 
                                   GameObjType objectType);
bool isSensorCollidingWithObjectType(b2Body *body, 
                                     GameObjType objectType,
                                     b2Fixture* fixture);