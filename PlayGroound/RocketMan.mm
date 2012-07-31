//
//  RocketMan.m
//  PlayGroound
//
//  Created by alex on 12-07-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RocketMan.h"
#import "GameManager.h"
#import "GlobalConstants.h"

//MOVE TO A pLIST
#define RM_DENSITY 5.0f
#define RM_FRICTION 0.5f
#define RM_RESTITUTION 1.0f
#define RM_VERT1 b2Vec2(0.3,1.0)
#define RM_VERT2 b2Vec2(-0.3,1.0)
#define RM_VERT3 b2Vec2(-0.5,-1.0)
#define RM_VERT4 b2Vec2(0.5,-1.0)
#define RM_LINEAR_DAMP 0.5
#define RM_ANG_DAMP 2.0

//#define RM_PAN_IMPULSE_X 1.0
//#define RM_PAN_IMPULSE_Y 2.0
//#define RM_ROCKET_IMPULSE_FACTOR 0.5
#define RM_PAN_TIME_FACTOR 0.5
#define RM_PAN_TIME_MAX 1.5
#define RM_PAN_TIME_MIN 0.2
//#define RM_MAX_ROCKET_IMPULSE 3.0
//#define RM_MIN_ROCKET_IMPULSE 1.0
#define RM_PAN_ROCKET_FORCE 2.0
#define RM_MAX_ROCKET_SLOPE 10.0
#define RM_MIN_ROCKET_SLOPE 1

#define RM_TAP_MANEUVER_TIME 2.0

@implementation RocketMan

-(void) createRocketManAtLocation: (CGPoint) location
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = b2Vec2(location.x/PTM_RATIO,
                              location.y/PTM_RATIO);
    body = world->CreateBody(&bodyDef);
    
    b2FixtureDef fixtureDef;
    fixtureDef.density = RM_DENSITY;
    fixtureDef.friction = RM_FRICTION;
    fixtureDef.restitution = RM_RESTITUTION;
    
    b2PolygonShape shape;
    
    fixtureDef.shape = &shape;
    
    b2Vec2 verts[]={RM_VERT1,RM_VERT2, RM_VERT3, RM_VERT4};
    
    shape.Set(verts, 4);
    
    body->CreateFixture(&fixtureDef);
    
    body->SetAngularDamping(RM_ANG_DAMP);
    body->SetLinearDamping(RM_LINEAR_DAMP);
    
    body->SetUserData(self);
}

-(id) initWithWorld:(b2World *)theWorld atLocation:(CGPoint)location {
    
    if ((self = [super init/*WithFile:@"Default.png"*/])) {
        
        world = theWorld;
        [self createRocketManAtLocation:location];
        //[self setScale:0.25];
        
        panVector = b2Vec2_zero;
        lsManeuverForce = b2Vec2_zero;
        rsManeuverForce = b2Vec2_zero;

        lsManeuverMSecTarget = -1.0f;
        rsManeuverMSecTarget = -1.0f;
        
        lsManeuverMSec = 0.0f;
        rsManeuverMSec = 0.0f;
        
        tapManeuverMSec = 0.0f;

        //sound ID's for the maneuvers
        lsSoundID = 0;
        rsSoundID = 0;
        tapSoundID = 0;
        
        [self changeState:kStateIdle];
    }
    return self;
}

/* AP: IMPULSE VERSION, replaced by Force version below
-(void)planPanMove:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{    
    //calculate the impluse vector
    b2Vec2 impulseVector = b2Vec2((endPoint.x - startPoint.x)/PTM_RATIO, (endPoint.y - startPoint.y)/PTM_RATIO);
    
    //For now, make the magnitude proportional to the square of the pan length
    float impulseMag = impulseVector.LengthSquared()*RM_ROCKET_IMPULSE_FACTOR;
    
    if (impulseMag > RM_MAX_ROCKET_IMPULSE)
    {
        CCLOG(@"MAX: %.2f (%.2f)", impulseMag, impulseVector.LengthSquared());
        impulseMag = RM_MAX_ROCKET_IMPULSE;
    }
    else if (impulseMag < RM_MIN_ROCKET_IMPULSE)
    {
        CCLOG(@"MIN: %.2f (%.2f)", impulseMag, impulseVector.LengthSquared());
        impulseMag = RM_MIN_ROCKET_IMPULSE;
    }
    
    //limit the angle of the impulse
    float slopeAbs;
    if (impulseVector.x !=0)
    {
        slopeAbs = ABS(impulseVector.y/impulseVector.x);
        if (slopeAbs < RM_MIN_ROCKET_SLOPE)
        {
            slopeAbs = RM_MIN_ROCKET_SLOPE;
        }
        else if (slopeAbs > RM_MAX_ROCKET_SLOPE)
        {
            slopeAbs = RM_MAX_ROCKET_SLOPE;
        }
    }
    else
    {
        slopeAbs = RM_MAX_ROCKET_SLOPE;
    }

    //rebuild the implulseVector based on the magnitude and the slope
    if (startPoint.x < endPoint.x)
    {           
        // moving from left to right
        panImpulse.x = 1.0f;
    }
    else 
    {
        panImpulse.x = -1.0f;
    }
    panImpulse.y = slopeAbs;
    panImpulse.Normalize();
    panImpulse.x *= body->GetMass()*impulseMag;
    panImpulse.y *= body->GetMass()*impulseMag;    
}
*/

