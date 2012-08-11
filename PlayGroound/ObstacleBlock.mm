//
//  ObstacleBlock.m
//  PlayGroound
//
//  Created by alex on 12-08-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ObstacleBlock.h"

@implementation ObstacleBlock

-(void) createBodyAtLocation:(b2Vec2) location withWidth: (float) width withHeight:(float) height withOffsetAngle: (float) angleOffset
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position = b2Vec2(location.x, location.y);
    
    self.body = world->CreateBody(&bodyDef);
    body->SetUserData(self);
    
    b2PolygonShape shape;
    b2Vec2 verts[]={
        b2Vec2(width/2.0f, height/2.0f),
        b2Vec2(-width/2.0f, height/2.0f),
        b2Vec2(-width/2.0f, -height/2.0f),
        b2Vec2(width/2.0f, -height/2.0f)};
    
    shape.Set(verts, 4);
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
    fixtureDef.restitution = 0.0f;
    fixtureDef.friction= 0.0f;
    
    body->CreateFixture(&fixtureDef);
    
    body->SetTransform(body->GetPosition(), angleOffset*M_PI_2/180.0f);
}

-(id)initWithWorld:(b2World*)theWorld atLocation:(b2Vec2) location withWidth: (float) width withHeight:(float) height withOffsetAngle:(float)angleOffset
{
    if ((self = [super init]))
    {
        world = theWorld;
        //[self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"spikes.png"]];
        gameObjType = kObjTypeObstacleBlock;
        [self createBodyAtLocation:location withWidth:width withHeight:height withOffsetAngle:angleOffset];
    }
    return self;        
}

@end
