//
//  Obstale.mm
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Obstacle.h"
#define PTM_RATIO (IS_IPAD() ? (32.0*1024.0/480.0) : 32.0)

@implementation Obstacle

-(void)createBodyAtLocation:(CGPoint)location {
    
    //CGSize winSize = [CCDirector sharedDirector].winSize;
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position = b2Vec2(location.x/PTM_RATIO,location.y/PTM_RATIO);
    
    body = world->CreateBody(&bodyDef);
    
    b2PolygonShape shape;
    b2FixtureDef fixtureDef;
    fixtureDef.density = 15.0;
    fixtureDef.shape = &shape;

    //row 1, col 1
    /*
    int num = 7;
    b2Vec2 verts[] = {
        b2Vec2(-32.5f / PTM_RATIO, 105.0f / PTM_RATIO),
        b2Vec2(-38.5f / PTM_RATIO, 100.0f / PTM_RATIO),
        b2Vec2(-50.5f / PTM_RATIO, -27.0f / PTM_RATIO),
        b2Vec2(-15.5f / PTM_RATIO, -27.0f / PTM_RATIO),
        b2Vec2(-19.5f / PTM_RATIO, 63.0f / PTM_RATIO),
        b2Vec2(-24.5f / PTM_RATIO, 98.0f / PTM_RATIO),
        b2Vec2(-32.5f / PTM_RATIO, 106.0f / PTM_RATIO)
    };
    
    shape.Set(verts, num);
    body->CreateFixture(&fixtureDef);
    */
    int num = 4;
    
    b2Vec2 verts1[] = {
        b2Vec2(-50.0f / PTM_RATIO, -25.0f / PTM_RATIO),
        b2Vec2(-50.0f / PTM_RATIO, -97.0f / PTM_RATIO),
        b2Vec2(11.0f / PTM_RATIO, -97.0f / PTM_RATIO),
        b2Vec2(11.0f / PTM_RATIO, -25.0f / PTM_RATIO)
    };
    
    shape.Set(verts1, num);
    body->CreateFixture(&fixtureDef);
    
    
    num = 4;
    b2Vec2 verts2[] = {
        b2Vec2(11.0f / PTM_RATIO, -40.5f / PTM_RATIO),
        b2Vec2(11.0f / PTM_RATIO, -97.0f / PTM_RATIO),
        b2Vec2(78.5f / PTM_RATIO, -97.0f / PTM_RATIO),
        b2Vec2(114.5f / PTM_RATIO, -40.5f / PTM_RATIO)
    };
     
    
    shape.Set(verts2, num);
    body->CreateFixture(&fixtureDef);
    
    body->SetUserData(self);
}


-(id) initWithWorld:(b2World *)theWorld atLoaction:(CGPoint)location {
    
    if ((self = [super initWithFile:@"LandingPad.png"])) {
        world = theWorld;
        gameObjType = kObjTypeObstacle;
        [self createBodyAtLocation:location];
    }
    return self;
}

@end
