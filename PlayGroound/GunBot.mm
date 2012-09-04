//
//  GunBot.m
//  PlayGroound
//
//  Created by alex on 12-09-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GunBot.h"

#define GB_DENSITY 1.0
#define GB_FRICTION 1.0
#define GB_RESTITUTION 1.0
#define GB_RADIUS 1.0
#define GB_LINEAR_DAMP 1.0

@implementation GunBot

-(void) createGunBotAtLocation:(CGPoint) location
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = b2Vec2(location.x, location.y);
    body = world->CreateBody(&bodyDef);
    
    b2FixtureDef fixtureDef;
    fixtureDef.density = GB_DENSITY;
    fixtureDef.friction = GB_FRICTION;
    fixtureDef.restitution = GB_RESTITUTION;
    
    b2CircleShape shape;
    shape.m_radius = GB_RADIUS;
    
    fixtureDef.shape = &shape;
    
    // make sure it doesn't collide with it's own bullets
    fixtureDef.filter.groupIndex = -1;
    
    body->CreateFixture(&fixtureDef);
    
    body->SetLinearDamping(GB_LINEAR_DAMP);
    body->SetLinearVelocity(b2Vec2_zero);
    
    body->SetUserData(self);
}

// location should be in meters (not points)
-(id) initWithWorld:(b2World *)theWorld atLocation:(CGPoint)location
{
    if ((self = [super init/*WithFile:@"Default.png"*/])) {
        
        world = theWorld;
        [self createGunBotAtLocation:location];
                
        gameObjType = kObjTypeGunBot;
    }
    return self;
}


@end
