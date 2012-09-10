//
//  PlayGround5UILayer.h
//  PlayGroound
//
//  Created by alex on 12-07-30.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCLayer.h"
#import "CustomPanGesureRecognizer.h"

@class PlayGround5Layer;


@interface PlayGround5UILayer : CCLayer <UIGestureRecognizerDelegate>
{
    PlayGround5Layer* gpLayer;
    
    float rotStartingAngle;
    
    //pointers to gesture recognizers.  Used in delegate functions
    CustomPanGesureRecognizer* panGestureRecognizer;   
    UITapGestureRecognizer* tapGestureRecognizer;
    UILongPressGestureRecognizer* longPressGestureRecognizer;
    UIRotationGestureRecognizer* rotationsGestureRecognizer;
    
    CustomPanGesureRecognizer* twoTouchPanGestureRecognizer;

}

-(id) initWithGameplayLayer:(PlayGround5Layer *)gameplayLayer;


@end
