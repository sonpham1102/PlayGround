//
//  RocketMan3.h
//  PlayGroound
//
//  Created by alex on 12-07-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameCharPhysics.h"
#import "SimpleAudioEngine.h"


@interface RocketMan3 : GameCharPhysics
{
    b2World* world;

    //variables for pan planning
    b2Vec2 panVector;
    b2Vec2 lsManeuverForce;
    b2Vec2 rsManeuverForce;

    //sound ID's for the maneuvers
    ALuint lpSoundID;
    
    //for rotation maneuver
    float rotationAngleDelta;
    //for long press maneuver
    BOOL lpContinueFiring;
}

-(id) initWithWorld:(b2World *)theWorld atLocation:(CGPoint)location;
-(void) planPanMove:(CGPoint) startPoint endPoint:(CGPoint) endPoint;
-(void) executePanMove;
-(void) planTapMove:(CGPoint) tapPoint;
-(void) executeTapMove;
-(void) planRotationMove:(float) angleDelta;
-(void) executeRotationMove;
-(void) planLongPressMove:(BOOL) continueFiring;
-(void) executeLongPressMove;
-(void) updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects;

@end
