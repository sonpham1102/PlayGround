//
//  BounceTriangle.h
//  PlayGroound
//
//  Created by alex on 12-08-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameCharPhysics.h"

@interface BounceTriangle : GameCharPhysics
{
    b2World *world;
}

//location should be in meters so that this object doesn't need the know that layer's PTM_RATIO
-(id)initWithWorld:(b2World*)theWorld atLocation:(b2Vec2) location withSize: (float) size withAngle:(float) angle withOffsetAngle:(float) angleOffset;


@end
