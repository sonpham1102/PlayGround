//
//  JumperMan.mm
//  PlayGroound
//
//  Created by Jason Parlour on 12-09-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JumperMan.h"

@implementation JumperMan

-(id)initWithWorld:(b2World*)theWorld atLocation:(CGPoint)location {
    if ((self = [super init])){
        world = theWorld;
        gameObjType = kObjTypeBlock;
        [self buildJumperManAtLocation:location];
    }
    return self;
}

-(void) buildJumperManAtLocation:(CGPoint)location {
    
    head = [self createHead:location];
    torso = [self createTorso:location];
    
    b2RevoluteJointDef revJointDef;
    revJointDef.Initialize(head , torso,
                           torso->GetWorldPoint(b2Vec2(0, 20.0/100.0)));
    revJointDef.lowerAngle = CC_DEGREES_TO_RADIANS(-15);
    revJointDef.upperAngle = CC_DEGREES_TO_RADIANS(15);
    revJointDef.enableLimit = true;
    world->CreateJoint(&revJointDef);
    
}
-(b2Body*) createTorso:(CGPoint)location {
    
    b2Body* retVal;
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = b2Vec2(location.x,location.y);
    
    retVal = world->CreateBody(&bodyDef);
    
    b2FixtureDef fixtureDef;
    fixtureDef.density = 1.0;
    fixtureDef.friction = 1.0;
    fixtureDef.restitution = 1.0;
    
    fixtureDef.filter.categoryBits = 0x2;
    fixtureDef.filter.maskBits = 0xFFFF;
    fixtureDef.filter.groupIndex = -1;
    
    b2PolygonShape torsoShape;
    b2Vec2 verts[] = {
        b2Vec2(0.5,1.5),
        b2Vec2(-0.5,1.5),
        b2Vec2(-0.3,-1.5),
        b2Vec2(0.5,-0.70),
        b2Vec2(0.6,0.2),
        b2Vec2(0.6,0.6)
    };
    
    torsoShape.Set(verts, 6);
    fixtureDef.shape = &torsoShape;
    
    retVal->CreateFixture(&fixtureDef);
    
    return retVal;
}

-(b2Body*) createHead:(CGPoint)location {
    
    b2Body* retVal;
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = b2Vec2(location.x,location.y);
    
    retVal = world->CreateBody(&bodyDef);
    
    b2FixtureDef fixtureDef;
    fixtureDef.density = 1.0;
    fixtureDef.friction = 1.0;
    fixtureDef.restitution = 1.0;
    
    fixtureDef.filter.categoryBits = 0x2;
    fixtureDef.filter.maskBits = 0xFFFF;
    fixtureDef.filter.groupIndex = -1;
    
    b2CircleShape shape;
    fixtureDef.shape = &shape;
    shape.m_radius = 1.0;
    shape.m_p = b2Vec2(0,2.5);
    
    retVal->CreateFixture(&fixtureDef);
    
    return retVal;
}

-(void) createBodyAtLocation:(CGPoint)location {
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_kinematicBody;
    bodyDef.position = b2Vec2(location.x,location.y);
    
    body = world->CreateBody(&bodyDef);
    
    b2FixtureDef fixtureDef;
    fixtureDef.density = 1.0;
    fixtureDef.friction = 1.0;
    fixtureDef.restitution = 1.0;
    
    b2CircleShape shape;
    fixtureDef.shape = &shape;
    shape.m_radius = 0.5;
    shape.m_p = b2Vec2(0,1.25);
    
    body->CreateFixture(&fixtureDef);
    
    b2PolygonShape torsoShape;
    b2Vec2 verts[] = {
            b2Vec2(0.25,0.75),
            b2Vec2(-0.25,0.75),
            b2Vec2(-0.25,-0.75),
            b2Vec2(0.25,-0.75)
    };
    
    torsoShape.Set(verts, 4);
    fixtureDef.shape = &torsoShape;
    
    body->CreateFixture(&fixtureDef);
    
    body->SetUserData(self);
}


@end
