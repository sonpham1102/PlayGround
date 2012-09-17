//
//  SimpleQueryCallback.h
//  SpaceViking
//
//  Created by alex on 12-06-28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//#ifndef SpaceViking_SimpleQueryCallback_h
//#define SpaceViking_SimpleQueryCallback_h

#import "Box2D.h"

class SimpleQueryCallback : public b2QueryCallback
{
public:
    b2Vec2 pointToTest;
    b2Fixture *fixtureFound;
    
    SimpleQueryCallback(const b2Vec2& point)
    {
        pointToTest = point;
        fixtureFound = NULL;
    }
    
    bool ReportFixture (b2Fixture* fixture)
    {
        b2Body* body = fixture->GetBody();
        if (body->GetType() == b2_dynamicBody)
        {
            if (fixture->TestPoint(pointToTest))
            {
                fixtureFound = fixture;
                return false;
            }
        }
        return true;
    }
};

//#endif
