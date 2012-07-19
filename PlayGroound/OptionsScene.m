//
//  OptionsScene.m
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OptionsScene.h"

@implementation OptionsScene

- (id) init
{
    self = [super init];
    if (self != nil)
    {
        OptionsLayer *optionsLayer = [OptionsLayer node];
        [self addChild:optionsLayer z:5];
    }
    return self;
}
@end
