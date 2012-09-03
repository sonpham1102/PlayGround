//
//  PlayGroundScene4UILayer.m
//  PlayGroound
//
//  Created by Jason Parlour on 12-09-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayGroundScene4UILayer.h"

@implementation PlayGroundScene4UILayer

@synthesize delegate;

-(id) init {
    if( (self=[super init])) {
        [self createMenu];
        CGSize winSize = [CCDirector sharedDirector].winSize;
        label = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt"
                                   fontSize:32.0];
        label.position = ccp(winSize.width/2, winSize.height/2);
        label.visible = NO;
        [self addChild:label];
    }
    return self;
}

-(BOOL)displayText:(NSString *)text andOnCompleteCallTarget:(id)target selector:(SEL)selector {
    [label stopAllActions];
    [label setString:text];
    label.visible = YES;
    label.scale = 0.0;
    label.opacity = 255;
    
    CCScaleTo *scaleUp = [CCScaleTo actionWithDuration:0.5 scale:1.2];
    CCScaleTo *scaleBack = [CCScaleTo actionWithDuration:0.1 scale:1.0];
    CCDelayTime *delay = [CCDelayTime actionWithDuration:2.0];
    //CCFadeOut *fade = [CCFadeOut actionWithDuration:0.5];
    //CCHide *hide = [CCHide action];
    CCCallFuncN *onComplete = [CCCallFuncN actionWithTarget:target
                                                   selector:selector];
    CCSequence *sequence = [CCSequence actions:scaleUp,scaleBack,delay,onComplete, nil];
    [label runAction:sequence];
    return TRUE;
}

-(void) createMenu
{
	// Default font size will be 22 points.
	[CCMenuItemFont setFontSize:22];
	
	// Reset Button
	CCMenuItemLabel *reset = [CCMenuItemFont itemWithString:@"Main Menu" block:^(id sender)
                              {
                                  [[GameManager sharedGameManager] runLevelWithID:kMainMenu];
                              }];
    
	//JP : Not using Achievements and Leader Boards of now
    /*
     // Achievement Menu Item using blocks
     CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:@"Achievements" block:^(id sender) {
     
     
     GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
     achivementViewController.achievementDelegate = self;
     
     AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
     
     [[app navController] presentModalViewController:achivementViewController animated:YES];
     
     [achivementViewController release];
     }];
     
     // Leaderboard Menu Item using blocks
     CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"Leaderboard" block:^(id sender) {
     
     
     GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
     leaderboardViewController.leaderboardDelegate = self;
     
     AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
     
     [[app navController] presentModalViewController:leaderboardViewController animated:YES];
     
     [leaderboardViewController release];
     }];*/
	
    //JP: Removed menu options for Achievments and LeaderBoards, Also Reduced Size of text;
    [reset setScale:0.75f];
	//CCMenu *menu = [CCMenu menuWithItems:itemAchievement, itemLeaderboard, reset, nil];
    CCMenu *menu = [CCMenu menuWithItems:reset, nil];
    
	[menu alignItemsVertically];

    //JP: Repositioned Menu to Upper Right Corner
    //    Should use IPAD Idiom to set properly
	CGSize size = [[CCDirector sharedDirector] winSize];
	[menu setPosition:ccp( size.width*0.9, size.height*0.95)];
	[self addChild: menu z:-1];	
}

-(void) dealloc {
    [super dealloc];
}

@end
