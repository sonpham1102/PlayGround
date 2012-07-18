//
//  GlobalConstants.h
//  PlayGroound
//
//  Created by alex on 12-07-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

// ONLY constants needed by all levels should go in here

#ifndef PlayGroound_GlobalConstants_h
#define PlayGroound_GlobalConstants_h

#define PTM_RATIO 32
// Used by the GameManager to know which scene (level) to switch to
// Following the lcc2d example, 0 = no level, and menu's all have id's under 100
// The reason for the menu ID range is so that the game manager can check if the level is a menu level or not
// (because if does some screen scaling for menu's
typedef enum
{
    kLevelUnitialized = 0,
    kMainMenu = 1,
    kPlayGround1 = 100,
    kPlayGround2 = 120
} LevelIDs;

// A macro to determine if iPad or not
#ifdef UI_USER_INTERFACE_IDIOM//()
#define IS_IPAD() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#else
#define IS_IPAD() (NO)
#endif

#endif
