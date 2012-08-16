//
//  PhotonTorpedo.mm
//  PlayGroound
//
//  Created by Jason Parlour on 12-08-14.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define PTM_RATIO (IS_IPAD() ? (32.0*1024.0/480.0) : 32.0)
#define MISSLE_LIFE 15

#import "PhotonTorpedo.h"
#define SCALE_FACTOR 0.2f


@implementation PhotonTorpedo
@synthesize delegate;

@synthesize target;

-(void)createBodyAtLocation:(b2Vec2)location {
    
    float32 size = 3.0;
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
    
    body->CreateFixture(&fixtureDef);
    
    body->SetUserData(self);
    [self setScale:3];
}

-(void) destroy:(id)sender {
    [delegate decrementMissleCount];
    [self removeFromParentAndCleanup:YES];
}

-(void)updateStateWithDeltaTime:(ccTime)dt {
    
    if (isDead) {
        return;
    }
    if (!target.destroyMe) {
        b2Vec2 currentPos = body->GetPosition();
        b2Vec2 offset = body->GetWorldVector(body->GetLinearVelocity());
        b2Vec2 targetPos = target.body->GetWorldPoint(target.body->GetLinearVelocity()) - offset;
        b2Vec2 destination = targetPos - currentPos;
        b2Vec2 force = body->GetWorldVector(destination);
        body->ApplyLinearImpulse(force, body->GetWorldPoint(b2Vec2(0.0 * SCALE_FACTOR,
                                                                   0.0 * SCALE_FACTOR)));
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
    
    timeTravelled += dt;
    if (timeTravelled >= MISSLE_LIFE) {
        destroyMe = true;
    }
    
    if (target.destroyMe) {
        destroyMe = true;
    }
}

-(id) initWithWorld:(b2World *)theWorld atLoaction:(b2Vec2)location withTarget:(b2Body*)myTarget {
    if ((self = [super initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bullet.png"]])) {
        world = theWorld;
        gameObjType = kobjTypeMissle;
        [self createBodyAtLocation:location];
        target = (Asteroid*) myTarget->GetUserData();
        destroyMe = false;
        isDead = false;
        timeTravelled = 0.0;
    }
    return self;
}

@end
