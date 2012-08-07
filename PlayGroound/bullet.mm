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
#define BULLET_LIFE 0.8

@implementation bullet

//@synthesize delegate;
//@synthesize sensorFixture;

-(void)dealloc{
    //world = nil;
    //delegate = nil;
    //sensorFixture = nil;
    [super dealloc];
}

-(void)createBodyAtLocation:(b2Vec2)location {
    
    //CGSize winSize = [CCDirector sharedDirector].winSize;
    float32 size = 1.0;
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = location;
    bodyDef.bullet = true;
    
    body = world->CreateBody(&bodyDef);
    
    b2CircleShape shape;
    shape.m_radius = size / PTM_RATIO;
    shape.m_p = b2Vec2(0,0);
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
    //fixtureDef.isSensor = true;
    //fixtureDef.density = 0.5;
    body->CreateFixture(&fixtureDef);
    
    body->SetUserData(self);
}

-(void) destroy:(id)sender {
    [self removeFromParentAndCleanup:YES];
}

-(void)updateStateWithDeltaTime:(ccTime)deltaTime{
    
    if (isDead) {
        return;
    }
    
    if (destroyMe) {
        world->DestroyBody(body);
        body = NULL;
        CCScaleTo *growAction = [CCScaleTo actionWithDuration:0.25 scale:1.25];
        CCScaleTo *shrinkAction = [CCScaleTo actionWithDuration:0.25 scale:0.75];
        CCCallFuncN *doneAction = [CCCallFuncN actionWithTarget:self selector:@selector(destroy:)];
        CCSequence *sequence = [CCSequence actions:growAction,shrinkAction,doneAction, nil];
        [self runAction:sequence];
        [self setVisible:NO];
        isDead = YES;
    }
    
    timeTravelled += deltaTime;
    if (timeTravelled >= BULLET_LIFE) {
        destroyMe = true;
    } 
   
}

-(id) initWithWorld:(b2World *)theWorld atLoaction:(b2Vec2)location {
    if ((self = [super initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bullet.png"]])) {
        world = theWorld;
        gameObjType = kobjTypeBullet;
        timeTravelled = 0.0;
        [self createBodyAtLocation:location];
        destroyMe = false;
        isDead = NO;
    }
    return self;
}
@end
