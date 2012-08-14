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
#define RM_LINEAR_DAMP 0.65
#define RM_ANG_DAMP 0.85

//#define RM_PAN_IMPULSE_X 1.0
//#define RM_PAN_IMPULSE_Y 2.0
//#define RM_ROCKET_IMPULSE_FACTOR 0.5
#define RM_PAN_TIME_FACTOR 0.5
#define RM_PAN_TIME_MAX 1.0
#define RM_PAN_TIME_MIN 0.1
//#define RM_MAX_ROCKET_IMPULSE 3.0
//#define RM_MIN_ROCKET_IMPULSE 1.0
#define RM_PAN_ROCKET_FORCE 6.0
#define RM_MAX_ROCKET_SLOPE 0.1
#define RM_MIN_ROCKET_SLOPE 0.0

#define RM_TAP_MANEUVER_TIME 1.0
#define RM_TAP_FORCE    6.0
//#define RM_ANG_OFFSET_TOLERANCE 1.0 //degrees, make sure to convert
//#define RM_TAP_TORQUE  1.25
//#define RM_TAP_TORQUE 8.0

#define RM_ROT_FACTOR 180.0 //controls the torque spinning with rotation touch.
#define RM_ROT_COUNTER_SPIN M_PI_2

#define RM_HOLD_MANEUVER_TIME 1.0
#define RM_HOLD_FORCE 12.0
#define RM_HOLD_TORQUE 8.0

@implementation RocketMan

-(void) createRocketManAtLocation: (CGPoint) location
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = b2Vec2(location.x, location.y);
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
    body->SetLinearVelocity(b2Vec2_zero);
    
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
        
        tapManeuverMSec = RM_TAP_MANEUVER_TIME + 1.0f;

        lpManeuverMSec = RM_HOLD_MANEUVER_TIME + 1.0f;
        
        lpContinueFiring = FALSE;
        
        //sound ID's for the maneuvers
        lsSoundID = 0;
        rsSoundID = 0;
        tapSoundID = 0;
        lpSoundID = 0;
        
        rotationAngleDelta = 0.0f;
        
        [self changeState:kStateIdle];
    }
    return self;
}

-(void)planPanMove:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{    
    //calculate the pan vector
    //make sure it's in meters so that everything that comes after should work for each device
    //AP - NO make sure the layer sends in meters, don't want the rocket to have to know about the PTM
    panVector = b2Vec2(endPoint.x - startPoint.x, endPoint.y - startPoint.y);
    
    //convert the vector to the rocket's local coordinate system
    //this way when the rocketman changes orientation, slashes still match up with
    //device geometry
    panVector = body->GetLocalVector(panVector);    
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

-(void) planTapMove:(CGPoint)tapPoint
{
    
}

-(void) executeTapMove
{
    tapManeuverMSec = 0.0f;
    if (tapSoundID == 0)
    {
        tapSoundID = PLAYSOUNDEFFECTLOOPED(ROCKET_JET);
    }
    [self changeState:kStateManeuver];
}

-(void) planLongPressMove:(BOOL) continueFiring
{
    lpContinueFiring = continueFiring;
}

-(void) executeLongPressMove
{
    lpManeuverMSec = 0.0f;
    if (lpSoundID == 0)
    {
        lpSoundID = PLAYSOUNDEFFECTLOOPED(ROCKET_JET);
    }
    [self changeState:kStateManeuver];
}

-(void)fireTapDevice
{
    float force = body->GetMass()*RM_TAP_FORCE;
    
    body->ApplyForce(body->GetWorldVector(b2Vec2(0, force)), body->GetWorldCenter());
    
    // apply a torque in the opposite direction of angular velocity to help straigten it
    //body->ApplyTorque(-body->GetMass() * body->GetAngularVelocity() *RM_TAP_TORQUE);
}

-(void) planRotationMove:(float)angleDelta
{
    rotationAngleDelta = angleDelta;
}

-(void) executeRotationMove
{
    if (rotationAngleDelta != 0.0)
    {        
        [self changeState:kStateManeuver];
    }
    else
    {
        //kill any angular velocity
        body->SetAngularVelocity(0.0);
    }
}

-(void) fireRotationDevice
{

    //for now just apply a torque porportional to the delta if necessary
    float spinTorque = -body->GetMass()*RM_ROT_FACTOR*rotationAngleDelta;
    
    //check if the torque is opposite the current spin velocity
    float direction = spinTorque*body->GetAngularVelocity();
    if (direction < 0)
    {
        float increaseFactor = MIN(ABS(body->GetAngularVelocity())/RM_ROT_COUNTER_SPIN, 1.0f);
        spinTorque *= (1.0f + increaseFactor);
        CCLOG(@"Torque: %.2f, increaseFactor: %.1f", spinTorque, increaseFactor);
    }
    
    body->ApplyTorque(spinTorque);

/*
    body->SetTransform(body->GetPosition(), body->GetAngle() - rotationAngleDelta*2.0);
    body->SetAngularVelocity(0.0f);
*/
}

-(void) fireLPDevice
{
    float force = body->GetMass()*RM_HOLD_FORCE;
    
    body->ApplyForce(body->GetWorldVector(b2Vec2(0, force)), body->GetWorldCenter());
    
    // apply a torque in the opposite direction of angular velocity to help straigten it
    body->ApplyTorque(-body->GetMass() * body->GetAngularVelocity() *RM_HOLD_TORQUE);
    
}

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
            STOPSOUNDEFFECT(tapSoundID);
            tapSoundID = 0;
        }

        lpManeuverMSec += deltaTime;
        if ((lpManeuverMSec < RM_HOLD_MANEUVER_TIME) || lpContinueFiring)
        {
            [self fireLPDevice];
            isManeuvering = TRUE;
        }
        else if (lpSoundID != 0)
        {
            STOPSOUNDEFFECT(lpSoundID);
            lpSoundID = 0;
        }

        //continue firing rotation device
        if (rotationAngleDelta != 0)
        {
            [self fireRotationDevice];
            isManeuvering = TRUE;
        }

    }
    
    body->ApplyForce(body->GetWorldVector(b2Vec2(0.0,body->GetMass()*5.0)), body->GetPosition());
    
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
