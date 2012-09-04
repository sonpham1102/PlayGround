//
//  SceneWithGesture.mm
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SceneWithGestureScene.h"
#import "SceneWithGestureLayer.h"
#import "SceneWithGestureUILayer.h"

@implementation SceneWithGestureScene
- (id) init
{
    self = [super init];
    if (self != nil)
    {
        SceneWithGestureLayer *gpLayer = [SceneWithGestureLayer node];
        [self addChild:gpLayer z:0];
        SceneWithGestureUILayer *uiLayer = [[[SceneWithGestureUILayer alloc] initWithGameplayLayer:gpLayer] autorelease];
        [self addChild:uiLayer z:5];
    }
    return self;
}

@end
