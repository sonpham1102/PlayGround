//
//  ShotGunBlast.mm
//  PlayGroound
//
//  Created by alex on 12-09-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ShotGunBlast.h"
#import "Box2DHelpers.h"
#import "GameManager.h"

@implementation ShotGunBlast

#define SGB_DENSITY 1.0
#define SGB_RESTITUTION 1.0
#define SGB_FRICTION 0.0
#define SGB_WIDTH 0.2
#define SGB_HEIGHT 6.0
#define MAX_LIFE_TIME 0.4

-(void) createAtLocation:(b2Vec2) location withVelocity:(b2Vec2) velocity
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = location;
    bodyDef.bullet = true;
    body = world->CreateBody(&bodyDef);
    
    b2FixtureDef fixtureDef;
    fixtureDef.density = SGB_DENSITY;
    fixtureDef.friction = SGB_FRICTION;
    fixtureDef.restitution = SGB_RESTITUTION;
    
    fixtureDef.isSensor = true;
    
    b2PolygonShape shape;
    b2Vec2 verts[]={
        b2Vec2(SGB_WIDTH/2.0f, SGB_HEIGHT/2.0f),
        b2Vec2(-SGB_WIDTH/2.0f, SGB_HEIGHT/2.0f),
        b2Vec2(-SGB_WIDTH/2.0f, -SGB_HEIGHT/2.0f),
        b2Vec2(SGB_WIDTH/2.0f, -SGB_HEIGHT/2.0f)};
    
    shape.Set(verts, 4);
    
    fixtureDef.shape = &shape;   
    
    // make sure the bullets don't collide with the GunBot
    //fixtureDef.filter.groupIndex = kGunBotBulletGroup;
    fixtureDef.filter.categoryBits = kCollCatBullet;
    fixtureDef.filter.maskBits = kCollMaskBullet;
    
    body->CreateFixture(&fixtureDef);
    
    body->SetLinearDamping(0.0);
    
    body->SetLinearVelocity(velocity);
    
    float angle = atan2f(velocity.y, velocity.x);
    
    body->SetTransform(body->GetPosition(), angle);    
    body->SetUserData(self);
    
    PLAYSOUNDEFFECT(FIRE_SHOTGUN);
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
}

@end
