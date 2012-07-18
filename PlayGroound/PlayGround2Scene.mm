//
//  PlayGround2.mm
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayGround2Scene.h"

@implementation PlayGround2Scene

- (id) init
{
    self = [super init];
    if (self != nil)
    {
        PlayGround2Layer *playGroundLayer = [PlayGround2Layer node];
        [self addChild:playGroundLayer z:5];
    }
    return self;
}

@end
