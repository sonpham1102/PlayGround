//
//  GBBullet.m
//  PlayGroound
//
//  Created by alex on 12-09-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GBBullet.h"
#import "Box2DHelpers.h"
#import "GameManager.h"

@implementation GBBullet

#define BULLET_DENSITY 1.0
#define BULLET_RESTITION 1.0
#define BULLET_FRICTION 0.0
#define BULLET_RADIUS 0.2
#define MAX_LIFE_TIME 5.0

-(void) createAtLocation:(b2Vec2) location withVelocity:(b2Vec2) velocity
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = location;
    bodyDef.bullet = true;
    body = world->CreateBody(&bodyDef);
    
    b2FixtureDef fixtureDef;
    fixtureDef.density = BULLET_DENSITY;
    fixtureDef.friction = BULLET_FRICTION;
    fixtureDef.restitution = BULLET_RESTITION;
    
    b2CircleShape shape;
    shape.m_radius = BULLET_RADIUS;
    
    fixtureDef.shape = &shape;
    
    // make sure the bullets don't collide with the GunBot
    //fixtureDef.filter.groupIndex = kGunBotBulletGroup;
    fixtureDef.filter.categoryBits = kCollCatBullet;
    fixtureDef.filter.maskBits = kCollMaskBullet;
    
    body->CreateFixture(&fixtureDef);
    
    body->SetLinearDamping(0.0);
    
    body->SetLinearVelocity(velocity);
    
    body->SetUserData(self);
    
    PLAYSOUNDEFFECT(FIRE_GUN);
}

-(id) initWithWorld:(b2World *)theWorld atLocation:(b2Vec2)location withVelocity:(b2Vec2) velocity
{
    if ((self = [super init/*WithFile:@"Default.png"*/])) {
        
        world = theWorld;
        [self createAtLocation:location withVelocity:velocity];
        
        gameObjType = kObjTypeBullet;
        
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
    else
    {
        // see if it hits anything and destroy it
        if (isBodyCollidingWithAnything(body))
        {
            destroyMe = true;
            [self setVisible:NO];
        }
    }
}

@end
