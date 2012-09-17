//
//  PlayGround7Layer.mm
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "PlayGround7Scene.h"
#import "PlayGround7Layer.h"
// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#import "GameCharPhysics.h"

#import "SmashBallChain.h"

#import "GameManager.h"

#import "SimpleQueryCallback.h"

#define NUM_CHAINS 9

enum {
	kTagParentNode = 1,
};


@interface PlayGround7Layer()
-(void) initPhysics;
@end

@implementation PlayGround7Layer

- (void) registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(void) createBackground {
    
//    CGSize winSize = [CCDirector sharedDirector].winSize;
}

-(void) createSmashBall: (CGPoint) location
{
    b2Vec2 loc = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    //create the smash ball
    smashBallMain = [[SmashBallMain alloc] initWithWorld:world atLocation:loc];
    [sceneSpriteBatchNode addChild:smashBallMain z:5];
    
/*    
    //create the first chain link
    loc.x = SBM_JOINT_OFFSET + SBC_JOINT_OFFSET;
    loc.y = 0.0f;
    loc = smashBallMain.body->GetWorldPoint(loc);
    SmashBallChain* chain1 = [[SmashBallChain alloc] initWithWorld:world atLocation:loc];
    
    //connect it to the main ball
    b2RevoluteJointDef revJointDef;
    revJointDef.Initialize(smashBallMain.body, chain1.body, smashBallMain.body->GetWorldPoint(b2Vec2(SBM_JOINT_OFFSET,0)));
    //revJointDef.lowerAngle = CC_DEGREES_TO_RADIANS(-15);
    //revJointDef.upperAngle = CC_DEGREES_TO_RADIANS(15);
    //revJointDef.enableLimit = true;
    //revJointDef.enableMotor = true;
    //revJointDef.motorSpeed = 0.5;
    //revJointDef.maxMotorTorque = 50.0f;
    world->CreateJoint(&revJointDef);
    
    //create the second chain link and add it to the first
    loc.x = SBC_JOINT_OFFSET + SBC_JOINT_OFFSET;
    loc.y = 0.0f;
    loc = chain1.body->GetWorldPoint(loc);
    SmashBallChain* chain2 = [[SmashBallChain alloc] initWithWorld:world atLocation:loc];
    revJointDef.Initialize(chain1.body, chain2.body, chain1.body->GetWorldPoint(b2Vec2(SBC_JOINT_OFFSET,0)));

    //create a third and link it to the second
    loc.x = SBC_JOINT_OFFSET + SBC_JOINT_OFFSET;
    loc.y = 0.0f;
    loc = chain2.body->GetWorldPoint(loc);
    SmashBallChain* chain3 = [[SmashBallChain alloc] initWithWorld:world atLocation:loc];
    revJointDef.Initialize(chain2.body, chain3.body, chain2.body->GetWorldPoint(b2Vec2(SBC_JOINT_OFFSET,0)));
    
    //create the end ball and link it to the third chain
    loc.x = SBC_JOINT_OFFSET + SBE_JOINT_OFFSET;
    loc.y = 0.0f;
    loc = chain3.body->GetWorldPoint(loc);
    smashBallEnd = [[SmashBallEnd alloc] initWithWorld:world atLocation:loc];
    revJointDef.Initialize(chain3.body, smashBallEnd.body, chain3.body->GetWorldPoint(b2Vec2(SBC_JOINT_OFFSET,0)));
*/
    //create the first chain link
    loc.x = SBM_JOINT_OFFSET + SBC_JOINT_OFFSET;
    loc.y = 0.0f;
    loc = smashBallMain.body->GetWorldPoint(loc);
    SmashBallChain* chain = [[SmashBallChain alloc] initWithWorld:world atLocation:loc];
    b2RevoluteJointDef revJointDef;
    revJointDef.Initialize(smashBallMain.body, chain.body, smashBallMain.body->GetWorldPoint(b2Vec2(SBM_JOINT_OFFSET,0)));
    world->CreateJoint(&revJointDef);
    [sceneSpriteBatchNode addChild:chain z:5];
    //[chain release];

    // create all remaining chains
    for (int i = 1; i < NUM_CHAINS; i++)
    {
        loc.x = SBC_JOINT_OFFSET*2.0;
        loc.y = 0.0f;
        loc = chain.body->GetWorldPoint(loc);
        SmashBallChain* nextChain = [[SmashBallChain alloc] initWithWorld:world atLocation:loc];
        revJointDef.Initialize(chain.body, nextChain.body, chain.body->GetWorldPoint(b2Vec2(SBC_JOINT_OFFSET,0)));
        world->CreateJoint(&revJointDef);
        [sceneSpriteBatchNode addChild:nextChain z:5];
        //[nextChain release];
        chain = nextChain;
    }
    //create the end ball and link it to the third chain
    loc.x = SBC_JOINT_OFFSET + SBE_JOINT_OFFSET;
    loc.y = 0.0f;
    loc = chain.body->GetWorldPoint(loc);
    smashBallEnd = [[SmashBallEnd alloc] initWithWorld:world atLocation:loc];
    revJointDef.Initialize(chain.body, smashBallEnd.body, chain.body->GetWorldPoint(b2Vec2(SBC_JOINT_OFFSET,0)));
    world->CreateJoint(&revJointDef);

    [sceneSpriteBatchNode addChild:smashBallEnd z:5];
}

