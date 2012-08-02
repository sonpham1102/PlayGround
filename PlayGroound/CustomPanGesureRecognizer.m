//
//  CustomPanGesureRecognizer.m
//  PlayGroound
//
//  Created by alex on 12-08-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomPanGesureRecognizer.h"
#define pan_Timeout 1.0

@implementation CustomPanGesureRecognizer

-(BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
    if (([preventingGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])||
        ([preventingGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]))
    {
        return YES;
    }
    else
    {
        return [super canBePreventedByGestureRecognizer:preventingGestureRecognizer];
    }
}

/*
-(void)gesture_Fail
{
    self.state = UIGestureRecognizerStateFailed;
    //self.state = UIGestureRecognizerStateCancelled;
    //self.enabled = FALSE;
    //self.enabled = TRUE;
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    [super touchesBegan:touches withEvent:event];
    
    
    [self performSelector:@selector(gesture_Fail) withObject:nil afterDelay:pan_Timeout];
}
*/

@end
