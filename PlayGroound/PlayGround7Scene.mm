//
//  PlayGround7.mm
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayGround7Scene.h"
#import "PlayGround7Layer.h"
#import "PlayGround7UILayer.h"

@implementation PlayGround7Scene
- (id) init
{
    self = [super init];
    if (self != nil)
    {
        PlayGround7Layer *gpLayer = [PlayGround7Layer node];
        [self addChild:gpLayer z:0];
        PlayGround7UILayer *uiLayer = [[[PlayGround7UILayer alloc] initWithGameplayLayer:gpLayer] autorelease];
        [self addChild:uiLayer z:5];
    }
    return self;
}

@end
