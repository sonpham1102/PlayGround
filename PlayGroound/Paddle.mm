//
//  Paddle.mm
//  PlayGroound
//
//  Created by Jason Parlour on 12-09-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define PTM_RATIO (IS_IPAD() ? (32.0*1024.0/480.0) : 32.0)

#import "Paddle.h"

@implementation Paddle

@synthesize delegate;

-(id)initWithWorld:(b2World*)theWorld atLocation:(CGPoint)location {
    if ((self = [super init])){
        world = theWorld;
        gameObjType = kObjTypePaddle;
        [self createBodyAtLocation:location];
    }
    return self;
}

-(void)createBodyAtLocation:(CGPoint)location {
    b2BodyDef bodydef;
    bodydef.type = b2_dynamicBody;
    bodydef.position = b2Vec2(location.x/PTM_RATIO,
                              location.y/PTM_RATIO);
    bodydef.bullet = true;
    
    body = world->CreateBody(&bodydef);
    
    b2FixtureDef fixtureDef;
    fixtureDef.density = 10.0f;
    fixtureDef.friction = 1.0f;
    fixtureDef.restitution = 1.15f;
    
    b2PolygonShape shape;
    
    fixtureDef.shape = &shape;
    
    b2Vec2 vert[] = {
        b2Vec2(20.0 / PTM_RATIO, 5.0 / PTM_RATIO),
        b2Vec2(-20.0 / PTM_RATIO, 5.0 / PTM_RATIO),
        b2Vec2(-20.0 / PTM_RATIO, -5.0 / PTM_RATIO),
        b2Vec2(20.0 / PTM_RATIO, -5.0 / PTM_RATIO)
    };
    
    shape.Set(vert, 4);
    body->CreateFixture(&fixtureDef);
    
    b2CircleShape circle;
    circle.m_radius = 5.4 / PTM_RATIO;
    circle.m_p = b2Vec2(20 / PTM_RATIO, 0);
    fixtureDef.shape = &circle;
    
    body->CreateFixture(&fixtureDef);
    
    circle.m_p = b2Vec2(-20 / PTM_RATIO, 0);
    
    body->CreateFixture(&fixtureDef);
    body->SetSleepingAllowed(NO);
    body->SetLinearDamping(3.0f);
    body->SetUserData(self);
    
}

-(void)updateStateWithDeltaTime:(ccTime)dt {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    b2Vec2 centre = b2Vec2(winSize.width/2/PTM_RATIO,0);
    b2Vec2 paddlecenter = body->GetWorldCenter();
    float offset =  paddlecenter.x - centre.x;
    
    CGPoint leftPos = [delegate getLeftTouchPos];
    CGPoint rightPos = [delegate getRightTouchPos];
    b2Vec2 leftTarget = b2Vec2(leftPos.x/PTM_RATIO,
                               leftPos.y/PTM_RATIO);
    b2Vec2 rightTarget = b2Vec2(rightPos.x/PTM_RATIO,
                               rightPos.y/PTM_RATIO);
    b2Vec2 targetLine = leftTarget - rightTarget;
    
    float desiredAngle = atan2f( -targetLine.x, targetLine.y ) - CC_DEGREES_TO_RADIANS(90);
    
    b2Vec2 newPos = b2Vec2(((leftPos.x + rightPos.x) / 2 / PTM_RATIO) + (offset * 10.0 / PTM_RATIO), 
                           ((leftPos.y + rightPos.y) / 2 / PTM_RATIO) + (42 / PTM_RATIO));
    
    body->SetTransform(newPos, desiredAngle);
}   

@end