-(id) init
{
	if( (self=[super init])) {
		
		// enable events
		
		self.isTouchEnabled = YES;
        
		self.isAccelerometerEnabled = YES;
		CGSize s = [CCDirector sharedDirector].winSize;
		
		// init physics
		[self initPhysics];
		        
        sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithTexture:nil];
        [self addChild:sceneSpriteBatchNode z:0];
        
        [self createSmashBall:ccp(s.width/2.0, s.height/2.0)];
        
        [self createBackground];
		
		[self scheduleUpdate];
	}
	return self;
}

-(void) dealloc
{
	delete world;
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
    
	[super dealloc];
}	

-(void) initPhysics
{
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	b2Vec2 gravity;
	gravity.Set(/*-10.0f*/0.0f, 0.0f);
	world = new b2World(gravity);
	
	
	// Do we want to let bodies sleep?
	world->SetAllowSleeping(true);
	
	world->SetContinuousPhysics(true);
	
	m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	world->SetDebugDraw(m_debugDraw);
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	//		flags += b2Draw::e_jointBit;
	//		flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
	m_debugDraw->SetFlags(flags);		
	
	
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	groundBody = world->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	b2EdgeShape groundBox;		
	
	// bottom
	
	groundBox.Set(b2Vec2(0,0), b2Vec2(s.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// top
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO));
	groundBody->CreateFixture(&groundBox,0);
	
	// left
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(0,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// right
	groundBox.Set(b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
}

-(void) draw
{
	//
	// IMPORTANT:
	// This is only for debug purposes
	// It is recommend to disable it
	//
	[super draw];
	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	kmGLPushMatrix();
	
	world->DrawDebugData();	
    
    //ccDrawLine(debugLineStartPoint, debugLineEndPoint);
	
	kmGLPopMatrix();
}


-(void) handlePan:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{

}

-(void) handleTap:(CGPoint)tapPoint
{

}

-(void) handleRotation:(float)angleDelta
{

}

-(void) handleLongPress:(BOOL)continueFiring
{

}

-(void) update: (ccTime) dt
{
    static double UPDATE_INTERVAL = 1.0/60.0f;
    static double MAX_CYCLES_PER_FRAME = 5;
    static double timeAccumulator = 0;
    
    timeAccumulator += dt;
    
    if (timeAccumulator > (MAX_CYCLES_PER_FRAME * UPDATE_INTERVAL))
    {
        timeAccumulator = MAX_CYCLES_PER_FRAME * UPDATE_INTERVAL;
    }
    
    int32 velocityIterations = 50;
    int32 positionIterations = 50;
    while (timeAccumulator >= UPDATE_INTERVAL)
    {
        timeAccumulator -= UPDATE_INTERVAL;
        world->Step(UPDATE_INTERVAL, velocityIterations, positionIterations);
    }

    for (b2Body *b=world->GetBodyList(); b !=  NULL; b=b->GetNext())
    {
        if (b->GetUserData() != NULL)
        {
            GameCharPhysics *sprite = (GameCharPhysics *) b->GetUserData();
            sprite.position = ccp(b->GetPosition().x*PTM_RATIO, b->GetPosition().y*PTM_RATIO);
            sprite.rotation = CC_RADIANS_TO_DEGREES(b->GetAngle() * -1);
        }
    }   
    
    CCArray *listOfGameObjects = [sceneSpriteBatchNode children];
    for (GameChar *tempChar in listOfGameObjects)
    {
        [tempChar updateStateWithDeltaTime:dt];
    }    
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInView:[touch view]];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    b2Vec2 locationWorld = b2Vec2(touchLocation.x/PTM_RATIO, touchLocation.y/PTM_RATIO);
    
    b2AABB aabb;
    b2Vec2 delta = b2Vec2(1.0/PTM_RATIO, 1.0/PTM_RATIO);
    
    aabb.lowerBound = locationWorld - delta;
    aabb.upperBound = locationWorld + delta;
    
    SimpleQueryCallback callback(locationWorld);
    
    world->QueryAABB(&callback, aabb);
    
    if (callback.fixtureFound)
    {
        b2Body *body = callback.fixtureFound->GetBody();
        
        GameCharPhysics *sprite = (GameCharPhysics *) body->GetUserData();
        if (sprite == NULL) return FALSE;
        if (![sprite mouseJointAccept]) return FALSE;
        
        b2MouseJointDef mouseJointDef;
        mouseJointDef.bodyA = groundBody;
        mouseJointDef.bodyB = body;
        mouseJointDef.target = locationWorld;
        mouseJointDef.maxForce = 10000*body->GetMass();
        mouseJointDef.collideConnected = true;
        
        mouseJoint = (b2MouseJoint *) world->CreateJoint(&mouseJointDef);
        body->SetAwake(true);
        return YES;
    }
    
    return TRUE;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInView:[touch view]];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    b2Vec2 locationWorld = b2Vec2(touchLocation.x/PTM_RATIO, touchLocation.y/PTM_RATIO);
    if (mouseJoint)
    {
        mouseJoint->SetTarget(locationWorld);
    }
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (mouseJoint)
    {
        world->DestroyJoint(mouseJoint);
        mouseJoint = NULL;
    }
}

@end
