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
#define BULLET_LIFE 0.5

@implementation bullet

//@synthesize delegate;
//@synthesize sensorFixture;

-(void)dealloc{
    //world = nil;
    //delegate = nil;
    //sensorFixture = nil;
    [super dealloc];
}

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
    
    /*sensorFixture =*/ body->CreateFixture(&fixtureDef);
    body->SetUserData(self);
}

-(void) destroy:(id)sender{
    [self removeFromParentAndCleanup:YES];
}

-(void)updateStateWithDeltaTime:(ccTime)deltaTime{
    
    if (destroyMe)
    {
        [self removeFromParentAndCleanup:YES];
        return;
    }
    
    timeTravelled += deltaTime;
    if (timeTravelled >= BULLET_LIFE) {
        //[delegate decrementBulletCount];\
        body->DestroyFixture(sensorFixture);
        //sensorFixture = NULL;
        world->DestroyBody(body);
        body = NULL;
        //[self destroy:self];
        destroyMe = true;        
    } else if (isBodyCollidingWithObjectType(body, kObjTypeAsteroid)) {
        /*
        CCScaleTo *growAction = [CCScaleTo actionWithDuration:0.1 scale:1.2];
        CCScaleTo *shrinkAction = [CCScaleTo actionWithDuration:0.1 scale:0.5];
        CCCallFuncN *doneAction = [CCCallFuncN actionWithTarget:self selector:@selector(destroy:)];
        CCSequence *sequence = [CCSpawn actions:growAction,shrinkAction,doneAction, nil];
        [self runAction:sequence];
         */
        //sensorFixture = NULL;
        world->DestroyBody(body);
        body = NULL;
        //[self destroy:self];
        destroyMe = true;
    }
    
    /*
    else if (isSensorCollidingWithObjectType(body, kObjTypeAsteroid,sensorFixture,world)) {
        //[delegate decrementBulletCount];
        destroyMe = true;
        CCLOG(@"Asteroid Hit with Bullet");
    }*/
   
}

-(id) initWithWorld:(b2World *)theWorld atLoaction:(CGPoint)location {
    if ((self = [super initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bullet.png"]])) {
        world = theWorld;
        gameObjType = kobjTypeBullet;
        timeTravelled = 0.0;
        [self createBodyAtLocation:location];
        destroyMe = false;
    }
    return self;
}
@end
