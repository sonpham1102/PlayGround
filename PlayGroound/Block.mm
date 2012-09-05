//
//  Block.mm
//  PlayGroound
//
//  Created by Jason Parlour on 12-09-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Block.h"

#define PTM_RATIO (IS_IPAD() ? (32.0*1024.0/480.0) : 32.0)

@implementation Block

-(id)initWithWorld:(b2World*)theWorld atLocation:(CGPoint)location {
    if ((self = [super init])){
        world = theWorld;
        gameObjType = kObjTypeBlock;
        [self createBodyAtLocation:location];
    }
    return self;
}

-(void)updateStateWithDeltaTime:(ccTime)dt {
    
}

-(void) createBodyAtLocation:(CGPoint)location {
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position = b2Vec2(location.x/PTM_RATIO,
                              location.y/PTM_RATIO);
    
    body = world->CreateBody(&bodyDef);
    
    b2FixtureDef fixtureDef;
    fixtureDef.density = 1.0f;
    fixtureDef.restitution = 1.0f;
    fixtureDef.friction = 1.0f;
    
    b2PolygonShape shape;
    b2Vec2 verts[] = {
        
        b2Vec2(15.0 / PTM_RATIO, 7.0 / PTM_RATIO),
        b2Vec2(-15.0 / PTM_RATIO, 7.0 / PTM_RATIO),
        b2Vec2(-15.0 / PTM_RATIO, -7.0 / PTM_RATIO),
        b2Vec2(15.0 / PTM_RATIO, -7.0 / PTM_RATIO)
        
    };
    shape.Set(verts, 4);
    fixtureDef.shape = &shape;
    
    body->CreateFixture(&fixtureDef);
    
    body->SetUserData(self);
}

@end
