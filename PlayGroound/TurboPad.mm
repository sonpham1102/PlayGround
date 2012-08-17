//
//  TurboPad.m
//  PlayGroound
//
//  Created by alex on 12-08-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TurboPad.h"
#import "Box2DHelpers.h"

#define TP_SIDEWAYS_FORCE 10.0f
#define TP_FORCE 600.0f
#define TP_IMPULSE 10.0f

@implementation TurboPad

-(void) createBodyAtLocation:(b2Vec2) location withWidth: (float) width withHeight:(float) height withOffsetAngle: (float) angleOffset
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position = b2Vec2(location.x, location.y);
    
    self.body = world->CreateBody(&bodyDef);
    body->SetUserData(self);
        
    b2PolygonShape shape;
    b2Vec2 verts[]={
        b2Vec2(width/2.0f, height*0.8f/2.0f),
        b2Vec2(-width/2.0f, height/2.0f),
        b2Vec2(-width/2.0f, -height/2.0f),
        b2Vec2(width/2.0f, -height*0.8f/2.0f)};
    
    shape.Set(verts, 4);
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
    
    fixtureDef.isSensor = true;
    
    body->CreateFixture(&fixtureDef);
    
    body->SetTransform(body->GetPosition(), angleOffset*M_PI/180.0f);
}

-(id)initWithWorld:(b2World*)theWorld atLocation:(b2Vec2) location withWidth: (float) width withHeight:(float) height withOffsetAngle:(float)angleOffset
{
    if ((self = [super init]))
    {
        world = theWorld;
        //[self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"spikes.png"]];
        gameObjType = kObjTypeTurboPad;
        [self createBodyAtLocation:location withWidth:width withHeight:height withOffsetAngle:angleOffset];
    }
    return self;        
}

-(void)updateStateWithDeltaTime:(ccTime)dt
{
    GameCharPhysics* rocketBody = isBodyCollidingWithObjectType(body, kObjTypeRocket);
    if (rocketBody != NULL)
    {
        b2Vec2 rocketVelocity = body->GetLocalVector(rocketBody.body->GetLinearVelocity());
        //apply a rear impulse to propel forward and a sideways force to damp sideways velocity
        b2Vec2 impulseVector = body->GetWorldVector(b2Vec2(1.0f, 0.0f));
        impulseVector.x *= rocketBody.body->GetMass()*TP_IMPULSE;
        impulseVector.y *= rocketBody.body->GetMass()*TP_IMPULSE;

        b2Vec2 forceVector = body->GetWorldVector(b2Vec2(0.0f, -rocketVelocity.y));
        forceVector.x *= TP_SIDEWAYS_FORCE * rocketBody.body->GetMass();       
        forceVector.y *= TP_SIDEWAYS_FORCE * rocketBody.body->GetMass();

        rocketBody.body->ApplyForce(forceVector, rocketBody.body->GetWorldCenter());
        rocketBody.body->ApplyLinearImpulse(impulseVector, rocketBody.body->GetWorldCenter());
    }
}

@end
