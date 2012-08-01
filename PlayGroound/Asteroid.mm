//
//  Asteroid.mm
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-31.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Asteroid.h"

@implementation Asteroid

-(void)createBodyAtLocation:(CGPoint)location {
    
    //CGSize winSize = [CCDirector sharedDirector].winSize;
    float32 size = arc4random()%50;
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = b2Vec2(location.x/PTM_RATIO,location.y/PTM_RATIO);
    
    body = world->CreateBody(&bodyDef);
    
    b2CircleShape shape;
    shape.m_radius = size / PTM_RATIO;
    shape.m_p = b2Vec2(0,0);
    
    b2FixtureDef fixtureDef;
    fixtureDef.density = 1500.0;
    fixtureDef.shape = &shape;
    fixtureDef.restitution = 1.0;
    fixtureDef.friction = 0.0;
    
    body->CreateFixture(&fixtureDef);
    
    body->SetUserData(self);
    
    float32 direction = body->GetPosition().x;
    if (direction > 40) {
        direction = -1.0;
    } else {
        direction = 1.0;
    }
    

    b2Vec2 impulse = b2Vec2(body->GetMass() * 200.0f * direction,0);
    body->ApplyForce(impulse, body->GetWorldCenter()); 

}

-(id) initWithWorld:(b2World *)theWorld atLoaction:(CGPoint)location {
    if ((self = [super init])) {
        world = theWorld;
        gameObjType = kObjTypeAsteroid;
        [self createBodyAtLocation:location];
    }
    return self;
}

@end
