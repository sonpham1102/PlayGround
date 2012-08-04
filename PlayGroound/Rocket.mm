//
//  Rocket.mm
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Rocket.h"
#import "bullet.h"

#define PTM_RATIO (IS_IPAD() ? (32.0*1024.0/480.0) : 32.0)

#define SCALE_FACTOR 0.12f
#define TURN_SPEED 20.0


@implementation Rocket

@synthesize pitchTurn;
@synthesize turnDirection;
@synthesize sensorFixture;
@synthesize delegate;


-(void) fireBullet:(ccTime)deltaTime {
    [delegate createBullet:deltaTime];
}

-(void) createWeaponSensor {
    b2FixtureDef fixtureDef;
    fixtureDef.isSensor = YES;
    b2PolygonShape shape;
    fixtureDef.shape = &shape;
    
    int num = 6;
    b2Vec2 vert[] = {
        b2Vec2(SCALE_FACTOR * 3.0 , SCALE_FACTOR * 5.0),
        b2Vec2(SCALE_FACTOR * 25.0, SCALE_FACTOR * 55.0),
        b2Vec2(SCALE_FACTOR * 10.0 , SCALE_FACTOR * 70.0),
        b2Vec2(SCALE_FACTOR * -10.0, SCALE_FACTOR * 70.0),
        b2Vec2(SCALE_FACTOR * -25.0, SCALE_FACTOR * 55.0),
        b2Vec2(SCALE_FACTOR * -3.0, SCALE_FACTOR * 5.0)
    };
    shape.Set(vert, num);
    body->CreateFixture(&fixtureDef);
    b2Fixture *fixture = body->GetFixtureList();
    while (fixture) {
        if (fixture->IsSensor()) {
            sensorFixture = fixture;
            break;
        }
        fixture = fixture->GetNext();    
    }
}

-(void) setTurnDirection:(int)turn{
    turnDirection = turn;
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft){
        turnDirection *= -turn;
    } else {
        turnDirection *= turn;
    }
}
-(void) turnRocket {
    body->ApplyTorque(body->GetMass()*pitchTurn * TURN_SPEED * turnDirection);
}

-(void) createRocketAtLocation:(CGPoint)location {
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = b2Vec2(location.x/PTM_RATIO,
                              location.y/PTM_RATIO);
    body = world->CreateBody(&bodyDef);
    
    body->SetUserData(self);
    
    b2FixtureDef fixtureDef;
    fixtureDef.density = 5.0f;
    fixtureDef.friction = 0.5f;
    fixtureDef.restitution = 0.0f;
    
    b2PolygonShape shape;
    
    fixtureDef.shape = &shape;
    
    b2Vec2 vert[] = {
        b2Vec2(SCALE_FACTOR * 0.0 , SCALE_FACTOR * 2.5),
        //b2Vec2(SCALE_FACTOR * -1.0 , SCALE_FACTOR * 2.5),
        b2Vec2(SCALE_FACTOR * -1.0 , SCALE_FACTOR * -0.5),
        b2Vec2(SCALE_FACTOR * 1.0 , SCALE_FACTOR * -0.5),
    };
    
    shape.Set(vert, 3);
    //fixtureDef.density = 5.0f;
    body->CreateFixture(&fixtureDef);
    
    b2Vec2 vert1[] = {
        b2Vec2(SCALE_FACTOR * -1.0 , SCALE_FACTOR * 0.5),
        b2Vec2(SCALE_FACTOR * -1.5 , SCALE_FACTOR * 0.5),
        b2Vec2(SCALE_FACTOR * -1.5 , SCALE_FACTOR * -1.75),
        b2Vec2(SCALE_FACTOR * -1.0 , SCALE_FACTOR * -1.75),
    };
    
    shape.Set(vert1, 4);
    
    body->CreateFixture(&fixtureDef);
    
    b2Vec2 vert2[] = {
        b2Vec2(SCALE_FACTOR * 1.5 , SCALE_FACTOR * 0.5),
        b2Vec2(SCALE_FACTOR * 1.0 , SCALE_FACTOR * 0.5),
        b2Vec2(SCALE_FACTOR * 1.0 , SCALE_FACTOR * -1.75),
        b2Vec2(SCALE_FACTOR * 1.5 , SCALE_FACTOR * -1.75),
    };
    
    shape.Set(vert2, 4);
    
    body->CreateFixture(&fixtureDef);
    
    //AP: add a little bouncy ball on the end
    fixtureDef.restitution = 0.50f;
    b2CircleShape circle;
    circle.m_radius = 0.05;
    circle.m_p = b2Vec2(0, SCALE_FACTOR *2.5);
    fixtureDef.shape = &circle;
    
    body->CreateFixture(&fixtureDef);
    
    body->SetAngularDamping(30.0f);
    //body->SetLinearDamping(1.0f);
    [self createWeaponSensor];
    
}

-(void)updateStateWithDeltaTime:(ccTime)deltaTime {
    [self turnRocket];
    //check to see if sensor detects asteroid
    if (isSensorCollidingWithObjectType(body, kObjTypeAsteroid,sensorFixture,world)) {
        [self fireBullet:deltaTime];
    } 
    if (isBodyCollidingWithObjectType(body, kObjTypeAsteroid)) {
        //CCLOG(@"Collided with Asteroid Handle it");
    }
}

-(void) fireLeftRocket {
    
    b2Vec2 bodyCenter = body->GetWorldCenter();
    b2Vec2 impulse = b2Vec2(0,body->GetMass() * 10.0f);
    b2Vec2 impulseWorld = body->GetWorldVector(impulse);
    b2Vec2 impulsePoint = body->GetWorldPoint(b2Vec2(-1.25 * SCALE_FACTOR,
                                                     /*-1.75*/0.0 * SCALE_FACTOR));
    body->ApplyForce(impulseWorld, impulsePoint);
}

-(void) fireRightRocket {
    
    b2Vec2 bodyCenter = body->GetWorldCenter();
    b2Vec2 impulse = b2Vec2(0,body->GetMass() * 10.0f);
    b2Vec2 impulseWorld = body->GetWorldVector(impulse);
    b2Vec2 impulsePoint = body->GetWorldPoint(b2Vec2(1.25 * SCALE_FACTOR,
                                                     /*-1.75*/0.0 * SCALE_FACTOR));
    body->ApplyForce(impulseWorld, impulsePoint);
}

-(id) initWithWorld:(b2World *)theWorld atLocation:(CGPoint)location {
    
    if ((self = [super initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"rocket1.png"]] )) {
        
        world = theWorld;
        gameObjType = kObjTypeRocket;
        
        [self createRocketAtLocation:location];
    }
    return self;
}

-(void) dealloc {
    [super dealloc];
    delegate = nil;
}

@end
