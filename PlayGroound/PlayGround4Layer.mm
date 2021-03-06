//
//  PlayGround4Layer.m
//  PlayGroound
//
//  Created by Jason Parlour on 12-09-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "PlayGround4Layer.h"
#import "PlayGroundScene4UILayer.h"
#import "BreakBlock.h"

#define PTM_RATIO (IS_IPAD() ? (32.0*1024.0/480.0) : 32.0)

#define LEVEL_HEIGHT 1 
#define LEVEL_WIDTH 1


@implementation PlayGround4Layer

@synthesize leftTouchPos;
@synthesize rightTouchPos;

-(CGPoint) getLeftTouchPos {
    return leftTouchPos;
}

-(CGPoint) getRightTouchPos {
    return rightTouchPos;
}

-(id) initWithUILayer:(PlayGroundScene4UILayer *)ui
{
	if( (self=[super init])) {
		
        uiLayer = ui;
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
		// Handle this onEnter and onExit
        self.isTouchEnabled = YES;
        
		self.isAccelerometerEnabled = YES;
		
		// init physics
		[self initPhysics];
        
        contactListener = new Level4ContactListener();
        world->SetContactListener(contactListener);
        
        sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithTexture:nil];
        [self addChild:sceneSpriteBatchNode z:0];
        
        [self buildLevel];
        
        thePaddle = [[Paddle alloc]initWithWorld:world atLocation:ccp(winSize.width * 0.5, 
                                                                       winSize.height * .05)];
        [thePaddle setDelegate:self];
        
        theBall = [[Ball alloc]initWithWorld:world atLocation:ccp(winSize.width * 0.5, 
                                                                  winSize.height * 0.5)];
        theBall.body->ApplyLinearImpulse(b2Vec2(0,-0.1f), b2Vec2(0,0));
        [sceneSpriteBatchNode addChild:thePaddle];
        [sceneSpriteBatchNode addChild:theBall];
         
        leftTouch = nil;
        rightTouch = nil;
        
        leftTouchPos = ccp(winSize.width/2.0 - 2.0*PTM_RATIO, winSize.height/2.0);
        rightTouchPos = ccp(winSize.width/2.0 + 2.0*PTM_RATIO, winSize.height/2.0);

        [self scheduleUpdate];
        
	}
	return self;
}


-(void) buildLevel {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    float row = 0.92;
    for (int r = 0; r < 5; r++) {
        for (float i = 1.0; i <= 9.0 ; i++) {
            BreakBlock* theBlock = [[BreakBlock alloc] initWithWorld:world atLocation:ccp(winSize.width * (i/10) , winSize.height * row)];
            [sceneSpriteBatchNode addChild:theBlock];
            [theBlock release];
        }
        row -= 0.07;
    }
       
}


-(void) initPhysics
{
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	b2Vec2 gravity;
	gravity.Set(0.0f, 0.0f);
    
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
	b2Body* groundBody = world->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	b2EdgeShape groundBox;		
	
	// bottom
	
	groundBox.Set(b2Vec2(0,0), b2Vec2(s.width*LEVEL_WIDTH/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// top
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO*LEVEL_HEIGHT), b2Vec2(s.width*LEVEL_WIDTH/PTM_RATIO,s.height * LEVEL_HEIGHT/PTM_RATIO));
	groundBody->CreateFixture(&groundBox,0);
	
	// left
	groundBox.Set(b2Vec2(0,s.height * LEVEL_HEIGHT/PTM_RATIO), b2Vec2(0,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// right
	groundBox.Set(b2Vec2(s.width * LEVEL_WIDTH/PTM_RATIO,s.height * LEVEL_HEIGHT/PTM_RATIO), b2Vec2(s.width * LEVEL_WIDTH/ PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
    
}

-(void) update: (ccTime) dt
{
    static double UPDATE_INTERVAL = 1.0/60.0f;
    static double MAX_CYCLES_PER_FRAME = 4;
    static double timeAccumulator = 0;
    
    timeAccumulator += dt;
    
    if (timeAccumulator > (MAX_CYCLES_PER_FRAME * UPDATE_INTERVAL))
    {
        timeAccumulator = MAX_CYCLES_PER_FRAME * UPDATE_INTERVAL;
    }
    
    int32 velocityIterations = 15;
    int32 positionIterations = 15;
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
    CCArray *listOfObjectsToDestroy = [CCArray array];
    for (GameChar *tempChar in listOfGameObjects)
    {
        [tempChar updateStateWithDeltaTime:dt];
        //for each object, check if it's dead and store it to be cleaned up later
        if ([tempChar gameObjType] == kObjTypeBlock)
        {
            GameCharPhysics *object = (GameCharPhysics*) tempChar;
            if (object.destroyMe == true)
            {
                [listOfObjectsToDestroy addObject:object];
            }
        }
    }
    
    for (GameCharPhysics *tempChar in listOfObjectsToDestroy)
    {
        world->DestroyBody(tempChar.body);
        tempChar.body = NULL;
        [tempChar removeFromParentAndCleanup:YES];
    }

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
	
	kmGLPopMatrix();
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches){
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
        CGSize winSize = [CCDirector sharedDirector].winSize;
        if (leftTouch == nil && rightTouch == nil) {
            if (location.x < winSize.width/2) {
                leftTouch = touch;
                leftTouchPos = location;
            } else {
                rightTouch = touch;
                rightTouchPos = location;
            }
        } else if (leftTouch) {
            rightTouch = touch;
            rightTouchPos = location;
        } else if (rightTouch) {
            leftTouch = touch;
            leftTouchPos = location;
        }
    }
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches){
        if (touch == leftTouch) {
            leftTouch = nil;
            leftTouchPos = ccp(4 * PTM_RATIO, 2 * PTM_RATIO);
        } else if (touch == rightTouch) {
            rightTouch = nil;
            rightTouchPos = ccp(0, 0);
        }
    }
    
    //if the left touch has ended but the right touch is still there, set the left manually
    if ((rightTouch != nil) && (leftTouch == nil))
    {
        leftTouchPos.y = rightTouchPos.y;
        leftTouchPos.x = rightTouchPos.x - 2.0*PTM_RATIO;
    }
    else if ((leftTouch != nil) && (rightTouch == nil))
    {
        rightTouchPos.y = leftTouchPos.y;
        rightTouchPos.x = leftTouchPos.x + 2.0*PTM_RATIO;
    }
    else if ((leftTouch == nil) && (rightTouch == nil))
    {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        leftTouchPos = ccp(winSize.width/2.0 - 2.0*PTM_RATIO, winSize.height/2.0);
        rightTouchPos = ccp(winSize.width/2.0 + 2.0*PTM_RATIO, winSize.height/2.0);
    }
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches){
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
        //CGSize winSize = [CCDirector sharedDirector].winSize;
        if (leftTouch && rightTouch) {
            if (touch == leftTouch) {
                leftTouchPos = location;
            } else if (touch == rightTouch) {
                rightTouchPos = location;
            }
        }
    }
}

@end