-(void)planPanMove:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{    
    //calculate the pan vector
    //make sure it's in meters so that everything that comes after should work for each device
    panVector = b2Vec2((endPoint.x - startPoint.x)/PTM_RATIO, (endPoint.y - startPoint.y)/PTM_RATIO);
    
}

-(void)executePanMove
{
    //limit the angle of the impulse
    float slopeAbs;
    if (panVector.x !=0)
    {
        slopeAbs = ABS(panVector.y/panVector.x);
        if (slopeAbs < RM_MIN_ROCKET_SLOPE)
        {
            slopeAbs = RM_MIN_ROCKET_SLOPE;
        }
        else if (slopeAbs > RM_MAX_ROCKET_SLOPE)
        {
            slopeAbs = RM_MAX_ROCKET_SLOPE;
        }
    }
    else
    {
        slopeAbs = RM_MAX_ROCKET_SLOPE;
    }
    
    //rebuild the panVector based on the slope
    if (panVector.x >=0)
    {           
        // moving from left to right
        panVector.y = panVector.x * slopeAbs;
    }
    else 
    {
        panVector.y = -panVector.x * slopeAbs;
    }
    
    
    //the magnitude of the force is fixed
    // the amount of time the force is to be applied depends on the length
    float timeToFire = panVector.Normalize() * RM_PAN_TIME_FACTOR;
    
    if (timeToFire > RM_PAN_TIME_MAX)
    {
        CCLOG(@"MAX: %.2f (%.2f)", RM_PAN_TIME_MAX, timeToFire);
        timeToFire = RM_PAN_TIME_MAX;
    }
    else if (timeToFire < RM_PAN_TIME_MIN)
    {
        CCLOG(@"MIN: %.2f (%.2f)", RM_PAN_TIME_MIN, timeToFire);
        timeToFire = RM_PAN_TIME_MIN;
    }
    
    //determine if it's the left or right device and set up accordingly
    if (panVector.x >= 0)
    {
        lsManeuverMSec = 0.0f;
        lsManeuverMSecTarget = timeToFire;
        lsManeuverForce.x = panVector.x * body->GetMass()*RM_PAN_ROCKET_FORCE;
        lsManeuverForce.y = panVector.y * body->GetMass()*RM_PAN_ROCKET_FORCE;
        if (lsSoundID == 0)
        {
            lsSoundID = PLAYSOUNDEFFECTLOOPED(ROCKET_JET);        
        }
    }
    else 
    {
        rsManeuverMSec = 0.0f;
        rsManeuverMSecTarget = timeToFire;
        rsManeuverForce.x = panVector.x * body->GetMass()*RM_PAN_ROCKET_FORCE;
        rsManeuverForce.y = panVector.y * body->GetMass()*RM_PAN_ROCKET_FORCE;
        if (rsSoundID == 0)
        {
            rsSoundID = PLAYSOUNDEFFECTLOOPED(ROCKET_JET);
        }
    }
    [self changeState:kStateManeuver];
}

-(void)fireLSDevice
{
    body->ApplyForce(body->GetWorldVector(lsManeuverForce), body->GetWorldCenter());
}

-(void)fireRSDevice
{
    body->ApplyForce(body->GetWorldVector(rsManeuverForce), body->GetWorldCenter());
}

-(void)fireTapDevice
{
    
}

-(void) planTapMove
{
    
}

//-(void) executePanMove

-(void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects
{
    //see if there are any active maneuvers to finish
    BOOL isManeuvering = FALSE;
    if (characterState == kStateManeuver)
    {
        //continue firing left slash device
        lsManeuverMSec += deltaTime;
        if (lsManeuverMSec < lsManeuverMSecTarget)
        {
            [self fireLSDevice];
            isManeuvering = TRUE;
        }
        else if (lsSoundID != 0)
        {
            STOPSOUNDEFFECT(lsSoundID);
            lsSoundID = 0;
        }
        
        //continue firing right slash device
        rsManeuverMSec += deltaTime;
        if (rsManeuverMSec < rsManeuverMSecTarget)
        {
            [self fireRSDevice];
            isManeuvering = TRUE;
        }
        else if (rsSoundID != 0)
        {
            STOPSOUNDEFFECT(rsSoundID);
            rsSoundID = 0;
        }
        
        //continue firing tap device
        tapManeuverMSec += deltaTime;
        if (tapManeuverMSec < RM_TAP_MANEUVER_TIME)
        {
            [self fireTapDevice];
            isManeuvering = TRUE;
        }
        else if (tapSoundID != 0)
        {
            STOPSOUNDEFFECT(rsSoundID);
            tapSoundID = 0;
        }
    }
    
    if(!isManeuvering)
    {
        [self changeState:kStateIdle];
    }
    
}

-(void) changeState:(CharStates)newState
{
    [self setCharacterState:newState];
}

@end
