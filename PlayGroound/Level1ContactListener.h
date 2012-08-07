#import "Box2D.h"
#import <vector>
#import <algorithm>

struct Level1Contact {
    b2Fixture *fixtureA;
    b2Fixture *fixtureB;
    bool operator==(const Level1Contact& other) const
    {
        return (fixtureA == other.fixtureA) && (fixtureB == other.fixtureB);
    }
};

class Level1ContactListener : public b2ContactListener {
    
public:
    std::vector<Level1Contact>_contacts;
    
    Level1ContactListener();
    ~Level1ContactListener();
    
    virtual void BeginContact(b2Contact* contact);
    virtual void EndContact(b2Contact* contact);
    virtual void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);    
    virtual void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
    
};
