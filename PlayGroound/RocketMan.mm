//
//  RocketMan.m
//  PlayGroound
//
//  Created by alex on 12-07-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RocketMan.h"

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
#define RM_ROCKET_IMPULSE_FACTOR 0.5
#define RM_MAX_ROCKET_IMPULSE 3.0
#define RM_MIN_ROCKET_IMPULSE 1.0
#define RM_MAX_ROCKET_SLOPE 10.0
#define RM_MIN_ROCKET_SLOPE 1

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
        panImpulse = b2Vec2_zero;
    }
    return self;
}

-(void)planPanMove:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{    
    //calculate the impluse vector
    b2Vec2 impulseVector = b2Vec2((endPoint.x - startPoint.x)/PTM_RATIO, (endPoint.y - startPoint.y)/PTM_RATIO);
    
    //For now, make the impulse magnitude proportional to the square of the pan length
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

-(void)executePanMove
{
    body->ApplyLinearImpulse(body->GetWorldVector(panImpulse), body->GetWorldCenter());
}

@end
