//
//  PlayGroundScene4UILayer.h
//  PlayGroound
//
//  Created by Jason Parlour on 12-09-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"
#import "GameManager.h"

@interface PlayGroundScene4UILayer : CCLayer {
    id <PlayGround4LayerDelegate> delegate;
    CCLabelTTF *label;
}

@property (nonatomic, assign) id <PlayGround4LayerDelegate> delegate;

@end
