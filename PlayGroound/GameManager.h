//
//  GameManager.h
//  PlayGroound
//
//  Created by alex on 12-07-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalConstants.h"

@interface GameManager : NSObject
{
    LevelIDs currentLevel;
}

+(GameManager*)sharedGameManager;
-(void) runLevelWithID:(LevelIDs) levelID; 

@end
