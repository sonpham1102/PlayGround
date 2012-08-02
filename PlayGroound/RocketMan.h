//
//  RocketMan.h
//  PlayGroound
//
//  Created by alex on 12-07-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameCharPhysics.h"
#import "SimpleAudioEngine.h"


@interface RocketMan : GameCharPhysics
{
    b2World* world;

    //variables for pan planning
    b2Vec2 panVector;
    b2Vec2 lsManeuverForce;
    b2Vec2 rsManeuverForce;
    //time trackers for maneuvers in millisec
    float lsManeuverMSec;
    float lsManeuverMSecTarget;
    float rsManeuverMSec;
    float rsManeuverMSecTarget;    
    float tapManeuverMSec;
    //sound ID's for the maneuvers
    ALuint lsSoundID;
    ALuint rsSoundID;
    ALuint tapSoundID;
    ALuint lpSoundID;
    //for rotation maneuver
    float rotationAngleDelta;
    //for longpress maneuver
    float lpManeuverMSec;
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
