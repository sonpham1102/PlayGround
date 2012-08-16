//
//  PlayGroundScene2UILayer.h
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"
#import "GameManager.h"

@interface PlayGroundScene2UILayer : CCLayer {
    id <PlayGround2LayerDelegate> delegate;
}
@property (nonatomic, assign) id <PlayGround2LayerDelegate> delegate;



@end
