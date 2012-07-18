//
//  GameManager.m
//  PlayGroound
//
//  Created by alex on 12-07-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameManager.h"
#import "cocos2d.h"
#import "MainMenuScene.h"
#import "IntroLayer.h"
#import "PlayGround1Scene.h"
#import "PlayGround2Scene.h"


@implementation GameManager

//the shared gamemanager variable, returned anytime anyone calls [GameManager sharedGameManager]
//static and starts as nil
static GameManager* _sharedGameManager = nil;

//creates the _sharedGameManager (if necessary) and returns a pointer to it
+(GameManager*) sharedGameManager
{
    // the @synchronize directive is used to threadlock this code I think, to prevent multiple threads from trying
    // to create the singleton
    @synchronized ([GameManager class])
    {
        if (!_sharedGameManager)
        {
            [[self alloc] init];
        }
        return _sharedGameManager;
    }
}

+(id) alloc
{
    @synchronized ([GameManager class])
    {
        NSAssert(_sharedGameManager == nil, @"Trying to instantiate a second game manager");
        _sharedGameManager = [super alloc];
        return _sharedGameManager;
    }
    // AP: not sure how this line would ever get called, took it from lcc2d example
    return nil;
}

-(id) init
{
    self = [super init];
    if (self != nil)
    {
        CCLOG(@"Game Manager initialized");
        currentLevel = kLevelUnitialized;
    }
    return self;
}

-(void) runLevelWithID:(LevelIDs)levelID
{
    LevelIDs oldLevel = currentLevel;
    currentLevel = levelID;
    id sceneToRun = nil;
    
    switch (levelID) {
        case kMainMenu:
            sceneToRun = [IntroLayer scene];
            break;
        case kPlayGround1:
            sceneToRun = [PlayGround1Scene node];
            break;
        case kPlayGround2:
            sceneToRun = [PlayGround2Scene node];
            break;
            
        default:
            CCLOG(@"Unknown Level ID, can't change scenes");
            return;
            break;
    }
    
    //see if a new scene was found
    if (sceneToRun == nil)
    {
        //nope, so nothing to do
        currentLevel = oldLevel;
        return;
    }
    
    //Special case Menu code goes here
    if (IS_IPAD())
    {
        
    }
    else 
    {
        
    }
    
    //switch to the new Level's scene
    if ([[CCDirector sharedDirector] runningScene] == nil)
    {
        [[CCDirector sharedDirector] runWithScene:sceneToRun];
   }
    else
    {
        [[CCDirector sharedDirector] replaceScene:sceneToRun];
    }
}

@end
