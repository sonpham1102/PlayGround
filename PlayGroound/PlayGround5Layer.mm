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
#import "ShotGunBlast.h"
#import "GBVortex.h"

#define LP_START_MAX_DISTANCE 2.0
//#define MAX_BULLET_SPEED 50.0
//#define MIN_BULLET_SPEED 1.0
//#define MAX_PAN_LENGTH 20.0
#define MIN_PAN_LENGTH 1.0

#define BULLET_SPEED 35.0

#define ENEMY_STARTING_WAVE_SIZE 8
#define ENEMY_STARTING_SPAWN_RATE 2.5
#define ENEMY_INCREASE_PER_WAVE 2
#define ENEMY_SPAWN_RATE_FACTOR 0.9
#define ENEMY_WAVE_TARGET_TIME 10.0
#define ENEMY_MAX_PER_SUBWAVE 8
#define ENEMY_MIN_PER_SUBWAVE 4
#define GB_ROTATION_ANGLE_TRIGGER 10.0*M_PI/180.0
#define GB_LAUNCH_IMPULSE 40.0

#define SGB_COOLDOWN 2.0
#define SPIN_COOLDOWN 10.0

#define GB_PAN_MOVE_OFFSET 3.0

#define MAX_PAN_POINTS 180
#define MIN_PAN_MOVE_DELTA 2.0

#define GB_PAN_MOVE_FORCE 100.0

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
    [sceneSpriteBatchNode addChild:gunBot z:5];
}

-(BOOL) displayText:(NSString *)text andOnCompleteCallTarget:(id)target selector:(SEL)selector
{
    [label stopAllActions];
    [label setString:text];
    label.visible = YES;
    label.scale = 0.0;
    label.opacity = 255;
    
    CCScaleTo *scaleUp = [CCScaleTo actionWithDuration:0.5 scale:1.2];
    CCScaleTo *scaleBack = [CCScaleTo actionWithDuration:0.1 scale:1.0];
    CCDelayTime *delay = [CCDelayTime actionWithDuration:2.0];
    CCFadeOut *fade = [CCFadeOut actionWithDuration:0.5];
    CCHide *hide = [CCHide action];
    CCCallFuncN *onComplete = [CCCallFuncN actionWithTarget:target selector:selector];
    CCSequence *sequence = [CCSequence actions:scaleUp, scaleBack, delay, fade, hide, onComplete, nil];
    [label runAction:sequence];
    return TRUE;
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
      
        [self createGunBot:ccp(s.width/2.0/PTM_RATIO, s.height/2.0/PTM_RATIO)];
        
        [self createBackground];
		
		[self scheduleUpdate];
        
        //init variables
        lpStarted = false;
        currentWaveNumber = 0;
        isCreatingWave = false;
        gameOver = false;
        elapsedTime = 0.0;
        lastSBTime = 0.0;
        lastSpinTime = 0.0;
        isVortexPlaced = false;
        
        panStartPoint = CGPointZero;
        panEndPoint = CGPointZero;
        
        isPlanningMove = false;
        
        panPoints = [[NSMutableArray alloc]init];
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        label = [CCLabelTTF labelWithString:@"" fontName:@"Helvetica" fontSize:48.0];
        label.position = ccp(winSize.width/2, winSize.height/2);
        label.visible = NO;
        [self addChild:label];
	}
	return self;
}

-(void) dealloc
{
	delete world;
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
    
    [panPoints release];
    
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
	
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &groundBox;
    fixtureDef.filter.categoryBits = kCollCatWall;
    fixtureDef.filter.maskBits = kCollMaskWall;
	// bottom
	
	groundBox.Set(b2Vec2(0,0), b2Vec2(s.width/PTM_RATIO,0));
	//groundBody->CreateFixture(&groundBox,0);
    groundBody->CreateFixture(&fixtureDef);
	
	// top
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO));
	//groundBody->CreateFixture(&groundBox,0);
    groundBody->CreateFixture(&fixtureDef);
	
	// left
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(0,0));
	//groundBody->CreateFixture(&groundBox,0);
    groundBody->CreateFixture(&fixtureDef);
	
	// right
	groundBox.Set(b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,0));
	//groundBody->CreateFixture(&groundBox,0);
    groundBody->CreateFixture(&fixtureDef);
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

