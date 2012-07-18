//
//  MainMenuScene.m
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainMenuScene.h"

@implementation MainMenuScene

-(id) init
{
    self = [super init];
    if (self != nil)
    {
        mainMenuLayer = [MainMenuLayer node];
        [self addChild:mainMenuLayer];
    }
    return self;
}
@end
