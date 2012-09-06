//
//  PlayGroundScene4UILayer.h
//  PlayGroound
//
//  Created by Jason Parlour on 12-09-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCLayer.h"
//#import "cocos2d.h"
#import "GlobalConstants.h"
//#import "GameManager.h"

@interface PlayGroundScene4UILayer : CCLayer {
    id <PlayGround4LayerDelegate> delegate;
    CCLabelTTF *label;
}

-(void) fuckOff;

-(BOOL)displayText:(NSString *)text andOnCompleteCallTarget:(id)target selector:(SEL)selector;

@property (nonatomic, assign) id <PlayGround4LayerDelegate> delegate;

@end
