//
//  RocketMan3.m
//  PlayGroound
//
//  Created by alex on 12-07-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RocketMan3.h"
#import "GameManager.h"
#import "GlobalConstants.h"

//MOVE TO A pLIST
#define RM_DENSITY 5.0f
#define RM_FRICTION 0.5f
#define RM_RESTITUTION 0.5f

#define RM_RADIUS 1.0
#define RM_LINEAR_DAMP 0.5


#define RM_PAN_ROCKET_IMPULSE 10.0
#define RM_PAN_LENGTH_MIN 2.0
#define RM_PAN_LENGTH_MAX 20.0
#define RM_MAX_ROCKET_SLOPE 100.0
#define RM_MIN_ROCKET_SLOPE 0.0
#define RM_PAN_SLOPE_ALLOWANCE 0.7

#define RM_TAP_IMPULSE 30.0

#define RM_ROT_FACTOR 180.0 //controls the torque spinning with rotation touch.
#define RM_ROT_COUNTER_SPIN M_PI_2

#define RM_HOLD_FORCE 5.0


@implementation RocketMan3

-(void) createRocketManAtLocation: (CGPoint) location
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = b2Vec2(location.x, location.y);
    bodyDef.fixedRotation = true;
    body = world->CreateBody(&bodyDef);
    
    b2FixtureDef fixtureDef;
    fixtureDef.density = RM_DENSITY;
    fixtureDef.friction = RM_FRICTION;
    fixtureDef.restitution = RM_RESTITUTION;
    
    b2CircleShape shape;
    shape.m_radius = RM_RADIUS;
    
    fixtureDef.shape = &shape;
        
    body->CreateFixture(&fixtureDef);
    
    body->SetLinearDamping(RM_LINEAR_DAMP);
    body->SetLinearVelocity(b2Vec2_zero);
    body->SetTransform(body->GetPosition(), -M_PI_2);
    
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
        
        lpContinueFiring = FALSE;
        
        //sound ID's for the maneuvers
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
    //the pan maneuver can provide side to side and back to forward impulses, but not front to back
    //front to back pans should be ingnored

    if (panVector.x != 0.0f)
    {
        float slopeAbs = ABS(panVector.y/panVector.x);

        // up in y is legal always
        if (panVector.y >= 0.0f)
        {
            //make sure the slope is legit
            if (slopeAbs < RM_MIN_ROCKET_SLOPE)
            {
                slopeAbs = RM_MIN_ROCKET_SLOPE;
            }
            else if (slopeAbs > RM_MAX_ROCKET_SLOPE)
            {
                slopeAbs = RM_MAX_ROCKET_SLOPE;
            }
        }
        // down in y is bad
        else 
        {
            //illegal move, limit it or discard it
            //if the slope is too high, let's just abort
            if (slopeAbs > RM_PAN_SLOPE_ALLOWANCE)
            {
                //abort
                CCLOG(@"Illegal Pan");
                return;
            }
            else
            {
                slopeAbs = RM_MIN_ROCKET_SLOPE;
            }
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
    }
    //x is zero, straight up or down pan
    else
    {
        if (panVector.y > 0.0f)
        {   
            //up slashes are ok
            //randomly choose a side to interpret the pan
            if (arc4random() % 2)
            {
                panVector.x = panVector.y/RM_MAX_ROCKET_SLOPE;
            }
            else
            {
                panVector.x = panVector.y/RM_MAX_ROCKET_SLOPE;
            }
        }
        else
        {
            //either the pan is straight down or has a zero maginitude, both useless
            return;
        }
    }
    
    
    
    //figure out a multiplier for the impulse based on the length of the slash    
    float increaseFactor = panVector.Normalize();
    
    increaseFactor = MAX(increaseFactor, RM_PAN_LENGTH_MIN);
    increaseFactor = MIN(increaseFactor, RM_PAN_LENGTH_MAX);
    
    increaseFactor = 1.0 + (increaseFactor - RM_PAN_LENGTH_MIN)/(RM_PAN_LENGTH_MAX - RM_PAN_LENGTH_MIN);
    
    //determine if it's the left or right device and set up accordingly
    CCLOG(@"pan factor: %.1f", increaseFactor);
    if (panVector.x >= 0)
    {
        lsManeuverForce.x = panVector.x * body->GetMass()*RM_PAN_ROCKET_IMPULSE * increaseFactor;
        lsManeuverForce.y = panVector.y * body->GetMass()*RM_PAN_ROCKET_IMPULSE * increaseFactor;
        [self fireLSDevice];
    }
    else 
    {
        rsManeuverForce.x = panVector.x * body->GetMass()*RM_PAN_ROCKET_IMPULSE * increaseFactor;
        rsManeuverForce.y = panVector.y * body->GetMass()*RM_PAN_ROCKET_IMPULSE * increaseFactor;
        [self fireRSDevice];
    }
}

-(void)fireLSDevice
{
    body->ApplyLinearImpulse(body->GetWorldVector(lsManeuverForce), body->GetWorldCenter());
}

-(void)fireRSDevice
{
    body->ApplyLinearImpulse(body->GetWorldVector(rsManeuverForce), body->GetWorldCenter());
}

-(void) planTapMove:(CGPoint)tapPoint
{
    
}

-(void) executeTapMove
{
    PLAYSOUNDEFFECT(ROCKET_JET);
    [self fireTapDevice];
}

-(void) planLongPressMove:(BOOL) continueFiring
{
    lpContinueFiring = continueFiring;
}

-(void) executeLongPressMove
{
    if (lpSoundID == 0)
    {
        lpSoundID = PLAYSOUNDEFFECTLOOPED(ROCKET_JET);
    }
    [self changeState:kStateManeuver];
}

-(void)fireTapDevice
{
    body->ApplyLinearImpulse(b2Vec2(body->GetMass()*RM_TAP_IMPULSE, 0.0), body->GetWorldCenter());
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
    b2Vec2 forceVector = body->GetLinearVelocity();

    forceVector.x *= -force;
    forceVector.y *= -force;
    
    body->ApplyForce(forceVector, body->GetWorldCenter());    
}

-(void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects
{
    //see if there are any active maneuvers to finish
    BOOL isManeuvering = FALSE;
    if (characterState == kStateManeuver)
    {
        if (lpContinueFiring)
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
