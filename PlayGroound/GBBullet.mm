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
    fixtureDef.filter.groupIndex = -1;
    
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
    // see if the bullet should die
/*
    if (isDead)
    {
        //first time we are here, remove the physics body but not the sprite (just in case this sprite is still in the update list
        if (body != NULL)
        {
            world->DestroyBody(body);
            body = NULL;
        }
        //second time we are here there's no way another object is colliding with us, so it should be safe to remove ourselves from the scene
        else
        {
            [self removeFromParentAndCleanup:YES];
            CCLOG(@"bullet removed");
        }
        return;
    }
 */   
    lifeTimer += deltaTime;
    if (lifeTimer > MAX_LIFE_TIME)
    {
        destroyMe = true;
        [self setVisible:NO];
        return;
    }
    else
    {
        // see if we've hit an enemy
        GameCharPhysics* enemyBody = isBodyCollidingWithObjectType(body, kObjTypeEnemy);
        if (enemyBody != NULL)
        {
            destroyMe = true;
            [self setVisible:NO];
            CCLOG(@"Bullet hit Enemy");
        }
    }
}

@end
