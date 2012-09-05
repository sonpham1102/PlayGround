//
//  Level4ContactListener.h
//  PlayGroound
//
//  Created by Jason Parlour on 12-09-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "Box2D.h"
#import <vector>
#import <algorithm>

struct Level4Contact {
    b2Fixture *fixtureA;
    b2Fixture *fixtureB;
    bool operator==(const Level4Contact& other) const
    {
        return (fixtureA == other.fixtureA) && (fixtureB == other.fixtureB);
    }
};

class Level4ContactListener : public b2ContactListener {
    
public:
    std::vector<Level4Contact>_contacts;
    
    Level4ContactListener();
    ~Level4ContactListener();
    
    virtual void BeginContact(b2Contact* contact);
    virtual void EndContact(b2Contact* contact);
    virtual void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);    
    virtual void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
    
};
