//
//  PlayGround6UILayer.h
//  PlayGroound
//
//  Created by Jason Parlour on 12-09-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCLayer.h"
#import "CustomPanGesureRecognizer.h"

@class PlayGround6Layer;

@interface PlayGround6UILayer : CCLayer <UIGestureRecognizerDelegate>
{
    PlayGround6Layer* gpLayer;
    CGPoint panStartPoint;
    CGPoint panEndPoint;
    CGPoint tapPoint;
    
    float rotStartingAngle;
    
    //pointers to gesture recognizers.  Used in delegate functions
    CustomPanGesureRecognizer* panGestureRecognizer;   
    UITapGestureRecognizer* tapGestureRecognizer;
    UILongPressGestureRecognizer* longPressGestureRecognizer;
    UIRotationGestureRecognizer* rotationsGestureRecognizer;
    
}

-(id) initWithGameplayLayer:(PlayGround6Layer *)gameplayLayer;

@end
