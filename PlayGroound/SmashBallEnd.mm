//
//  SmashBallEnd.mm
//  PlayGroound
//
//  Created by alex on 12-09-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SmashBallEnd.h"

@implementation SmashBallEnd

-(BOOL) mouseJointBegan
{
    return TRUE;
}

-(void) createSelfAtLocation:(b2Vec2) location
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = location;
    body = world->CreateBody(&bodyDef);
    
    b2FixtureDef fixtureDef;
    fixtureDef.density = SBE_DENSITY;
    fixtureDef.friction = SBE_FRICTION;
    fixtureDef.restitution = SBE_RESTITUTION;
    
    b2CircleShape shape;
    shape.m_radius = SBE_RADIUS;
    
    fixtureDef.shape = &shape;
    
    fixtureDef.filter.categoryBits = kCollCatSBE;
    fixtureDef.filter.maskBits = kCollMaskSBE;
    
    body->CreateFixture(&fixtureDef);
    
    body->SetLinearDamping(SBE_LINEAR_DAMP);
    body->SetAngularDamping(SBE_ANG_DAMP);
    
    body->SetUserData(self);    
}

-(id) initWithWorld:(b2World *)theWorld atLocation:(b2Vec2)location
{
    if ((self = [super init/*WithFile:@"Default.png"*/] ))
    {        
        world = theWorld;
        [self createSelfAtLocation:location];
        
    }
    return self;    
}

@end
