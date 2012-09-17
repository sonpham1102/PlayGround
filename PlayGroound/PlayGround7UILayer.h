//
//  PlayGround7UILayer.h
//  PlayGroound
//
//  Created by alex on 12-07-30.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCLayer.h"
#import "CustomPanGesureRecognizer.h"

@class PlayGround7Layer;


@interface PlayGround7UILayer : CCLayer <UIGestureRecognizerDelegate>
{
    PlayGround7Layer* gpLayer;
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

-(id) initWithGameplayLayer:(PlayGround7Layer *)gameplayLayer;


@end
