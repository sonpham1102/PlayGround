//
//  PlayGround4Scene.m
//  PlayGroound
//
//  Created by Jason Parlour on 12-09-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayGround4Scene.h"

@implementation PlayGround4Scene

- (id) init
{
    self = [super init];
    if (self != nil)
    {
        PlayGroundScene4UILayer *uiLayer = [PlayGroundScene4UILayer node];
        [self addChild:uiLayer z:10];
        PlayGround4Layer *playGroundLayer = [[[PlayGround4Layer alloc] initWithUILayer:uiLayer]autorelease];
        [self addChild:playGroundLayer z:5];
        [uiLayer setDelegate:playGroundLayer];
    }
    return self;
}

@end
