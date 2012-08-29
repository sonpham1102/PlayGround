//
//  PlayGroundScene4UILayer.h
//  PlayGroound
//
//  Created by Jason Parlour on 12-08-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"
#import "GameManager.h"

@interface PlayGroundScene4UILayer : CCLayer {
    id <PlayGround4LayerDelegate> delegate;
    CCLabelTTF *label;
}

-(BOOL)displayText:(NSString *)text 
andOnCompleteCallTarget:(id)target selector:(SEL)selector;

@property (nonatomic, assign) id <PlayGround4LayerDelegate> delegate;



@end
