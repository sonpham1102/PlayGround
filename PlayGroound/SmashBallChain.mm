//
//  SmashBallChain.m
//  PlayGroound
//
//  Created by alex on 12-09-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SmashBallChain.h"

@implementation SmashBallChain

-(void) createSelfAtLocation:(b2Vec2) location
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = location;
    body = world->CreateBody(&bodyDef);
    
    b2FixtureDef fixtureDef;
    fixtureDef.density = SBC_DENSITY;
    fixtureDef.friction = SBC_FRICTION;
    fixtureDef.restitution = SBC_RESTITUTION;
    
    b2PolygonShape shape;
    
    fixtureDef.shape = &shape;
        
    b2Vec2 verts[]={
        b2Vec2(SBC_WIDTH/2.0, SBC_HEIGHT/2.0),
        b2Vec2(-SBC_WIDTH/2.0, SBC_HEIGHT/2.0),
        b2Vec2(-SBC_WIDTH/2.0, -SBC_HEIGHT/2.0),
        b2Vec2(SBC_WIDTH/2.0, -SBC_HEIGHT/2.0)
    };
    
    shape.Set(verts, 4);
    
    fixtureDef.filter.categoryBits = kCollCatSBC;
    fixtureDef.filter.maskBits = kCollMaskSBC;
    
    body->CreateFixture(&fixtureDef);
    
    body->SetLinearDamping(SBC_LINEAR_DAMP);
    body->SetAngularDamping(SBC_ANG_DAMP);
    
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
