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
    
    if (speed > MAX_SPEED) {
        body->ApplyForce(-vel, body->GetLocalCenter());
    } else {
        body->ApplyForce(vel, body->GetLocalCenter());
    }
    
}

-(void)createBodyAtLocation:(CGPoint)location {
    b2BodyDef bodydef;
    bodydef.bullet = true;
    bodydef.fixedRotation = true;
    bodydef.type = b2_dynamicBody;
    bodydef.position = b2Vec2(location.x/PTM_RATIO,
                              location.y/PTM_RATIO);
    body = world->CreateBody(&bodydef);
    
    b2FixtureDef fixtureDef;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.15f;
    fixtureDef.restitution = 1.0f;
    
    b2CircleShape circle;
    circle.m_radius = 0.2;
    fixtureDef.shape = &circle;
    
    body->CreateFixture(&fixtureDef);
    
    body->SetUserData(self);
}
@end
