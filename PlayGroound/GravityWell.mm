//
//  GravityWell.m
//  PlayGroound
//
//  Created by alex on 12-08-09.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GravityWell.h"
#import "Box2DHelpers.h"

#define GW_GRAV_FORCE 350.0
#define GW_GF_TANGENT_FRAC 0.5
#define GW_DEAD_ZONE_RADIUS_FRACTION 0.15

@implementation GravityWell
-(void) createBodyAtLocation:(b2Vec2) location withRadius:(float) radius
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position = b2Vec2(location.x, location.y);
    
    self.body = world->CreateBody(&bodyDef);
    body->SetUserData(self);
    
    b2CircleShape shape;
    shape.m_radius = radius;
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
    fixtureDef.isSensor = true;

    body->CreateFixture(&fixtureDef); 
    
    deadZoneRad = radius*GW_DEAD_ZONE_RADIUS_FRACTION;
    
    forceOn = true;
    initialImpactVector = b2Vec2_zero;
/*    
    shape.m_radius = radius/3.0f;
    fixtureDef.isSensor = false;
    fixtureDef.friction = 0.0f;
    fixtureDef.restitution = 0.0f;
    
    body->CreateFixture(&fixtureDef);
*/
}

-(id) initWithWorld:(b2World *)theWorld atLocation:(b2Vec2)location withRadius:(float) radius
{
    if ((self = [super init]))
    {
        world = theWorld;
        //[self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"spikes.png"]];
        gameObjType = kObjTypeGravityWell;
        [self createBodyAtLocation:location withRadius:radius];
    }
    return self;
}
/*
-(void)updateStateWithDeltaTime:(ccTime)dt
{
    GameCharPhysics* rocketBody = isBodyCollidingWithObjectType(body, kObjTypeRocket);
    if (rocketBody != NULL)
    {
        if (forceOn)
        {
            //get a vector pointing from the rocket to the center of the gravity well
            b2Vec2 gravityForce = body->GetWorldCenter() - rocketBody.body->GetWorldCenter();
            //get it's length
            float gravityMag = gravityForce.Normalize();
            //if it's not too close to the center
            if (gravityMag >= deadZoneRad)
            {
                //apply a force that is inversely proportional to the distance apart
                gravityMag = GW_MG*rocketBody.body->GetMass()/gravityMag/gravityMag/gravityMag;
                gravityForce.x *= gravityMag;
                gravityForce.y *= gravityMag;
                rocketBody.body->ApplyForceToCenter(gravityForce);
            }
            //otherwise stop applying a force until the rocket leaves again to creat a slingshot effect
            else
            {
                forceOn = false;
            }
        }
    }
    // if we aren't colliding with the rocket and we were previously turned off, turn us back on
    else if (!forceOn)
    {
        forceOn = true;
    }
}
*/
-(void)updateStateWithDeltaTime:(ccTime)dt
{
    GameCharPhysics* rocketBody = isBodyCollidingWithObjectType(body, kObjTypeRocket);
    if (rocketBody != NULL)
    {
        //get a vector pointing from the rocket to the center of the gravity well
        b2Vec2 gravityForce = body->GetWorldCenter() - rocketBody.body->GetWorldCenter();
        //get it's length
        float gravityMag = gravityForce.Normalize();
        
        //see if we've been turned on yet.  If not, turn on, and register the initial vector
        if ((initialImpactVector.x == 0.0f) && (initialImpactVector.y == 0.0f))
        {
            forceOn = true;
            initialImpactVector.x = gravityForce.x;
            initialImpactVector.y = gravityForce.y;
        }
        
        // if the dotProd is negative, we passed the 90 degree angle
        if (forceOn)
        {
            // calculate the dot product - we'll track this to see when to turn off the force
            float dotProd = b2Dot(initialImpactVector, gravityForce);
            if (dotProd >= -0.9f)
            {
                //apply 1 force that pulls it in to the center
                gravityMag = GW_GRAV_FORCE*rocketBody.body->GetMass();
                gravityForce.x *= gravityMag;
                gravityForce.y *= gravityMag;
                rocketBody.body->ApplyForceToCenter(gravityForce);
                
                // apply a second tangential force in line with the velocity of the rocket
                b2Vec2 rocketVelocity = rocketBody.body->GetLinearVelocity();
                
                //cross the two vectors
                float xProd = gravityForce.x * rocketVelocity.y - gravityForce.y * rocketVelocity.x;
                if (xProd < 0)
                {
                    float temp = gravityForce.y*GW_GF_TANGENT_FRAC;
                    gravityForce.y = -gravityForce.x*GW_GF_TANGENT_FRAC;
                    gravityForce.x = temp;
                }
                else 
                {
                    float temp = -gravityForce.y*GW_GF_TANGENT_FRAC;
                    gravityForce.y = gravityForce.x*GW_GF_TANGENT_FRAC;
                    gravityForce.x = temp;
                }
                rocketBody.body->ApplyForceToCenter(gravityForce);
            }
            else
            {
                //turn off the force
                forceOn = false;
            }
            
        }
    }
    // if we aren't colliding with the rocket and we were previously turned off, turn us back on
    else if (!forceOn)
    {
        forceOn = true;
    }
}

@end
