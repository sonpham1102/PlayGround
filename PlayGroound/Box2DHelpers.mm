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
            GameCharPhysics *spriteA = 
            (GameCharPhysics *) bodyA->GetUserData();
            GameCharPhysics *spriteB = 
            (GameCharPhysics *) bodyB->GetUserData();
            if ((spriteA != NULL && 
                 spriteA.gameObjType == objectType) ||
                (spriteB != NULL && 
                 spriteB.gameObjType == objectType)) {
                    return true;
                }        
        }
        edge = edge->next;
    }    
    return false;
}
