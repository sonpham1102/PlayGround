//
//  BounceTriangle.m
//  PlayGroound
//
//  Created by alex on 12-08-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BounceTriangle.h"

@implementation BounceTriangle

-(void) createBodyAtLocation:(b2Vec2) location withSize: (float) size withAngle:(float) angle withOffsetAngle:(float) angleOffset
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position = b2Vec2(location.x, location.y);
    
    self.body = world->CreateBody(&bodyDef);
    body->SetUserData(self);
    
    //the size is the length of the hypoteneuse
    float halfWidth = cosf(angle*M_PI_2/180.0f)*size/2.0f;
    float halfHeight = sinf(angle*M_PI_2/180.0f)*size;
    
    b2PolygonShape shape;
    b2Vec2 verts[]={
            b2Vec2(halfWidth, 0.0f),
            b2Vec2(-halfWidth, halfHeight),
            b2Vec2(-halfWidth, -halfHeight) };
        
    shape.Set(verts, 3);

    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
    
    fixtureDef.friction = 0.0f;
    fixtureDef.restitution = 3.0f;
    body->CreateFixture(&fixtureDef);
    
    body->SetTransform(body->GetPosition(), angleOffset*M_PI_2/180.0f);
}


-(id)initWithWorld:(b2World*)theWorld atLocation:(b2Vec2) location withSize: (float) size withAngle:(float) angle withOffsetAngle:(float)angleOffset
{
    if ((self = [super init]))
    {
        world = theWorld;
        //[self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"spikes.png"]];
        gameObjType = kObjTypeBounceTriangle;
        [self createBodyAtLocation:location withSize: size withAngle:angle withOffsetAngle:angleOffset];
    }
    return self;    
}

@end
