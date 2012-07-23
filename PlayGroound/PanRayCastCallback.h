//
//  RayCastCallback.h
//  CutCutCut
//
//  Created by alex on 12-07-09.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef PanRayCastCallback_h
#define PanRayCastCallback_h

#import "Box2D.h"
#import "RocketMan.h"

class PanRayCastCallback: public b2RayCastCallback
{
public:
PanRayCastCallback(){}
    
float32 ReportFixture(b2Fixture *fixture, const b2Vec2 &point, const b2Vec2 &normal, float32 fraction)
{
    RocketMan *rocketman = (RocketMan *)fixture->GetBody()->GetUserData();
    [rocketman executePanMove];
    return 1;
}

};

#endif
