//
//  Ball.m
//  PlayGroound
//
//  Created by Jason Parlour on 12-09-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Ball.h"

#define PTM_RATIO (IS_IPAD() ? (32.0*1024.0/480.0) : 32.0)
#define MAX_SPEED 10
#define BALL_FORCE_MAG 1.25
#define BALL_ANG_DAMP 50.0

@implementation Ball

-(id)initWithWorld:(b2World*)theWorld atLocation:(CGPoint)location {
    if ((self = [super init])){
        world = theWorld;
        gameObjType = kObjTypeBall;
        [self createBodyAtLocation:location];
    }
    return self;
}

-(void)updateStateWithDeltaTime:(ccTime)dt{
    
    b2Vec2 vel = body->GetLinearVelocity();
    
    float speed = vel.Normalize();
    
    b2Vec2 forceVector;
    
    forceVector.x = vel.x*BALL_FORCE_MAG;
    forceVector.y = vel.y*BALL_FORCE_MAG;
    
//    if (forceVector.y == 0.0f) {
//        forceVector.y = 1.0;
//    }
    
    if (speed > MAX_SPEED) {
        body->ApplyForce(-forceVector, body->GetLocalCenter());
    } else {
        body->ApplyForce(forceVector, body->GetLocalCenter());
    }
    
    b2Vec2 gravityForce = b2Vec2(0.0f, -body->GetMass()*2.0);
    
    body->ApplyForce(gravityForce, body->GetWorldCenter());
    
}

-(void)createBodyAtLocation:(CGPoint)location {
    b2BodyDef bodydef;
    bodydef.bullet = true;
    //bodydef.fixedRotation = true;
    bodydef.type = b2_dynamicBody;
    bodydef.position = b2Vec2(location.x/PTM_RATIO,
                              location.y/PTM_RATIO);
    body = world->CreateBody(&bodydef);
    
    b2FixtureDef fixtureDef;
    fixtureDef.density = 0.1f;
    fixtureDef.friction = 0.15f;
    fixtureDef.restitution = 1.0f;
    
    b2CircleShape circle;
    circle.m_radius = 0.2;
    fixtureDef.shape = &circle;
    
    body->CreateFixture(&fixtureDef);
    
    body->SetAngularDamping(BALL_ANG_DAMP);
    
    body->SetUserData(self);
}
@end
