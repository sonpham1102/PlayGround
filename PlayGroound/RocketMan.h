//
//  RocketMan.h
//  PlayGroound
//
//  Created by alex on 12-07-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameCharPhysics.h"

@interface RocketMan : GameCharPhysics
{
    b2World* world;

    //variables for pan planning
    b2Vec2 panImpulse;
}

-(id) initWithWorld:(b2World *)theWorld atLocation:(CGPoint)location;
-(void) planPanMove:(CGPoint) startPoint endPoint:(CGPoint) endPoint;
-(void) executePanMove;
-(void) updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects;

@end
