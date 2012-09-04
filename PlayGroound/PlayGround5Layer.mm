//
//  PlayGround5Layer.mm
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "PlayGround5Scene.h"
#import "PlayGround5Layer.h"
// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#import "PhysicsSprite.h"
#import "GameManager.h"
#import "GBBullet.h"
#import "GBEnemy.h"

#define LP_START_MAX_DISTANCE 2.0
#define MAX_BULLET_SPEED 50.0
#define MIN_BULLET_SPEED 1.0
#define MAX_PAN_LENGTH 20.0
#define MIN_PAN_LENGTH 1.0

#define ENEMY_SPAWN_TIME 2.0


enum {
	kTagParentNode = 1,
};


@interface PlayGround5Layer()
-(void) initPhysics;
@end

@implementation PlayGround5Layer

-(void) createBackground {
    
//    CGSize winSize = [CCDirector sharedDirector].winSize;
}

-(void) createGunBot: (CGPoint) location
{
    gunBot = [[GunBot alloc] initWithWorld:world atLocation:location];
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
        
        [self createGunBot:ccp(s.width/2.0/PTM_RATIO, s.height/2.0/PTM_RATIO)];
		        
        sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithTexture:nil];
        [self addChild:sceneSpriteBatchNode z:0];
                
        [self createBackground];
		
		[self scheduleUpdate];
        
        //init variables
        lpStarted = false;

        enemySpawnTimer = 0.0f;
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
	b2Body* groundBody = world->CreateBody(&groundBodyDef);
	
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
    //create a bullet and launch it in along the pan vector with a speed proportional to the length (with limits)
    
    //the start and end are in screen space, get the vector between them and convert to screen space
    b2Vec2 launchVector = b2Vec2((endPoint.x - startPoint.x)/PTM_RATIO, (endPoint.y - startPoint.y)/PTM_RATIO);
    
    b2Vec2 velocityVector;
    float panLengthInMeters = launchVector.Normalize();
    // make sure the pan is long enough to be worth processing
    if (panLengthInMeters < MIN_PAN_LENGTH)
    {
        return;
    }
    if (panLengthInMeters > MAX_PAN_LENGTH)
    {
        panLengthInMeters = MAX_PAN_LENGTH;
    }
    // get the speed between min and max depending on pan length
    float speed = MIN_BULLET_SPEED + (MAX_BULLET_SPEED - MIN_BULLET_SPEED)*panLengthInMeters/MAX_PAN_LENGTH;
    
    velocityVector.x = launchVector.x * speed;
    velocityVector.y = launchVector.y * speed;
    
    //make a new bullet
    GBBullet* bullet = [[GBBullet alloc] initWithWorld:world atLocation:gunBot.body->GetPosition() withVelocity:velocityVector];
    [sceneSpriteBatchNode addChild:bullet];

    [bullet release];
}

-(void) handleTap:(CGPoint)tapPoint
{

}

-(void) handleRotation:(float)angleDelta
{

}

-(void) handleLongPressStart:(CGPoint)point
{
    //check if the start point is close enough to the gunbot
    //first need to convert to physics space (meters)
    b2Vec2 touchInWorld = b2Vec2(point.x/PTM_RATIO, point.y/PTM_RATIO);
    
    //get the vector between this point and the center to the gunbot
    b2Vec2 seperationVector = touchInWorld - gunBot.body->GetPosition();

    if (seperationVector.Length() < LP_START_MAX_DISTANCE)
    {
        lpStarted = true;
        gunBot.body->SetTransform(touchInWorld, gunBot.body->GetAngle());
        PLAYSOUNDEFFECT(LP_DETECTED);
    }
}

-(void) handleLongPressMove:(CGPoint)point
{
    if (lpStarted)
    {
        b2Vec2 touchInWorld = b2Vec2(point.x/PTM_RATIO, point.y/PTM_RATIO);
        gunBot.body->SetTransform(touchInWorld, gunBot.body->GetAngle());       
    }
}

-(void) handleLongPressEnd:(CGPoint)point
{
    if (lpStarted)
    {
        b2Vec2 touchInWorld = b2Vec2(point.x/PTM_RATIO, point.y/PTM_RATIO);
        gunBot.body->SetTransform(touchInWorld, gunBot.body->GetAngle());       
    }
    lpStarted = false;
}

-(void) spawnEnemies
{
    //choose a random spot near the edge of the level
    b2Vec2 location;
    CGSize winSize = [CCDirector sharedDirector].winSize;
    float randomNum;
    
    randomNum = (float)arc4random()/(float)0x100000000;
    if (randomNum > 0.5)
    {
        randomNum = MIN(randomNum, 0.9);
        randomNum = MAX(randomNum, 0.6);        
    }
    else
    {
        randomNum = MIN(randomNum, 0.4);
        randomNum = MAX(randomNum, 0.1);        
    }
    location.x = winSize.width*randomNum/PTM_RATIO;
    randomNum = (float)arc4random()/(float)0x100000000;
    if (randomNum > 0.5)
    {
        randomNum = MIN(randomNum, 0.9);
        randomNum = MAX(randomNum, 0.6);        
    }
    else
    {
        randomNum = MIN(randomNum, 0.4);
        randomNum = MAX(randomNum, 0.1);        
    }
    location.y = winSize.height*randomNum/PTM_RATIO;
    

    GBEnemy* enemy = [[GBEnemy alloc] initWithWorld:world atLocation:location withTargetBody:gunBot.body];
    [sceneSpriteBatchNode addChild:enemy];
    [enemy release];
}

-(void) update: (ccTime) dt
{
    static double UPDATE_INTERVAL = 1.0/60.0f;
    static double MAX_CYCLES_PER_FRAME = 5;
    static double timeAccumulator = 0;
    
    timeAccumulator += dt;
    CCLOG(@"new update");
    
    if (timeAccumulator > (MAX_CYCLES_PER_FRAME * UPDATE_INTERVAL))
    {
        timeAccumulator = MAX_CYCLES_PER_FRAME * UPDATE_INTERVAL;
    }
    
    int32 velocityIterations = 5;
    int32 positionIterations = 5;
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
        if (([tempChar gameObjType] == kObjTypeEnemy) || ([tempChar gameObjType] == kObjTypeBullet))
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
    
    // see if its time to spawn new enemies
    enemySpawnTimer += dt;
    if (enemySpawnTimer > ENEMY_SPAWN_TIME)
    {
        enemySpawnTimer = 0.0;
        [self spawnEnemies];
    }
}

@end
