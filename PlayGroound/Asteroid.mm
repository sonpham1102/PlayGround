//
//  Asteroid.mm
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-31.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Asteroid.h"
#import "Box2DHelpers.h"
#define PTM_RATIO (IS_IPAD() ? (32.0*1024.0/480.0) : 32.0)
#define SCALE (IS_IPAD() ? 1.1 : 0.55)

@implementation Asteroid

-(void)dealloc{
    [super dealloc];
}

-(void)createBodyAtLocation:(CGPoint)location {
    
    //CGSize winSize = [CCDirector sharedDirector].winSize;
    float32 size = arc4random()%30;
    size += 10.0f;
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = b2Vec2(location.x/PTM_RATIO,location.y/PTM_RATIO);
    
    body = world->CreateBody(&bodyDef);
    
    b2CircleShape shape;
    shape.m_radius = size / PTM_RATIO;
    shape.m_p = b2Vec2(0,0);
    
    b2FixtureDef fixtureDef;
    fixtureDef.density = 15.0;
    fixtureDef.shape = &shape;
    fixtureDef.restitution = 1.0;
    fixtureDef.friction = 0.0;
    
    body->CreateFixture(&fixtureDef);
    
    body->SetUserData(self);
    [self setScale:SCALE * size / PTM_RATIO];
    float32 direction = body->GetPosition().x;
    if (direction > 10) {
        direction = -1.0;
    } else {
        direction = 1.0;
    }
    
    b2Vec2 impulse = b2Vec2(body->GetMass() * 300.0f * direction,0);
    body->ApplyForce(impulse, body->GetWorldCenter()); 

}

-(void) destroy:(id)sender {
    [self removeFromParentAndCleanup:YES];
}

-(void) updateStateWithDeltaTime:(ccTime)dt {
   
    if (destroyMe) {
        return;
    }
    
    if (isBodyCollidingWithObjectType(body, kobjTypeBullet)) {
        world->DestroyBody(body);
        body = NULL;
        CCScaleTo *growAction = [CCScaleTo actionWithDuration:0.25 scale:1.25];
        CCScaleTo *shrinkAction = [CCScaleTo actionWithDuration:0.25 scale:0.75];
        CCCallFuncN *doneAction = [CCCallFuncN actionWithTarget:self selector:@selector(destroy:)];
        CCSequence *sequence = [CCSequence actions:growAction,shrinkAction,doneAction, nil];
        [self runAction:sequence];
        destroyMe = true;
    }

}

-(id) initWithWorld:(b2World *)theWorld atLoaction:(CGPoint)location {
    if ((self = [super initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"asteroid.png"]])) {
        world = theWorld;
        gameObjType = kObjTypeAsteroid;
        [self createBodyAtLocation:location];
        destroyMe = false;
    }
    return self;
}



@end
