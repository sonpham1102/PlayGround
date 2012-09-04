//
//  Ball.m
//  PlayGroound
//
//  Created by Jason Parlour on 12-09-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Ball.h"

#define PTM_RATIO (IS_IPAD() ? (32.0*1024.0/480.0) : 32.0)

@implementation Ball

-(id)initWithWorld:(b2World*)theWorld atLocation:(CGPoint)location {
    if ((self = [super init])){
        world = theWorld;
        [self createBodyAtLoaction:location];
    }
    return self;
}

-(void)createBodyAtLoaction:(CGPoint)location {
    b2BodyDef bodydef;
    bodydef.bullet = true;
    bodydef.type = b2_dynamicBody;
    bodydef.position = b2Vec2(location.x/PTM_RATIO,
                              location.y/PTM_RATIO);
    body = world->CreateBody(&bodydef);
    
    b2FixtureDef fixtureDef;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.0f;
    fixtureDef.restitution = 1.0f;
    
    b2CircleShape circle;
    circle.m_radius = 5.4 / PTM_RATIO;
    fixtureDef.shape = &circle;
    
    body->CreateFixture(&fixtureDef);
    
    body->SetUserData(self);
}
@end
