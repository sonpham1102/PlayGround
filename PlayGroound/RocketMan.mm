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

#import "PlayGround1Layer.h" //mainly for the PTM_RATIO

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

#define RM_ROT_FACTOR 150.0 //controls the torque spinning with rotation touch.
#define RM_ROT_COUNTER_SPIN M_PI_2

#define RM_HOLD_MANEUVER_TIME 1.0
#define RM_HOLD_FORCE 12.0
#define RM_HOLD_TORQUE 8.0

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
/*
-(void)fireTapDevice
{
    //this device does 2 things - fires the rear rocket but also tries to get the rocket aligned straight up
    
 
    float angle = body->GetAngle();
    float angularVelocity = body->GetAngularVelocity();
    float torque = 0.0f;
    float force = 0.0f;
    
    //first make sure the angle is between -180 and 180
    //see how many full rotations we have
    int rotations = angle / (M_PI * 2);
    //subtract them out
    angle -= (float) rotations * M_PI * 2;
    //if the angle is above 180 degress, subtract PI
    if (angle > M_PI)
    {
        angle -= M_PI*2;
    }
    else if (angle < -M_PI)
    {
        angle += M_PI*2;
    }
    
    float direction = 1.0f;
    
    if (angle > 0)
    {
        direction = -1.0f;
    }
    
    // see if the angle is zero, but there is angular velocity
    if (angle == 0.0f)
    {
        if (ABS(angularVelocity) > 0)
        {
            //kill the velocity
            body->SetAngularVelocity(0.0f);
        }
        force = body->GetMass()*RM_TAP_FORCE;
    }
    // see if the angle is close enough to zero
    else if (ABS(angle) < CC_DEGREES_TO_RADIANS(RM_ANG_OFFSET_TOLERANCE))
    {
        // set it to zero and kill any angular velocity
        body->SetTransform(body->GetPosition(), 0.0f);        
        body->SetAngularVelocity(0.0f);
        angle = 0.0f;
    }
    else if (ABS(angle) > M_PI_2)
    {
        // if the angle is greater than 90 degrees (M_PI_2), then use the max torque
        torque = body->GetMass() * RM_TAP_TORQUE;
        force = 0.0f;
    }
    else
    {
        torque = body->GetMass() * RM_TAP_TORQUE * ABS(angle)/M_PI_2;
        // only fire the rear rocket if the angle is less that 45 degrees
        if (ABS(angle) > M_PI_4)
        {
            force = 0.0f;
        }
        else
        {
            force = body->GetMass() * RM_TAP_FORCE * ABS(angle)/M_PI_4;
        }
    }
    
    //see if the angle and angular velocity are in the same directions and bigger than 45 degrees
    if ((ABS(angle) > M_PI_4) && (angle * angularVelocity > 0)) 
    {
        
        //normally the impulse should be in the opposite direction of the angle
        //but if the current velocity is already in the same direction and the angle
        //flip all the way around at full speed
//        impulse = body->GetMass() * RM_TAP_IMPULSE*2;
//        direction *= -1.0;
//        force = 0.0f;
//AP: ok being too clever, works fine without and hard to get right with        
    }
    
    body->ApplyForce(body->GetWorldVector(b2Vec2(0, force)), body->GetWorldCenter());
    
    body->ApplyTorque(torque * direction);
}
*/

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
    [self changeState:kStateManeuver];
}

-(void) fireRotationDevice
{
    //for now just apply a torque porportional to the delta if necessary
    float spinTorque = -body->GetMass()*RM_ROT_FACTOR*rotationAngleDelta;
    
    //check if the torque is opposite the current spin velocity
    float direction = spinTorque*body->GetAngularVelocity();
    if (direction < 0)
    {
        float increaseFactor = MIN(ABS(body->GetAngularVelocity()/RM_ROT_COUNTER_SPIN), 1.0f);
        spinTorque *= (1.0f + increaseFactor);
    }
    
    body->ApplyTorque(spinTorque);
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
