//
//  bullet.mm
//  PlayGroound
//
//  Created by Jason Parlour on 12-08-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "bullet.h"
#import "Box2DHelpers.h"

#define PTM_RATIO (IS_IPAD() ? (32.0*1024.0/480.0) : 32.0)
#define BULLET_LIFE 1.5

@implementation bullet

@synthesize delegate;
@synthesize sensorFixture;

-(void)createBodyAtLocation:(CGPoint)location {
    
    //CGSize winSize = [CCDirector sharedDirector].winSize;
    float32 size = 1.0;
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = b2Vec2(location.x/PTM_RATIO,location.y/PTM_RATIO);
    bodyDef.bullet = true;
    
    body = world->CreateBody(&bodyDef);
    
    b2CircleShape shape;
    shape.m_radius = size / PTM_RATIO;
    shape.m_p = b2Vec2(0,0);
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
    fixtureDef.isSensor = true;
    
    body->CreateFixture(&fixtureDef);
    
    body->SetUserData(self);
    b2Fixture *fixture = body->GetFixtureList();
    while (fixture) {
        if (fixture->IsSensor()) {
            sensorFixture = fixture;
            break;
        }
        fixture = fixture->GetNext();    
    }
}

-(void)updateStateWithDeltaTime:(ccTime)deltaTime{
    
    timeTravelled += deltaTime;
    if (timeTravelled >= BULLET_LIFE) {
        [self removeFromParentAndCleanup:YES];
        world->DestroyBody(body);
        [delegate decrementBulletCount];
    }
    if (isSensorCollidingWithObjectType(body, kObjTypeAsteroid,sensorFixture,world)) {
        [self removeFromParentAndCleanup:YES];
        world->DestroyBody(body);
        CCLOG(@"Asteroid Hit with Bullet");
        [delegate decrementBulletCount];
    }
   
}

-(id) initWithWorld:(b2World *)theWorld atLoaction:(CGPoint)location {
    if ((self = [super initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bullet.png"]])) {
        world = theWorld;
        gameObjType = kobjTypeBullet;
        timeTravelled = 0.0;
        [self createBodyAtLocation:location];
    }
    return self;
}
@end
