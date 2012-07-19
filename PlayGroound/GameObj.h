//
//  GameObj.h
//  PlayGroound
//
//  Created by alex on 12-07-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//AP: this class is the starting point for all game objects that have graphics and behaviour
//GameChar (game objects with AI and health) will derive from it

#import "cocos2d.h"
// the object types are in globalconstants
#import "GlobalConstants.h"

@interface GameObj : CCSprite
{
    //each game object has a type
    GameObjType gameObjType;
}
@property (readwrite) GameObjType gameObjType;

// game objects might need to update themselves each frame
-(void) updateStateWithDeltaTime:(ccTime)deltaTime
            andListOfGameObjects:(CCArray*)listOfGameObjects;
// game objects might want to use bounding boxes different from their graphics sizes
-(CGRect) adjustedBoundingBox;
// game objects might have animations
-(CCAnimation*)loadPlistForAnimationWithName:(NSString*)animationName
                                andClassName:(NSString*)className;
@end
