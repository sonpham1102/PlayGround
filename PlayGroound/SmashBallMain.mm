//
//  SmashBallMain.mm
//  PlayGroound
//
//  Created by alex on 12-09-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SmashBallMain.h"

@implementation SmashBallMain

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
    fixtureDef.density = SBM_DENSITY;
    fixtureDef.friction = SBM_FRICTION;
    fixtureDef.restitution = SBM_RESTITUTION;
    
    b2CircleShape shape;
    shape.m_radius = SBM_RADIUS;
    
    fixtureDef.shape = &shape;
    
    fixtureDef.filter.categoryBits = kCollCatSBM;
    fixtureDef.filter.maskBits = kCollMaskSBM;
    
    body->CreateFixture(&fixtureDef);
    
    body->SetLinearDamping(SBM_LINEAR_DAMP);
    body->SetAngularDamping(SBM_ANG_DAMP);
    
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
