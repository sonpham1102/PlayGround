//
//  Box2DHelpers.mm
//  SpaceViking
//
//  Created by Ray Wenderlich on 3/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Box2DHelpers.h"
#import "GameCharPhysics.h"
#import "Rocket.h"


GameCharPhysics* isBodyCollidingWithObjectType(b2Body *body, GameObjType objectType) {
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
        
            if ((spriteA != NULL) && (spriteA.gameObjType == objectType))
                return spriteA;
            if ((spriteB != NULL) && (spriteB.gameObjType == objectType))  
                return spriteB;
        }
        edge = edge->next;
    }    
    return NULL;
}

bool isSensorCollidingWithObjectType(b2Body *body, GameObjType objectType,b2Fixture* fixture,b2World *world) {
    b2ContactEdge* edge = body->GetContactList();
    b2Body *bodyHit;

    while (edge)
    {
        b2Contact* contact = edge->contact;
        if (contact->IsTouching()) {
            b2Fixture* fixtureA = contact->GetFixtureA();
            b2Fixture* fixtureB = contact->GetFixtureB();
            b2Body *initBody;
            if ((fixtureA == fixture) || (fixtureB == fixture)) {
                if (fixtureA == fixture) {
                    bodyHit = fixtureB->GetBody();
                    initBody = fixtureA->GetBody();
                } else {
                    bodyHit = fixtureA->GetBody();
                    initBody = fixtureB->GetBody();
                }
                GameCharPhysics *spriteA = (GameCharPhysics *)bodyHit->GetUserData();
                GameCharPhysics *spriteB = (GameCharPhysics *)initBody->GetUserData();
                if (spriteA.gameObjType == objectType) {
                    if ((spriteA.gameObjType == kObjTypeAsteroid) && (spriteB.gameObjType == kobjTypeBullet)){
                        //spriteA.destroyMe = true;
                        world->DestroyBody(bodyHit);
                        spriteA.body = NULL;
                        [spriteA removeFromParentAndCleanup:YES];
                    }
                    return true;
                }
            }
        }
        edge = edge->next;
    }    
    return false;  
}

bool isSensorCollidingWithObjectType(b2Body *body, GameObjType objectType,b2Fixture* fixture) {
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

            if ((fixtureA == fixture) || (fixtureB == fixture))
            {
                if ((spriteA != NULL && spriteA.gameObjType == objectType) ||
                    (spriteB != NULL && spriteB.gameObjType == objectType))
                {
                    return true;
                }
            }
        }
        edge = edge->next;
    }    
    return false;
}




