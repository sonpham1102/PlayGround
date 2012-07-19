//
//  Rocket.mm
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Rocket.h"

#define SCALE_FACTOR 0.5f

@implementation Rocket

-(void) createRocketAtLocation:(CGPoint)location {
    
    
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = b2Vec2(location.x/PTM_RATIO,
                              location.y/PTM_RATIO);
    body = world->CreateBody(&bodyDef);
    
    b2FixtureDef fixtureDef;
    fixtureDef.density = 5.0f;
    fixtureDef.friction = 0.5f;
    fixtureDef.restitution = 0.0f;
    
    b2PolygonShape shape;
    
    fixtureDef.shape = &shape;
    
    b2Vec2 vert[] = {
        b2Vec2(SCALE_FACTOR * 0.0 , SCALE_FACTOR * 2.5),
        //b2Vec2(SCALE_FACTOR * -1.0 , SCALE_FACTOR * 2.5),
        b2Vec2(SCALE_FACTOR * -1.0 , SCALE_FACTOR * -0.5),
        b2Vec2(SCALE_FACTOR * 1.0 , SCALE_FACTOR * -0.5),
    };
    
    shape.Set(vert, 3);
    fixtureDef.density = 1.0f;
    body->CreateFixture(&fixtureDef);
    
    b2Vec2 vert1[] = {
        b2Vec2(SCALE_FACTOR * -1.0 , SCALE_FACTOR * 0.5),
        b2Vec2(SCALE_FACTOR * -1.5 , SCALE_FACTOR * 0.5),
        b2Vec2(SCALE_FACTOR * -1.5 , SCALE_FACTOR * -1.75),
        b2Vec2(SCALE_FACTOR * -1.0 , SCALE_FACTOR * -1.75),
    };
    
    shape.Set(vert1, 4);
    
    body->CreateFixture(&fixtureDef);
    
    b2Vec2 vert2[] = {
        b2Vec2(SCALE_FACTOR * 1.5 , SCALE_FACTOR * 0.5),
        b2Vec2(SCALE_FACTOR * 1.0 , SCALE_FACTOR * 0.5),
        b2Vec2(SCALE_FACTOR * 1.0 , SCALE_FACTOR * -1.75),
        b2Vec2(SCALE_FACTOR * 1.5 , SCALE_FACTOR * -1.75),
    };
    
    shape.Set(vert2, 4);
    
    body->CreateFixture(&fixtureDef);
    
    body->SetAngularDamping(10.0f);
    
}

-(void) fireLeftRocket {
    
    b2Vec2 bodyCenter = body->GetWorldCenter();
    b2Vec2 impulse = b2Vec2(0,body->GetMass() * 0.5f);
    b2Vec2 impulseWorld = body->GetWorldPoint(impulse);
    impulseWorld = impulseWorld - bodyCenter;
    b2Vec2 impulsePoint = body->GetWorldPoint(b2Vec2(-1.25 * SCALE_FACTOR,
                                                     /*-1.75*/0.0 * SCALE_FACTOR));
    body->ApplyLinearImpulse(impulseWorld, impulsePoint);
}

-(void) fireRightRocket {
    
    b2Vec2 bodyCenter = body->GetWorldCenter();
    b2Vec2 impulse = b2Vec2(0,body->GetMass() * 0.5f);
    b2Vec2 impulseWorld = body->GetWorldPoint(impulse);
    impulseWorld = impulseWorld - bodyCenter;
    b2Vec2 impulsePoint = body->GetWorldPoint(b2Vec2(1.25 * SCALE_FACTOR,
                                                     /*-1.75*/0.0 * SCALE_FACTOR));
    body->ApplyLinearImpulse(impulseWorld, impulsePoint);
    
}

-(id) initWithWorld:(b2World *)theWorld atLocation:(CGPoint)location {
    
    if ((self = [super init])) {

        world = theWorld;
        [self createRocketAtLocation:location];
    }
    return self;
}

@end
