//
//  Level4ContactListener.mm
//  PlayGroound
//
//  Created by Jason Parlour on 12-09-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Level4ContactListener.h"
#import "GameCharPhysics.h"


Level4ContactListener::Level4ContactListener() : _contacts() {
}

Level4ContactListener::~Level4ContactListener() {
}

void Level4ContactListener::BeginContact(b2Contact* contact) {
         
}

void Level4ContactListener::EndContact(b2Contact* contact) {
  
    
}

void Level4ContactListener::PreSolve(b2Contact* contact, 
                                     const b2Manifold* oldManifold) {
   
}




void Level4ContactListener::PostSolve(b2Contact* contact, 
                                      const b2ContactImpulse* impulse) {
    b2Fixture* fixtureA = contact->GetFixtureA();
    b2Fixture* fixtireB = contact->GetFixtureB();
    b2Body *bodyA = fixtureA->GetBody();
    b2Body *bodyB = fixtireB->GetBody();
    GameCharPhysics *spriteA = (GameCharPhysics*) bodyA->GetUserData();
    GameCharPhysics *spriteB = (GameCharPhysics*) bodyB->GetUserData();
    
    if ((spriteA.gameObjType == kObjTypeBlock || spriteB.gameObjType == kObjTypeBlock) &&
        (spriteB.gameObjType == kObjTypeBall || spriteA.gameObjType == kObjTypeBall)) {
        if (spriteA.gameObjType == kObjTypeBlock) {
            
            spriteA.destroyMe = true;

        } else if (spriteB.gameObjType == kObjTypeBlock) {
           
            spriteB.destroyMe = true;
            
        }
    }
    
}
