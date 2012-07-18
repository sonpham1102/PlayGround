//
//  MainMenuLayer.m
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainMenuLayer.h"


@implementation MainMenuLayer


-(void) playScene:(CCMenuItemFont*)itemPassedIn
{
    CCLOG(@"Should load Scene %d",[itemPassedIn tag]);
}

-(void) displayMenu {
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    CCLabelTTF *playScene1Label = [CCLabelTTF labelWithString:@"Level 1"
                                                     fontName:@"Arial-BoldMT"
                                                     fontSize:24.0f];
    CCMenuItemLabel *playScene1 = [CCMenuItemLabel itemWithLabel:playScene1Label target:self
                                                        selector:@selector(playScene:)];
    [playScene1 setTag:1];
    
    CCLabelTTF *playScene2Label = [CCLabelTTF labelWithString:@"Level 2"
                                                     fontName:@"Arial-BoldMT"
                                                     fontSize:24.0f];
    CCMenuItemLabel *playScene2 = [CCMenuItemLabel itemWithLabel:playScene2Label target:self
                                                        selector:@selector(playScene:)];
    [playScene2 setTag:2];  
    
    
    mainMenu = [CCMenu menuWithItems:playScene1,playScene2, nil];
    [mainMenu alignItemsVerticallyWithPadding:screenSize.height * 0.059f];
    [mainMenu setPosition:ccp(screenSize.width/2, screenSize.height/2)];
    
    [self addChild:mainMenu z:0];
}

-(id) init
{
    self = [super init];
    if (self != nil)
    {
        [self displayMenu];
    }
    return self;
}
@end
