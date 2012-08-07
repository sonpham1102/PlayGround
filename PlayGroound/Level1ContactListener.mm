//
//  Level1ContactListener.mm
//  PlayGroound
//
//  Created by Jason Parlour on 12-08-06.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Level1ContactListener.h"
#import "GameCharPhysics.h"
#import "Asteroid.h"


Level1ContactListener::Level1ContactListener() : _contacts() {
}

Level1ContactListener::~Level1ContactListener() {
}

void Level1ContactListener::BeginContact(b2Contact* contact) {

}

void Level1ContactListener::EndContact(b2Contact* contact) {
    
}

void Level1ContactListener::PreSolve(b2Contact* contact, 
                                 const b2Manifold* oldManifold) {
}

void Level1ContactListener::PostSolve(b2Contact* contact, 
                                  const b2ContactImpulse* impulse) {
    b2Manifold *manifold = contact->GetManifold();
    
    b2Fixture* fixtureA = contact->GetFixtureA();
    b2Fixture* fixtireB = contact->GetFixtureB();
    b2Body *bodyA = fixtureA->GetBody();
    b2Body *bodyB = fixtireB->GetBody();
    GameCharPhysics *spriteA = (GameCharPhysics*) bodyA->GetUserData();
    GameCharPhysics *spriteB = (GameCharPhysics*) bodyB->GetUserData();
    
    if (spriteA.gameObjType == kobjTypeBullet) {
        spriteA.destroyMe = true;
        
    } else if (spriteB.gameObjType == kobjTypeBullet) {
        spriteB.destroyMe = true;
    }
    
    if ((spriteA.gameObjType == kObjTypeAsteroid || spriteB.gameObjType == kObjTypeAsteroid) && 
    (spriteA.gameObjType == kobjTypeBullet || spriteB.gameObjType == kobjTypeBullet)){
        if (spriteA.gameObjType == kObjTypeAsteroid) {
            b2Vec2 impulsePower = spriteB.body->GetLinearVelocity();
            impulsePower.x /= 10;
            impulsePower.y /= 10;
            spriteA.body->ApplyLinearImpulse(impulsePower, manifold->points->localPoint);
            spriteA.characterHealth -= 10;
            if (spriteA.characterHealth <= 0) {
                 spriteA.destroyMe = true;
            }
        } else if (spriteB.gameObjType == kObjTypeAsteroid) {
            b2Vec2 impulsePower = spriteA.body->GetLinearVelocity();
            impulsePower.x /= 10;
            impulsePower.y /= 10;
            spriteB.body->ApplyLinearImpulse(impulsePower, manifold->points->localPoint);
            spriteB.characterHealth -= 10;
            if (spriteB.characterHealth <= 0) {
                spriteB.destroyMe = true;
            }
        }
        
    }
}


