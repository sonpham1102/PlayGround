//
//  Box2DHelpers.mm
//  SpaceViking
//
//  Created by Ray Wenderlich on 3/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Box2DHelpers.h"
#import "GameCharPhysics.h"

bool isBodyCollidingWithObjectType(b2Body *body, GameObjType objectType) {
    b2ContactEdge* edge = body->GetContactList();
    while (edge)
    {
        b2Contact* contact = edge->contact;
        if (contact->IsTouching()) {        
            b2Fixture* fixtureA = contact->GetFixtureA();
            b2Fixture* fixtureB = contact->GetFixtureB();
            b2Body *bodyA = fixtureA->GetBody();
            b2Body *bodyB = fixtureB->GetBody();
       /*     Box2DSprite *spriteA = 
            (Box2DSprite *) bodyA->GetUserData();
            Box2DSprite *spriteB = 
            (Box2DSprite *) bodyB->GetUserData();
            if ((spriteA != NULL && 
                 spriteA.gameObjectType == objectType) ||
                (spriteB != NULL && 
                 spriteB.gameObjectType == objectType))*/ {
                    return true;
                }        
        }
        edge = edge->next;
    }    
    return false;
}
