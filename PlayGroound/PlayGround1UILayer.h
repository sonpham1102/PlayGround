//
//  PlayGround1UILayer.h
//  PlayGroound
//
//  Created by alex on 12-07-30.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCLayer.h"

@class PlayGround1Layer;


@interface PlayGround1UILayer : CCLayer <UIGestureRecognizerDelegate>
{
    PlayGround1Layer* gpLayer;
    CGPoint panStartPoint;
    CGPoint panEndPoint;
    CGPoint tapPoint;
}

-(id) initWithGameplayLayer:(PlayGround1Layer *)gameplayLayer;


@end
