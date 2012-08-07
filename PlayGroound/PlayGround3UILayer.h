//
//  PlayGround3UILayer.h
//  PlayGroound
//
//  Created by alex on 12-07-30.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCLayer.h"
#import "CustomPanGesureRecognizer.h"

@class PlayGround3Layer;


@interface PlayGround3UILayer : CCLayer <UIGestureRecognizerDelegate>
{
    PlayGround3Layer* gpLayer;
    CGPoint panStartPoint;
    CGPoint panEndPoint;
    CGPoint tapPoint;
    
    float rotStartingAngle;
    
    //pointers to gesture recognizers.  Used in delegate functions
//    UIPanGestureRecognizer* panGestureRecognizer;   
    CustomPanGesureRecognizer* panGestureRecognizer;   
    UITapGestureRecognizer* tapGestureRecognizer;
    UILongPressGestureRecognizer* longPressGestureRecognizer;
    UIRotationGestureRecognizer* rotationsGestureRecognizer;
    
    CCLabelTTF* timerLabel;
    
    bool isGPLayerAcceptingInput;
}

-(id) initWithGameplayLayer:(PlayGround3Layer *)gameplayLayer;


@end
