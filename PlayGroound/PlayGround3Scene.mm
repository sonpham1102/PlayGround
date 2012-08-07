//
//  PlayGround3.mm
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayGround3Scene.h"
#import "PlayGround3Layer.h"
#import "PlayGround3UILayer.h"

@implementation PlayGround3Scene
- (id) init
{
    self = [super init];
    if (self != nil)
    {
        PlayGround3Layer *playGroundLayer = [PlayGround3Layer node];
        [self addChild:playGroundLayer z:0];
        PlayGround3UILayer *playGroundUILayer = [[[PlayGround3UILayer alloc] initWithGameplayLayer:playGroundLayer] autorelease];
        [self addChild:playGroundUILayer z:5];
    }
    return self;
}

@end
