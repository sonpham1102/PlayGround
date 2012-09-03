//
//  SceneWithGestureUILayer.h
//  PlayGroound
//
//  Created by alex on 12-07-30.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCLayer.h"
#import "CustomPanGesureRecognizer.h"

@class SceneWithGestureLayer;


@interface SceneWithGestureUILayer : CCLayer <UIGestureRecognizerDelegate>
{
    SceneWithGestureLayer* gpLayer;
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

-(id) initWithGameplayLayer:(SceneWithGestureLayer *)gameplayLayer;


@end
