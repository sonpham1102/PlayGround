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

@end
