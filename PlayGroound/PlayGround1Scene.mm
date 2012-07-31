//
//  PlayGround1.mm
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayGround1Scene.h"
#import "PlayGround1Layer.h"
#import "PlayGround1UILayer.h"

@implementation PlayGround1Scene
- (id) init
{
    self = [super init];
    if (self != nil)
    {
        PlayGround1Layer *playGroundLayer = [PlayGround1Layer node];
        [self addChild:playGroundLayer z:0];
        PlayGround1UILayer *playGroundUILayer = [[[PlayGround1UILayer alloc] initWithGameplayLayer:playGroundLayer] autorelease];
        [self addChild:playGroundUILayer z:5];
    }
    return self;
}

@end
