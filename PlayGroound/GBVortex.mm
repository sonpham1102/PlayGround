//
//  GBVortex.mm
//  PlayGroound
//
//  Created by alex on 12-09-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GBVortex.h"
#import "Box2DHelpers.h"
#import "GameManager.h"

@implementation GBVortex

#define MAX_LIFE_TIME 3.0
#define VORTEX_RADIUS 5.0

-(void) createAtLocation:(b2Vec2) location
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position = location;
    body = world->CreateBody(&bodyDef);
    
    b2FixtureDef fixtureDef;
    fixtureDef.isSensor = true;
    
    b2CircleShape shape;
    shape.m_radius = VORTEX_RADIUS;
    
    fixtureDef.shape = &shape;
        
    body->CreateFixture(&fixtureDef);
    
    body->SetUserData(self);
    
    PLAYSOUNDEFFECT(VORTEX_SPAWN);
}

-(id) initWithWorld:(b2World *)theWorld atLocation:(b2Vec2)location
{
    if ((self = [super init/*WithFile:@"Default.png"*/])) {
        
        world = theWorld;
        [self createAtLocation:location];
        
        gameObjType = kObjTypeGravityWell;
        
        destroyMe = false;
        
        lifeTimer = 0.0f;
    }
    return self;    
}

-(void)updateStateWithDeltaTime:(ccTime)deltaTime
{
    if (destroyMe)
    {
        return;
    }
    
    lifeTimer += deltaTime;
    if (lifeTimer > MAX_LIFE_TIME)
    {
        destroyMe = true;
        [self setVisible:NO];
        return;
    }
}


@end
