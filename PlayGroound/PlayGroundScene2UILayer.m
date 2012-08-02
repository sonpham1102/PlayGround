//
//  PlayGroundScene2UILayer.m
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayGroundScene2UILayer.h"

@implementation PlayGroundScene2UILayer

-(id) init {
    if( (self=[super init])) {
        [self createMenu];
    }
    return self;
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
