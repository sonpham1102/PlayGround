//
//  CustomPanGesureRecognizer.m
//  PlayGroound
//
//  Created by alex on 12-08-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomPanGesureRecognizer.h"

@implementation CustomPanGesureRecognizer

-(BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
    if (([preventingGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])||
        ([preventingGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]))
    {
        return FALSE;
    }
    else
    {
        return [super canBePreventedByGestureRecognizer:preventingGestureRecognizer];
    }
}
@end
