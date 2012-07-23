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
#define RM_LINEAR_DAMP 2.0
#define RM_ANG_DAMP 2.0

#define RM_PAN_IMPULSE_X 1.0
#define RM_PAN_IMPULSE_Y 2.0

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
    if (startPoint.x < endPoint.x)
    {
        panImpulse = b2Vec2(body->GetMass()*RM_PAN_IMPULSE_X, body->GetMass()*RM_PAN_IMPULSE_Y);
    }
    else 
    {
        panImpulse = b2Vec2(-body->GetMass()*RM_PAN_IMPULSE_X, body->GetMass()*RM_PAN_IMPULSE_Y);
    }        
}

-(void)executePanMove
{
    body->ApplyLinearImpulse(panImpulse, body->GetWorldCenter());
}

@end
