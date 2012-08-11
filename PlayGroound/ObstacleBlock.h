//
//  ObstacleBlock.h
//  PlayGroound
//
//  Created by alex on 12-08-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameCharPhysics.h"

@interface ObstacleBlock : GameCharPhysics
{
    b2World *world;
}

//location should be in meters so that this object doesn't need the know that layer's PTM_RATIO
-(id)initWithWorld:(b2World*)theWorld atLocation:(b2Vec2) location withWidth: (float) width withHeight:(float) height withOffsetAngle:(float) angleOffset;

@end
