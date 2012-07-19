//
//  GameChar.m
//  PlayGroound
//
//  Created by alex on 12-07-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameChar.h"

@implementation GameChar

@synthesize characterHealth;
@synthesize characterState;

-(void) dealloc
{
    [super dealloc];
}

-(void)checkAndClampSpritePosition
{
    CGPoint currentSpritePosition = [self position];
    
    //CGSize levelSize = [[GameManager sharedGameManager] getDimensionsOfCurrentScene];
    CGSize levelSize = [[CCDirector sharedDirector] winSize];
    
    float xOffset;
    
    if (IS_IPAD())
    {
        xOffset = 30.0f;
    }
    else 
    {
        xOffset = 24.0f;
    }
    
    if (currentSpritePosition.x < xOffset)
    {
        [self setPosition:ccp(xOffset, currentSpritePosition.y)];
    }
    else if (currentSpritePosition.x > (levelSize.width - xOffset))
    {
        [self setPosition:ccp(levelSize.width - xOffset, currentSpritePosition.y)];
    }
}

@end
