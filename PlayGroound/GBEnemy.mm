//
//  GBEnemy.m
//  PlayGroound
//
//  Created by alex on 12-09-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GBEnemy.h"
#import "Box2DHelpers.h"
#import "GameManager.h"

#define GBENEMY_DENSITY 1.0
#define GBENEMY_FRICTION 1.0
#define GBENEMY_RESTITUTION 0.2
#define GBENEMY_RADIUS 0.8
#define GBENEMY_STARTING_VELOCITY 8.0
#define GBENEMY_LINEAR_DAMP 1.0
#define GBENEMY_PROPULSION_FORCE 11.0

#define GBENEMY_VORTEX_FORCE 40.0


@implementation GBEnemy
-(void) createAtLocation:(b2Vec2) location
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = location;
    body = world->CreateBody(&bodyDef);
    
    b2FixtureDef fixtureDef;
    fixtureDef.density = GBENEMY_DENSITY;
    fixtureDef.friction = GBENEMY_FRICTION;
    fixtureDef.restitution = GBENEMY_RESTITUTION;
    
    b2CircleShape shape;
    shape.m_radius = GBENEMY_RADIUS;
    
    fixtureDef.shape = &shape;
    
//    fixtureDef.filter.groupIndex = kEnemyWallGroup;
    fixtureDef.filter.categoryBits = kCollCatEnemy;
    fixtureDef.filter.maskBits = kCollMaskEnemy;
    
    body->CreateFixture(&fixtureDef);
    
    //figure out a random starting velocity (starting with a number between 0 and 1)
    float randomXVelocity = (float)arc4random()/(float)0x100000000;
    float randomYVelocity = (float)arc4random()/(float)0x100000000;
    //find a value between -GB_ENEMY_STARTING_VELOCITY and +GB_ENEMY_STARTING_VELOCITY
    randomXVelocity = GBENEMY_STARTING_VELOCITY - 2.0*GBENEMY_STARTING_VELOCITY * randomXVelocity;
    randomYVelocity = GBENEMY_STARTING_VELOCITY - 2.0*GBENEMY_STARTING_VELOCITY * randomYVelocity;
    
    body->SetLinearVelocity(b2Vec2(randomXVelocity, randomXVelocity));
    
    body->SetLinearDamping(GBENEMY_LINEAR_DAMP);
    
    body->SetUserData(self);
    
    PLAYSOUNDEFFECT(ENEMY_SPAWN);
}

-(id) initWithWorld:(b2World *)theWorld atLocation:(b2Vec2)location withTargetBody:(b2Body*) theTarget
{
    if ((self = [super init/*WithFile:@"Default.png"*/])) {
        
        world = theWorld;
        
        target = theTarget;
        
        [self createAtLocation:location];
        
        gameObjType = kObjTypeEnemy;
        
        destroyMe = false;
    }
    return self;    
}

-(void)updateStateWithDeltaTime:(ccTime)deltaTime
{
    if (destroyMe)
    {
        return;
    }
    
    // see if we've been hit by a bullet
    GameCharPhysics* bulletBody = isBodyCollidingWithObjectType(body, kObjTypeBullet);
    if (bulletBody != NULL)
    {
        destroyMe = TRUE;
        [self setVisible:NO];
        PLAYSOUNDEFFECT(ENEMY_EXPLODE);    
        return;
    }
    
    // see if we reached the player
    GameCharPhysics* gunBotBody = isBodyCollidingWithObjectType(body, kObjTypeGunBot);
    if (gunBotBody != NULL)
    {
        destroyMe = TRUE;
        [self setVisible:false];
        return;
    }
    
    // see if we are trapped in a vortex
    GameCharPhysics* vortexBody = isBodyCollidingWithObjectType(body, kObjTypeGravityWell);
    if (vortexBody != NULL)
    {
        b2Vec2 vortexForce = vortexBody.body->GetPosition() - body->GetPosition();
        vortexForce.Normalize();
        vortexForce.x *= GBENEMY_VORTEX_FORCE;
        vortexForce.y *= GBENEMY_VORTEX_FORCE;
        body->ApplyForce(vortexForce, body->GetPosition());
    }
    
    // if we got here, then continue moving towards the target
    b2Vec2 forceVector = target->GetPosition() - body->GetPosition();
    forceVector.Normalize();
    forceVector.x *= GBENEMY_PROPULSION_FORCE;
    forceVector.y *= GBENEMY_PROPULSION_FORCE;
    
    body->ApplyForce(forceVector, body->GetPosition());
}

@end
