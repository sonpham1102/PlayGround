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


@implementation bullet

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
    
    if (isSensorCollidingWithObjectType(body, kObjTypeAsteroid,sensorFixture,world)) {
        CCLOG(@"Asteroid Hit with Bullet");
    }
   
}

-(id) initWithWorld:(b2World *)theWorld atLoaction:(CGPoint)location {
    if ((self = [super init])) {
        world = theWorld;
        gameObjType = kobjTypeBullet;
        timeTravelled = 0.0;
        [self createBodyAtLocation:location];
    }
    return self;
}
@end
