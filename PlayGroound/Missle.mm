//
//  Missle.mm
//  PlayGroound
//
//  Created by Jason Parlour on 12-08-14.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define PTM_RATIO (IS_IPAD() ? (32.0*1024.0/480.0) : 32.0)
#define MISSLE_LIFE 5
#define SCALE_FACTOR 0.2f

#import "Missle.h"


@implementation Missle
@synthesize delegate;

@synthesize target;

-(void)createBodyAtLocation:(b2Vec2)location {
    
    //float32 size = 4.0;
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = location;
    bodyDef.bullet = true;
    
    
    body = world->CreateBody(&bodyDef);
    /*
     b2CircleShape shape;
     shape.m_radius = size / PTM_RATIO;
     shape.m_p = b2Vec2(0,0);
     */
    b2PolygonShape shape;
    
    b2Vec2 vert[] = {
        b2Vec2( 0 * SCALE_FACTOR , 1 * SCALE_FACTOR),
        b2Vec2(-0.1 * SCALE_FACTOR , SCALE_FACTOR * -0.12),
        b2Vec2(0.1 * SCALE_FACTOR , SCALE_FACTOR * -0.12),
    };
    
    shape.Set(vert, 3);
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
    
    body->CreateFixture(&fixtureDef);
    
    body->SetUserData(self);
    //[self setScale:3];
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
        
        b2Vec2 targetPos = target.body->GetWorldPoint(target.body->GetLinearVelocityFromLocalPoint(b2Vec2(0,0)))  - currentPos;
        
        float bodyAngle = body->GetAngle();
        float desiredAngle = atan2f( -targetPos.x, targetPos.y );

        float totalRotation = desiredAngle - bodyAngle;
        float change = CC_DEGREES_TO_RADIANS(8); //allow 4 degree rotation per time step
        float newAngle = bodyAngle + min( change, max(-change, totalRotation));
        body->SetTransform( body->GetPosition(), newAngle );
        
        b2Vec2 impulse = b2Vec2(0,body->GetMass() * 8.0f);
        b2Vec2 impulseWorld = body->GetWorldVector(impulse);
        b2Vec2 impulsePoint = body->GetWorldPoint(b2Vec2(-1.25 * SCALE_FACTOR,
                                                         /*-1.75*/0.0 * SCALE_FACTOR));
        body->ApplyForce(impulseWorld, impulsePoint);
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
    if (self = [super initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bullet.png"]]){
        world = theWorld;
        gameObjType = kobjTypeMissle;
        [self createBodyAtLocation:location];
        target = (Asteroid*) myTarget->GetUserData();
        destroyMe = false;
        isDead = false;
        timeTravelled = 0.0;
        [self setVisible:NO];
    }
    return self;
}

@end
