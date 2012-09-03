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
    if ([itemPassedIn tag] == 1) {
        [[GameManager sharedGameManager] runLevelWithID:kPlayGround1];
    } else if ([itemPassedIn tag] == 2) {
        [[GameManager sharedGameManager] runLevelWithID:kPlayGround2];
    } else if ([itemPassedIn tag] == 3) {
        [[GameManager sharedGameManager] runLevelWithID:kPlayGround3];
    } else if ([itemPassedIn tag] == 4) {
        [[GameManager sharedGameManager] runLevelWithID:kPlayGround4];
    } else if ([itemPassedIn tag] == 5) {
        [[GameManager sharedGameManager] runLevelWithID:kOptionsMenu];
    } else  {
        CCLOG(@"Damn level not found %d",[itemPassedIn tag]);
    }

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

    CCLabelTTF *playScene3Label = [CCLabelTTF labelWithString:@"Level 3"
                                                     fontName:@"Arial-BoldMT"
                                                     fontSize:24.0f];
    CCMenuItemLabel *playScene3 = [CCMenuItemLabel itemWithLabel:playScene3Label target:self
                                                        selector:@selector(playScene:)];
    [playScene3 setTag:3];
    
    CCLabelTTF *playScene4Label = [CCLabelTTF labelWithString:@"Level 4"
                                                      fontName:@"Arial-BoldMT"
                                                      fontSize:24.0f];
    CCMenuItemLabel *playScene4 = [CCMenuItemLabel itemWithLabel:playScene4Label
                                                           target:self 
                                                         selector:@selector(playScene:)];
    [playScene4 setTag:4];

    
    CCLabelTTF *playOptionsScene = [CCLabelTTF labelWithString:@"Options"
                                                      fontName:@"Arial-BoldMT"
                                                      fontSize:24.0f];
    CCMenuItemLabel *playOptions = [CCMenuItemLabel itemWithLabel:playOptionsScene
                                                           target:self 
                                                         selector:@selector(playScene:)];
    [playOptions setTag:5];
    
    
    mainMenu = [CCMenu menuWithItems:playScene1,playScene2,playScene3,playScene4, playOptions, nil];
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
