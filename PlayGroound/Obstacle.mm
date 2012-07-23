//
//  Obstale.mm
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Obstacle.h"

@implementation Obstacle

-(void)createBodyAtLocation:(CGPoint)location {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position = b2Vec2(location.x/PTM_RATIO,location.y/PTM_RATIO);
    
    body = world->CreateBody(&bodyDef);
    body->SetUserData(self);
    
    
    b2PolygonShape shape;
    shape.SetAsBox(winSize.width*1.5/2/PTM_RATIO, 
                   winSize.height*0.1f/2/PTM_RATIO,
                   b2Vec2(0, 5.0/100.0),0);
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
    fixtureDef.density = 1000.0;
    
    body->CreateFixture(&fixtureDef);
}


-(id) initWithWorld:(b2World *)theWorld atLoaction:(CGPoint)location {
    
    if ((self = [super init])) {
        world = theWorld;
        gameObjType = kObjTypeObstacle;
        [self createBodyAtLocation:location];
    }
    return self;
}

@end
