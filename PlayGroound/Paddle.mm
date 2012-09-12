//
//  Paddle.mm
//  PlayGroound
//
//  Created by Jason Parlour on 12-09-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define PTM_RATIO (IS_IPAD() ? (32.0*1024.0/480.0) : 32.0)

#define PADDLE_SPRING_FORCE 15.0
#define PADDLE_TORQUE_FORCE 20.0
#define ANGLE_TRIGGER 30.0 * M_PI/180.0

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
        b2Vec2(0.7 , 0.15),
        b2Vec2(-0.7 , 0.15),
        b2Vec2(-0.7 , -0.15),
        b2Vec2(0.7, -0.15)
    };
    
    shape.Set(vert, 4);
    body->CreateFixture(&fixtureDef);
    
    b2CircleShape circle;
    circle.m_radius = 0.15;
    circle.m_p = b2Vec2(0.7, 0);
    fixtureDef.shape = &circle;
    
    body->CreateFixture(&fixtureDef);
    
    circle.m_p = b2Vec2(-0.7, 0);
    
    body->CreateFixture(&fixtureDef);
    body->SetSleepingAllowed(NO);
    body->SetLinearDamping(1.0f);
    body->SetAngularDamping(5.0f);
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
    b2Vec2 targetLine = rightTarget - leftTarget;
    
    float targetAngle = atan2f( targetLine.y , targetLine.x );
    if (targetAngle < 0){
        targetAngle += 2.0 * M_PI;
    }

    float curAngle = body->GetAngle();
    
    while (curAngle <  0.0f){
        curAngle += 2.0f * M_PI;
    }
    while (curAngle >= 2.0f * M_PI){
        curAngle -= 2.0f * M_PI;
    }
    
    //Correct To Horizontal
    float torqueToApply = 0;
    
    if ((targetAngle < 0.25f) || 
        (targetAngle > 6.0f)) {
           if (curAngle >= 3.0 * M_PI_2){
               torqueToApply = body->GetMass() * PADDLE_TORQUE_FORCE * (2.0 * M_PI - curAngle);
           } else if (curAngle >= 2.0 * M_PI_2){
               torqueToApply = -body->GetMass() * PADDLE_TORQUE_FORCE * (curAngle - M_PI);
           } else if (curAngle >= 1.0 * M_PI_2){
               torqueToApply = body->GetMass() * PADDLE_TORQUE_FORCE * (M_PI - curAngle);
           } else {
               torqueToApply = -body->GetMass() * PADDLE_TORQUE_FORCE * (curAngle);
           }
    }
     else {
         if ((targetAngle > 0.25f) && (targetAngle < 1.0f)){
             CCLOG(@"Right Power Shot");
             [self rightPowerShot];
         } else {
             CCLOG(@"Left Power Shot");
             [self leftPowerShot];
         }
    }
    
    
    b2Vec2 newPos = b2Vec2(((leftPos.x + rightPos.x) / 2 / PTM_RATIO) + (offset * 10.0 / PTM_RATIO), 
                           ((leftPos.y + rightPos.y) / 2 / PTM_RATIO) + (42 / PTM_RATIO));
    if (newPos.y > 2 ){
        newPos.y = 2;
    }
    
    b2Vec2 targetPos = newPos - paddlecenter;
    float length = targetPos.Length();
    
    b2Vec2 force;
    force.x = PADDLE_SPRING_FORCE * targetPos.x * body->GetMass() * length;
    force.y = PADDLE_SPRING_FORCE * targetPos.y * body->GetMass() * length;
    
    body->ApplyForce(force, body->GetWorldCenter());
    body->ApplyTorque(torqueToApply);
}  

-(void) leftPowerShot {
    float torque = -165.0f;
    body->ApplyTorque(torque);
}

-(void) rightPowerShot {
    float torque = 165.0f;
    body->ApplyTorque(torque);
}

@end