-(void) handlePanStart:(CGPoint)startPoint
{
    // see if the start point is on the gunbot
    b2Vec2 panPoint = b2Vec2(startPoint.x/PTM_RATIO, startPoint.y/PTM_RATIO);
                             
    b2Vec2 distanceVector = gunBot.body->GetPosition() - panPoint;
    
    float distance = distanceVector.Length();
    
    if (distance < GB_PAN_MOVE_OFFSET)
    {
        PLAYSOUNDEFFECT(LP_DETECTED);
        isPlanningMove = true;
        if ([panPoints count] != 0)
        {
            [panPoints removeAllObjects];
        }
        [panPoints addObject:[NSValue valueWithCGPoint:startPoint]];
    }
    else
    {
        isPlanningMove = false;
        panStartPoint = startPoint;
    }
}

-(void) handlePanMove:(CGPoint)newPoint
{
    if (isPlanningMove)
    {
        if ([panPoints count] < MAX_PAN_POINTS)
        {
            [panPoints addObject:[NSValue valueWithCGPoint:newPoint]];

            if ([panPoints count] == MAX_PAN_POINTS)
            {
                PLAYSOUNDEFFECT(LP_DETECTED);
            }
        }
    }
}

-(void) handlePanEnd:(CGPoint)endPoint
{
    panEndPoint = endPoint;
    
    if (gameOver) {
        return;
    }
    
    if (isPlanningMove)
    {
        if ([panPoints count] < MAX_PAN_POINTS)
        {
            [panPoints addObject:[NSValue valueWithCGPoint:endPoint]];
            PLAYSOUNDEFFECT(LP_DETECTED);
        }
        isPlanningMove = false;
        currentPanTargetIndex = 0;
        return;
    }
    
    //the start and end are in screen space, get the vector between them and convert to screen space
    b2Vec2 launchVector = b2Vec2((panEndPoint.x - panStartPoint.x)/PTM_RATIO, (panEndPoint.y - panStartPoint.y)/PTM_RATIO);
    
    //if the gunbot is spinning, launch him
    if ([gunBot characterState] == kStateManeuver)
    {
        b2Vec2 impulseVector = launchVector;
        impulseVector.Normalize();
        impulseVector.x *= GB_LAUNCH_IMPULSE*gunBot.body->GetMass();
        impulseVector.y *= GB_LAUNCH_IMPULSE*gunBot.body->GetMass();
        gunBot.body->ApplyLinearImpulse(impulseVector, gunBot.body->GetPosition());
        return;
    }
    
    //create a bullet and launch it in along the pan vector 
    
    b2Vec2 velocityVector;
    
    float panLengthInMeters = launchVector.Normalize();
    // make sure the pan is long enough to be worth processing
    if (panLengthInMeters < MIN_PAN_LENGTH)
    {
        return;
    }
    // do a fixed velocity 
    float speed = BULLET_SPEED;
    velocityVector.x = launchVector.x * speed;
    velocityVector.y = launchVector.y * speed;
    
    //make a new bullet
    GBBullet* bullet = [[GBBullet alloc] initWithWorld:world atLocation:gunBot.body->GetPosition() withVelocity:velocityVector];
    [sceneSpriteBatchNode addChild:bullet];
    
    [bullet release];
}


-(void) handlePan:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    if (gameOver) {
        return;
    }

    //the start and end are in screen space, get the vector between them and convert to screen space
    b2Vec2 launchVector = b2Vec2((endPoint.x - startPoint.x)/PTM_RATIO, (endPoint.y - startPoint.y)/PTM_RATIO);
        
    //if the gunbot is spinning, launch him
    if ([gunBot characterState] == kStateManeuver)
    {
        b2Vec2 impulseVector = launchVector;
        impulseVector.Normalize();
        impulseVector.x *= GB_LAUNCH_IMPULSE*gunBot.body->GetMass();
        impulseVector.y *= GB_LAUNCH_IMPULSE*gunBot.body->GetMass();
        gunBot.body->ApplyLinearImpulse(impulseVector, gunBot.body->GetPosition());
        return;
    }
    
    //create a bullet and launch it in along the pan vector 
        
    b2Vec2 velocityVector;
    
    float panLengthInMeters = launchVector.Normalize();
    // make sure the pan is long enough to be worth processing
    if (panLengthInMeters < MIN_PAN_LENGTH)
    {
        return;
    }
    /*
     if (panLengthInMeters > MAX_PAN_LENGTH)
     {
     panLengthInMeters = MAX_PAN_LENGTH;
     }
     // get the speed between min and max depending on pan length
     float speed = MIN_BULLET_SPEED + (MAX_BULLET_SPEED - MIN_BULLET_SPEED)*panLengthInMeters/MAX_PAN_LENGTH;
     */  
    // do a fixed velocity instead
    float speed = BULLET_SPEED;
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
    //if the angle is big enough, put the gunbot into rotation mode
    if (ABS(angleDelta) > GB_ROTATION_ANGLE_TRIGGER)
    {
        //make sure enough time has passed between shots
        if (((elapsedTime - lastSpinTime) < SPIN_COOLDOWN) && (lastSpinTime != 0.0))
        {
            PLAYSOUNDEFFECT(SHOTGUN_RELOADING);
            return;
        }

        [gunBot setSpinDirection:angleDelta];
        [gunBot changeState:kStateManeuver];
        lastSpinTime = elapsedTime;
    }
}

