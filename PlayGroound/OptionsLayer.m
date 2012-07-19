//
//  OptionsLayer.m
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OptionsLayer.h"

@implementation OptionsLayer

-(void)soundEffectsPressed{
    if([[GameManager sharedGameManager] isSoundEffectsON]) {
        [[GameManager sharedGameManager] setIsSoundEffectsON:NO];
    } else {
        [[GameManager sharedGameManager] setIsSoundEffectsON:YES];
    }
}

-(void)musicTogglePressed {
    if ([[GameManager sharedGameManager] isMusicON]) {
		CCLOG(@"OptionsLayer-> Turning Game Music OFF");
		[[GameManager sharedGameManager] setIsMusicON:NO];
        [[GameManager sharedGameManager] stopBackgroundTrack];
	} else {
		CCLOG(@"OptionsLayer-> Turning Game Music ON");
		[[GameManager sharedGameManager] setIsMusicON:YES];
        [[GameManager sharedGameManager] playBackgroundTrack:kOptionsMenu];
	}
}

-(void) returnToMain {
    [[GameManager sharedGameManager] runLevelWithID:kMainMenu];
}
-(id) init {
    self = [super init];
    if (self != nil) {
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        CCLabelTTF *musicOn = [CCLabelTTF labelWithString:@"Music : ON"
                                                         fontName:@"Arial-BoldMT"
                                                         fontSize:24.0f];
        CCLabelTTF *musicOff = [CCLabelTTF labelWithString:@"Music : OFF"
                                                 fontName:@"Arial-BoldMT"
                                                 fontSize:24.0f];
        CCLabelTTF *soundEffectsOn = [CCLabelTTF labelWithString:@"Sound Effects : ON"
                                                 fontName:@"Arial-BoldMT"
                                                 fontSize:24.0f];
        CCLabelTTF *soundEffectsOff = [CCLabelTTF labelWithString:@"Sound Effects : OFF"
                                                  fontName:@"Arial-BoldMT"
                                                  fontSize:24.0f];
        CCLabelTTF *returnToMainMenu = [CCLabelTTF labelWithString:@"Back" 
                                                          fontName:@"Arial-BoldMT"
                                                          fontSize:24.0f];
        CCMenuItemLabel *returnLabel = [CCMenuItemLabel itemWithLabel:returnToMainMenu
                                                               target:self 
                                                             selector:@selector(returnToMain)]; 
        
        CCMenuItemLabel *musicOnLabel = [CCMenuItemLabel itemWithLabel:musicOn target:self selector:nil];
		CCMenuItemLabel *musicOffLabel = [CCMenuItemLabel itemWithLabel:musicOff target:self selector:nil];
        CCMenuItemLabel *soundEffectsOnLabel = [CCMenuItemLabel itemWithLabel:soundEffectsOn target:self 
                                                                     selector:nil];
        CCMenuItemLabel *soundEffectsOffLabel = [CCMenuItemLabel itemWithLabel:soundEffectsOff target:self selector:nil];
        CCMenuItemToggle *soundEffectsToggle = [CCMenuItemToggle itemWithTarget:self
                                                                       selector:@selector(soundEffectsPressed) items:soundEffectsOnLabel,soundEffectsOffLabel, nil];
        
        CCMenuItemToggle *musicToggle = [CCMenuItemToggle itemWithTarget:self 
																selector:@selector(musicTogglePressed) 
																   items:musicOnLabel,musicOffLabel,nil];
        if (![GameManager sharedGameManager].isMusicON) {
            [musicToggle setSelectedIndex:1];
        }
        if (![GameManager sharedGameManager].isSoundEffectsON) {
            [soundEffectsToggle setSelectedIndex:1];
        }
        
        CCMenu *optionsMenu = [CCMenu menuWithItems:musicToggle,soundEffectsToggle, returnLabel, nil];
        
        [optionsMenu alignItemsVerticallyWithPadding:screenSize.height * 0.059f];
        [optionsMenu setPosition:ccp(screenSize.width/2, screenSize.height/2)];
        
        [self addChild:optionsMenu z:0];
    }
    return self;
}

@end
