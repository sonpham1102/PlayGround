//
//  GameChar.h
//  PlayGroound
//
//  Created by alex on 12-07-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameObj.h"

@interface GameChar : GameObj
{
    int characterHealth;
    CharStates characterState;
}

-(void)checkAndClampSpritePosition;

@property (readwrite) int characterHealth;
@property (readwrite) CharStates characterState;

@end