-(void) handleLongPressStart:(CGPoint)point
{
    if (gameOver) {
        return;
    }
    
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
    else if (isVortexPlaced == false)       
    {
        //place a vortex at that location
        GBVortex* vortex = [[GBVortex alloc] initWithWorld:world atLocation:touchInWorld];
        [sceneSpriteBatchNode addChild:vortex];
        
        [vortex release]; 
        
        isVortexPlaced = true;
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

-(void) handleTwoTouchPan:(CGPoint)centroid withVelocity:(CGPoint)velocity
{
    if (gameOver) {
        return;
    }

    //make sure enough time has passed between shots
    if (((elapsedTime - lastSBTime) < SGB_COOLDOWN) && (lastSBTime != 0.0))
    {
        PLAYSOUNDEFFECT(SHOTGUN_RELOADING);
        return;
    }
    
    b2Vec2 velocityVector = b2Vec2(velocity.x, velocity.y);
    velocityVector.Normalize();
    
    float speed = BULLET_SPEED;
    velocityVector.x *= speed;
    velocityVector.y *= speed;
    
    //make a new bullet
    ShotGunBlast* bullet = [[ShotGunBlast alloc] initWithWorld:world atLocation:gunBot.body->GetPosition() withVelocity:velocityVector];
    [sceneSpriteBatchNode addChild:bullet];
    
    lastSBTime = elapsedTime;
    
    [bullet release];    
}

-(void) playRandomAnnouncerSound
{
    int soundNumber = arc4random() % 6;
    
    switch (soundNumber) {
        case 0:
            PLAYSOUNDEFFECT(ANNOUNCER_V1);
            break;
        case 1:
            PLAYSOUNDEFFECT(ANNOUNCER_V2);
            break;
        case 2:
            PLAYSOUNDEFFECT(ANNOUNCER_V3);
            break;
        case 3:
            PLAYSOUNDEFFECT(ANNOUNCER_V4);
            break;
        case 4:
            PLAYSOUNDEFFECT(ANNOUNCER_V5);
            break;
        case 5:
            PLAYSOUNDEFFECT(ANNOUNCER_V6);
            break;
            
        default:
            break;
    }
}

-(void) spawnEnemy:(id) sender
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
    
    isCreatingWave = false;
}

-(void) beginSpawning:(id) sender
{
    isReadyToSpawn = true;
    
    leftGateTimer = 0.0;
    leftGateCount = 0;
    leftGateTarget = 0;
    rightGateTimer = 0.0;
    rightGateCount = 0;
    rightGateTarget = 0;
    topGateTimer = 0.0;
    topGateCount = 0;
    topGateTarget = 0;
    bottomGateTimer = 0.0;
    bottomGateCount = 0;
    bottomGateTarget = 0;
    
    enemiesAllocated = 0;
    
    //set up the wave depending on which one it is
    if (currentWaveNumber == 1)
    {
        enemySpawnTarget = ENEMY_STARTING_WAVE_SIZE;
        timePerEnemy = ENEMY_STARTING_SPAWN_RATE;
    }
    else
    {
        enemySpawnTarget += ENEMY_INCREASE_PER_WAVE;
        timePerEnemy *= ENEMY_SPAWN_RATE_FACTOR;
    }
    
}

-(void) createEnemyAtLocation:(b2Vec2) location
{
    GBEnemy* enemy = [[GBEnemy alloc] initWithWorld:world atLocation:location withTargetBody:gunBot.body];
    [sceneSpriteBatchNode addChild:enemy];
    [enemy release];
}

-(void) spawnEnemies:(float) dt
{
    if (gameOver || !isReadyToSpawn)
    {
        return;
    }
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    bool emptyGate = false;
    bool isFinished = true;
    
    //check each door and continue it's subwave
    if (leftGateCount < leftGateTarget)
    {
        leftGateTimer += dt;
        if (leftGateTimer > timePerEnemy)
        {
            [self createEnemyAtLocation:b2Vec2(-10.0/PTM_RATIO, winSize.height/2.0/PTM_RATIO)];
            leftGateCount++;
            leftGateTimer = 0.0f;
        }
        isFinished = false;
    }
    else 
    {
        leftGateTarget = 0;
        emptyGate = true;
    }
    if (rightGateCount < rightGateTarget)
    {
        rightGateTimer += dt;
        if (rightGateTimer > timePerEnemy)
        {
            [self createEnemyAtLocation:b2Vec2((winSize.width+10.0)/PTM_RATIO, winSize.height/2.0/PTM_RATIO)];
            rightGateCount++;
            rightGateTimer = 0.0f;
        }
        isFinished = false;
    }
    else 
    {
        rightGateTarget = 0;
        emptyGate = true;
    }
    if (topGateCount < topGateTarget)
    {
        topGateTimer += dt;
        if (topGateTimer > timePerEnemy)
        {
            [self createEnemyAtLocation:b2Vec2(winSize.width/2.0/PTM_RATIO, (winSize.height+10.0)/PTM_RATIO)];
            topGateCount++;
            topGateTimer = 0.0f;
        }
        isFinished = false;
    }
    else 
    {
        topGateTarget = 0;
        emptyGate = true;
    }
    if (bottomGateCount < bottomGateTarget)
    {
        bottomGateTimer += dt;
        if (bottomGateTimer > timePerEnemy)
        {
            [self createEnemyAtLocation:b2Vec2(winSize.width/2.0/PTM_RATIO, -10)];
            bottomGateCount++;
            bottomGateTimer = 0.0f;
        }
        isFinished = false;
    }
    else 
    {
        bottomGateTarget = 0;
        emptyGate = true;
    }
    
    //see if we have any left to allocate to a gate, assuming we have an empty gate to allocate them to
    if ((enemiesAllocated < enemySpawnTarget) && emptyGate)
    {
        // randomly select a number to allocate
        float randomNum = (float)arc4random()/(float)0x100000000;
        int enemiesForSubWave = ENEMY_MIN_PER_SUBWAVE + (ENEMY_MAX_PER_SUBWAVE - ENEMY_MIN_PER_SUBWAVE)*randomNum;
        int remainingEnemies = enemySpawnTarget - enemiesAllocated;
        if (remainingEnemies < enemiesForSubWave)
        {
            enemiesForSubWave = remainingEnemies;
        }
        
        // figure out a random delay before starting
        float randomDelay = (float)arc4random()/(float)0x100000000;
        randomDelay *= (ENEMY_MAX_PER_SUBWAVE - ENEMY_MIN_PER_SUBWAVE)/2.0 * timePerEnemy;
        
        //now randomly choose a gate for them
        int gateIndex = arc4random() % 4;
        switch (gateIndex) {
            case 0:
                if (leftGateTarget == 0)
                {
                    leftGateTarget = enemiesForSubWave;
                    enemiesAllocated+=enemiesForSubWave;
                    leftGateTimer = -randomDelay;
                    leftGateCount = 0;
                }
                break;
            case 1:
                if (rightGateTarget == 0)
                {
                    rightGateTarget = enemiesForSubWave;
                    enemiesAllocated+=enemiesForSubWave;
                    rightGateTimer = -randomDelay;
                    rightGateCount = 0;
                }
                break;
            case 2:
                if (topGateTarget == 0)
                {
                    topGateTarget = enemiesForSubWave;
                    enemiesAllocated+=enemiesForSubWave;
                    topGateTimer = -randomDelay;
                    topGateCount = 0;
                }
                break;
            case 3:
                if (bottomGateTarget == 0)
                {
                    bottomGateTarget = enemiesForSubWave;
                    enemiesAllocated+=enemiesForSubWave;
                    bottomGateTimer = -randomDelay;
                    bottomGateCount = 0;
                }
                break;
                
            default:
                CCLOG(@"ILLLLEEGAL");
                break;
        }
    }
    else if ((enemiesAllocated >= enemySpawnTarget) && isFinished)
    {
        isCreatingWave = false;
        isReadyToSpawn = false;
    }
}

-(void) startNewWave
{
    currentWaveNumber++;
    
    isCreatingWave = true;
    isReadyToSpawn = false;
    
    //set up the wave depending on which one it is
    if (currentWaveNumber == 1)
    {
        PLAYSOUNDEFFECT(ANNOUNCER_V1);
    }
    else
    {
        [self playRandomAnnouncerSound];
    }
    
    [self displayText:[NSString stringWithFormat:@"Wave %i", currentWaveNumber] andOnCompleteCallTarget:self selector:@selector(beginSpawning:)];
}

-(void) displayFinalResult:(id) sender
{
    [label setString:[NSString stringWithFormat:@"Waves Complete: %i", (currentWaveNumber - 1)]];
    label.visible = YES;
    label.scale = 1.0;
    label.opacity = 255;
}

-(void) update: (ccTime) dt
{
    elapsedTime += dt;
    
    static double UPDATE_INTERVAL = 1.0/60.0f;
    static double MAX_CYCLES_PER_FRAME = 5;
    static double timeAccumulator = 0;
    
    timeAccumulator += dt;
    
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
    int numberOfLivingEnemies = 0;
    isVortexPlaced = false;
    for (GameChar *tempChar in listOfGameObjects)
    {
        [tempChar updateStateWithDeltaTime:dt];
        //for each object, check if it's dead and store it to be cleaned up later
        if (([tempChar gameObjType] == kObjTypeEnemy) || 
            ([tempChar gameObjType] == kObjTypeBullet) ||
            ([tempChar gameObjType] == kObjTypeGravityWell))
        {
            GameCharPhysics *object = (GameCharPhysics*) tempChar;
            if (object.destroyMe == true)
            {
                [listOfObjectsToDestroy addObject:object];
            }
            if ([tempChar gameObjType] == kObjTypeEnemy)
            {
                numberOfLivingEnemies++;
            }
        }
        if ([tempChar gameObjType] == kObjTypeGravityWell)
        {
            isVortexPlaced = true;
        }
    }
    
    for (GameCharPhysics *tempChar in listOfObjectsToDestroy)
    {
        world->DestroyBody(tempChar.body);
        tempChar.body = NULL;
        [tempChar removeFromParentAndCleanup:YES];
    }
    
    // see if the player was killed
    if (gunBot.destroyMe && !gameOver)
    {
        gameOver = true;
        PLAYSOUNDEFFECT(ANNOUNCER_V6);
        [self displayText:@"Game Over!" andOnCompleteCallTarget:self selector:@selector(displayFinalResult:)];
    }
    else if (gameOver)
    {
        return;
    }
    
    // see if the gunbot has a pan move in progress
    if ( ([panPoints count] != 0) && !isPlanningMove)
    {
        b2Vec2 currentPosition = gunBot.body->GetPosition();
        b2Vec2 targetVector = currentPanTarget - currentPosition;
        
        //if this is the first time in here, set up the first target
        if (currentPanTargetIndex == 0)
        {
            CGPoint newTarget = [[panPoints objectAtIndex:currentPanTargetIndex] CGPointValue];
            currentPanTarget.x = newTarget.x/PTM_RATIO;
            currentPanTarget.y = newTarget.y/PTM_RATIO;
            currentPanTargetIndex++;
        }
        else if (targetVector.Normalize() > MIN_PAN_MOVE_DELTA)
        {
            //push the gunbot towards the target
            b2Vec2 forceVector;
            forceVector.x = targetVector.x * gunBot.body->GetMass() * GB_PAN_MOVE_FORCE;
            forceVector.y = targetVector.y * gunBot.body->GetMass() * GB_PAN_MOVE_FORCE;
            gunBot.body->ApplyForce(forceVector, gunBot.body->GetWorldCenter());
        }
        else
        {
            //we are close enough, so change the target
            if (currentPanTargetIndex >= [panPoints count])
            {
                //we are finished the pan manouvre
                [panPoints removeAllObjects];
            }
            else
            {
                CGPoint newTarget = [[panPoints objectAtIndex:currentPanTargetIndex] CGPointValue];
                currentPanTarget.x = newTarget.x/PTM_RATIO;
                currentPanTarget.y = newTarget.y/PTM_RATIO;
                currentPanTargetIndex++;
            }
        }
    }
    
    
    // if we aren't generating a new wave, see if we should start
    if (!isCreatingWave)
    {
        if (numberOfLivingEnemies == 0)
        {
            [self startNewWave];
        }
    }
    else
    {
        [self spawnEnemies:dt];
    }
}

@end
