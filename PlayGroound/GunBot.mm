//
//  GunBot.m
//  PlayGroound
//
//  Created by alex on 12-09-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GunBot.h"
#import "Box2DHelpers.h"

#define GB_DENSITY 10.0
#define GB_FRICTION 1.0
#define GB_RESTITUTION 1.0
#define GB_RADIUS 1.0
#define GB_LINEAR_DAMP 10.0
#define GB_ANGULAR_DAMP 10.0
#define GB_SPIN_VELOCITY 20.0
#define GB_SPIN_TIME 3.0

@implementation GunBot
-(void) setSpinDirection:(float)angle
{
    
    if (angle > 0.0)
    {
        spinDirection = -1.0;
    }
    else
    {
        spinDirection = 1.0;
    }
}


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
    //fixtureDef.filter.groupIndex = kGunBotBulletGroup;
    fixtureDef.filter.categoryBits = kCollCatGunBot;
    fixtureDef.filter.maskBits = kCollMaskGunBot;
    
    body->CreateFixture(&fixtureDef);
    
    body->SetLinearDamping(GB_LINEAR_DAMP);
    body->SetAngularDamping(GB_ANGULAR_DAMP);
    body->SetLinearVelocity(b2Vec2_zero);
    
    body->SetUserData(self);
}

// location should be in meters (not points)
-(id) initWithWorld:(b2World *)theWorld atLocation:(CGPoint)location
{
    if ((self = [super init/*WithFile:@"Default.png"*/] ))
    {        
        world = theWorld;
        [self createGunBotAtLocation:location];
                
        gameObjType = kObjTypeGunBot;
        [self setCharacterState:kStateIdle];
        spinTimer = 0.0;
        
        [self setScale:1.0];
    }
    return self;
}

-(void)updateStateWithDeltaTime:(ccTime)deltaTime
{
    if (destroyMe)
    {
        return;
    }
    
    // see if we've been hit by an Enemy
    GameCharPhysics* enemy = isBodyCollidingWithObjectType(body, kObjTypeEnemy);
    if ((enemy != NULL) && ([self characterState] != kStateManeuver))
    {
        destroyMe = TRUE;
        [self setVisible:NO];
    
        return;
    }
    
    // if spinning, see if it's time to stop
    if ([self characterState] == kStateManeuver)
    {
        spinTimer += deltaTime;
        if (spinTimer > GB_SPIN_TIME)
        {
            [self changeState:kStateIdle];
        }
    }
}

-(void) changeState:(CharStates)newState
{
    if (characterState == newState)
    {
        return;
    }
    
    [self setCharacterState:newState];
    
    switch (newState) {
        case kStateManeuver:
            //give the bot an angular velocity
            body->SetAngularDamping(0.0f);
            body->SetLinearDamping(0.0f);
            body->SetAngularVelocity(spinDirection * GB_SPIN_VELOCITY);
            //start the spin timer
            spinTimer = 0.0f;
            break;
        case kStateIdle:
            body->SetLinearDamping(GB_LINEAR_DAMP);
            body->SetAngularDamping(GB_ANGULAR_DAMP);
            break;
        default:
            break;
    }
}

@end
