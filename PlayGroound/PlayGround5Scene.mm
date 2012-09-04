//
//  PlayGround5.mm
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayGround5Scene.h"
#import "PlayGround5Layer.h"
#import "PlayGround5UILayer.h"

@implementation PlayGround5Scene
- (id) init
{
    self = [super init];
    if (self != nil)
    {
        PlayGround5Layer *gpLayer = [PlayGround5Layer node];
        [self addChild:gpLayer z:0];
        PlayGround5UILayer *uiLayer = [[[PlayGround5UILayer alloc] initWithGameplayLayer:gpLayer] autorelease];
        [self addChild:uiLayer z:5];
    }
    return self;
}

@end
