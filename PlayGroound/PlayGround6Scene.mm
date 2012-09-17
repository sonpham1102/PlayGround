//
//  PlayGround6Scene.m
//  PlayGroound
//
//  Created by Jason Parlour on 12-09-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayGround6Scene.h"
#import "PlayGround6Layer.h"
#import "PlayGround6UILayer.h"

@implementation PlayGround6Scene
- (id) init
{
    self = [super init];
    if (self != nil)
    {
        PlayGround6Layer *gpLayer = [PlayGround6Layer node];
        [self addChild:gpLayer z:0];
        PlayGround6UILayer *uiLayer = [[[PlayGround6UILayer alloc] initWithGameplayLayer:gpLayer] autorelease];
        [self addChild:uiLayer z:5];
    }
    return self;
}
@end
