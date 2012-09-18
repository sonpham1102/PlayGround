//
//  SBBlock.mm
//  PlayGroound
//
//  Created by alex on 12-09-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SBBlock.h"

@implementation SBBlock
-(void) createSelfAtLocation:(b2Vec2) location
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = location;
    body = world->CreateBody(&bodyDef);
    
    b2FixtureDef fixtureDef;
    fixtureDef.density = SBB_DENSITY;
    fixtureDef.friction = SBB_FRICTION;
    fixtureDef.restitution = SBB_RESTITUTION;
    
    b2PolygonShape shape;
    
    fixtureDef.shape = &shape;
    
    b2Vec2 verts[]={
        b2Vec2(SBB_WIDTH/2.0, SBB_HEIGHT/2.0),
        b2Vec2(-SBB_WIDTH/2.0, SBB_HEIGHT/2.0),
        b2Vec2(-SBB_WIDTH/2.0, -SBB_HEIGHT/2.0),
        b2Vec2(SBB_WIDTH/2.0, -SBB_HEIGHT/2.0)
    };
    
    shape.Set(verts, 4);
    
    fixtureDef.filter.categoryBits = kCollCatSBB;
    fixtureDef.filter.maskBits = kCollMaskSBB;
    
    body->CreateFixture(&fixtureDef);
    
    body->SetLinearDamping(SBB_LINEAR_DAMP);
    body->SetAngularDamping(SBB_ANG_DAMP);
    
    body->SetUserData(self);        
}

-(id) initWithWorld:(b2World *)theWorld atLocation:(b2Vec2)location
{
    if ((self = [super init/*WithFile:@"Default.png"*/] ))
    {        
        world = theWorld;
        [self createSelfAtLocation:location];
        startingLocation = location;
        deathTimer = 0.0f;
        
        gameObjType = kObjTypeBlock;
    }
    return self;    
}

#define KILL_DISTANCE_SQ 0.2*SBB_WIDTH*0.2*SBB_WIDTH
#define MAX_LIFE_TIME 3.0

-(void)updateStateWithDeltaTime:(ccTime)deltaTime
{
    if (destroyMe)
    {
        return;
    }

    // check our location, if it's far from the starting location, start the death timer
    if (body->IsAwake() && (deathTimer == 0.0f))
    {
        b2Vec2 translationVector = startingLocation - body->GetPosition();
        
        if (translationVector.LengthSquared() > KILL_DISTANCE_SQ)
        {
            deathTimer = deltaTime;
        }
    }
    else if (deathTimer > 0.0f)
    {
        deathTimer+= deltaTime;
    }
    if (deathTimer > MAX_LIFE_TIME)
    {
        destroyMe = true;
        [self setVisible:NO];
        return;
    }
}

@end
