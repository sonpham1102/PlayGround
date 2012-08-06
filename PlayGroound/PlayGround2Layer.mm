//
//  PlayGround2Layer.mm
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayGround2Scene.h"
#import "PlayGround2Layer.h"
// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#import "PhysicsSprite.h"
#import "GameManager.h"
#import "Rocket.h"
#import "GlobalConstants.h"
#import "Obstacle.h"
#import "Asteroid.h"

#define PTM_RATIO (IS_IPAD() ? (32.0*1024.0/480.0) : 32.0)

#define LEVEL_HEIGHT 25 //25
#define LEVEL_WIDTH 10 //10
#define MAX_VELOCITY 5
//#define FRICTION_COEFF 0.08

#define ASTEROID_TIMER 0.5
#define ASTEROID_LIMIT 100

// used in FollowRocket2
#define CAMERA_VELOCITY_FACTOR 0.6

// AP: clean this shit up once I get a smooth camera follow
#define CAMERA_CORRECTION_FACTOR 0.1 // affects the speed at which the camera will try to follow the rocket
#define CAMERA_MIN_DELTA 0.5
#define CAMERA_CATCHUP_TIME 1.0 //1 second
#define MAX_CAMERA_SPEED 1.0 //(in M/s)

#define BULLET_TIME 0.5
#define TOTAL_BULLETS 10000

#define USE_MAX_VELOCITY 0
//#define NO_TEST 0

enum {
	kTagParentNode = 1,
};


#pragma mark - HelloWorldLayer

@interface PlayGround2Layer()
-(void) initPhysics;
@end

@implementation PlayGround2Layer

@synthesize motionManager;
@synthesize debugLabel;



-(void) onEnter{
    [super onEnter];
    self.isTouchEnabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFlipScreen:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

-(void) onExit{
    [super onExit];
    self.isTouchEnabled = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

-(void)decrementBulletCount{
    bulletCount --;
}

-(id) init
{
	if( (self=[super init])) {
		
        touchRight = nil;
        touchLeft = nil;
        touchMiddle = nil;
        
        leftRocketSoundID = 0;
        rightRocketSoundID = 0;
        middleRocketSoundID = 0;
        asteroidTimer = 0.0;
        asteroidsCreated = 0;
        bulletTime = 0.0;
        bulletCount = 0;
        loopCount = 0;
        
		// enable events
        
        //Setup Motion Manager
        self.motionManager = [[[CMMotionManager alloc] init] autorelease];
        motionManager.deviceMotionUpdateInterval = 1.0/60.0;
        if (motionManager.isDeviceMotionAvailable) {
            [motionManager startDeviceMotionUpdates];
            
            
            //[motionManager startGyroUpdates];
        }
        
        referenceAttitude = nil;
        
        cameraTarget = CGPointZero;
        
		// Handle this onEnter and onExit
        self.isTouchEnabled = NO;
        
		self.isAccelerometerEnabled = YES;
		CGSize s = [CCDirector sharedDirector].winSize;
		
		// init physics
        
		[self initPhysics];
		[self createBackground];
        [self createObstacle];
        //[self initAsteroids];
		//Set up sprite
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Playground2Atlas.plist"];
        sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"Playground2Atlas.png" capacity:110];
        [self addChild:sceneSpriteBatchNode z:0];

        rocket = [[Rocket alloc] initWithWorld:world atLocation:ccp(s.width * 1.5 /2 + 70.0, s.height*0.16)];
        [sceneSpriteBatchNode addChild:rocket];
        [rocket release];
        //rocket = [[Rocket alloc] initWithWorld:world atLocation:ccp(s.width * LEVEL_WIDTH/2, s.height*LEVEL_HEIGHT/2)];
        [rocket setTurnDirection:1];
        [rocket setDelegate:self];
		/*
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"This is Level 2" fontName:@"Marker Felt" fontSize:32];
		[self addChild:label z:0];
		[label setColor:ccc3(0,0,255)];
		label.position = ccp( s.width/2, s.height-50);
        */
        /*
        debugLabel = [CCLabelTTF labelWithString:@"test" fontName:@"Marker Felt" fontSize:12];
        [self addChild:debugLabel z:100];
        [debugLabel setColor:ccc3(0, 0, 255)];
        debugLabel.position = ccp(s.width*0.8, s.height/2);
        */
        //[self addChild:rocket z:100];

		[self scheduleUpdate];
	}
	return self;
}

-(void) createBackground {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    tileMapNode = [CCTMXTiledMap
                tiledMapWithTMXFile:@"SpaceBackground.tmx"];
    
    /*
    CCTMXLayer *backDropLayer = [tileMapNode layerNamed:@"BackDrop"];
    CCTMXLayer *planetsLayer = [tileMapNode
                                    layerNamed:@"Planets"];
    
    parallaxNode = [CCParallaxNode node];
    [parallaxNode setPosition:
     ccp(winSize.width*LEVEL_WIDTH/2,winSize.height*LEVEL_HEIGHT/2)];
    
    float xOffset = 0.0f;
    float yOffset = 0.0f;

    [backDropLayer retain];
    [backDropLayer removeFromParentAndCleanup:NO];
    [backDropLayer setAnchorPoint:CGPointMake(0.5f, 0.5f)];
    [parallaxNode addChild:backDropLayer z:15 parallaxRatio:ccp(1,1)
            positionOffset:ccp(0,0)];
    [backDropLayer release];
    
    xOffset = (winSize.width*LEVEL_WIDTH/2) * 0.005f;
    yOffset = (winSize.height*LEVEL_HEIGHT/2) * 0.005f;
    [planetsLayer retain];
    [planetsLayer removeFromParentAndCleanup:NO];
    [planetsLayer setAnchorPoint:CGPointMake(0.5f, 0.5f)];
    [parallaxNode addChild:planetsLayer z:20
             parallaxRatio:ccp(0.95,0.95)
            positionOffset:ccp(xOffset, yOffset)];
    [planetsLayer release];  
    */
    
    CCTMXLayer *backDropLayer = [tileMapNode layerNamed:@"BackDrop"];
    CCTMXLayer *planetsLayer = [tileMapNode
                                layerNamed:@"Planets"];
    
    parallaxNode = [CCParallaxNode node];
    [parallaxNode setPosition:
     ccp(winSize.width*LEVEL_WIDTH/2,winSize.height*LEVEL_HEIGHT/2)];
    
    float xOffset = 0.0f;
    float yOffset = 0.0f;
    
    [backDropLayer retain];
    [backDropLayer removeFromParentAndCleanup:NO];
    [backDropLayer setAnchorPoint:CGPointMake(0.5f, 0.5f)];
    [parallaxNode addChild:backDropLayer z:15 parallaxRatio:ccp(0.3,0.3)
            positionOffset:ccp(xOffset,yOffset)];
    [backDropLayer release];
    
    [planetsLayer retain];
    [planetsLayer removeFromParentAndCleanup:NO];
    [planetsLayer setAnchorPoint:CGPointMake(0.5f, 0.5f)];
    [parallaxNode addChild:planetsLayer z:20
             parallaxRatio:ccp(1,1)
            positionOffset:ccp(xOffset, yOffset)];
    [planetsLayer release]; 
     
     
    [self addChild:parallaxNode z:-1]; 
}

-(void) dealloc
{
	delete world;
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
	
	[super dealloc];
}

-(void) initAsteroids {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
     
     for (int i = 0; i < 25; i++)
     {
         Asteroid *sprite = [[Asteroid alloc] initWithWorld:world atLoaction:ccp(winSize.width * 0.5 + (5*i), winSize.height * 0.5)];
         sprite.position = ccp(winSize.width/2,winSize.height/2);
         [sceneSpriteBatchNode addChild:sprite];
         [sprite release];
     }
     
}

-(void)createObstacle {
    //Spikes * spikes;
    CGSize winSize = [CCDirector sharedDirector].winSize;
    Obstacle * obstacle;
    obstacle = [[[Obstacle alloc] initWithWorld:world atLoaction:ccp(winSize.width * 0.75, winSize.height * 0.12)] autorelease];
    [self addChild:obstacle];
}

-(void) initPhysics
{
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	b2Vec2 gravity;
	gravity.Set(0.0f, 0.0f);
//	gravity.Set(0.0f, 0.0f);
    
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
/*
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
*/
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
/*            b2Vec2 velocity = b->GetLinearVelocity();
#if USE_MAX_VELOCITY            
            if (velocity.LengthSquared() > MAX_VELOCITY*MAX_VELOCITY)
            {
                float velocityScale = MAX_VELOCITY/velocity.Length();
                
                b2Vec2 newVelocity = b2Vec2(velocity.x * velocityScale, velocity.y *velocityScale);
                b->SetLinearVelocity(newVelocity);

            }
#else use drag
            b2Vec2 force = velocity;
            force.Normalize();
            force=-force;
            force*=velocity.LengthSquared()*FRICTION_COEFF;
            b->ApplyForceToCenter(force);
#endif*/
        }
    }
    
    CCArray *listOfGameObjects = [sceneSpriteBatchNode children];
    for (GameCharPhysics *tempChar in listOfGameObjects) {
        [tempChar updateStateWithDeltaTime:dt];
    }
    loopCount ++;
    
    [self fireAsteroid:dt];
    
    CMDeviceMotion *currentDeviceMotion = motionManager.deviceMotion;
    
    if (referenceAttitude == nil) {
        //CMDeviceMotion *deviceMotion = motionManager.deviceMotion;
        CMAttitude *attitude = currentDeviceMotion.attitude;
        referenceAttitude = [attitude retain];        
    }
    
    // Device Motion Updates
    //CMDeviceMotion *currentDeviceMotion = motionManager.deviceMotion;
    CMAttitude *currentAttitude = currentDeviceMotion.attitude;
    
    [currentAttitude multiplyByInverseOfAttitude:referenceAttitude];
    
    float pitch = currentAttitude.pitch;
    
    [rocket setPitchTurn:pitch];
    //[rocket updateStateWithDeltaTime:dt];
	[self followRocket2:dt];
//	[self followRocket:dt];
   // if (bulletfired) {
   //     [bulletfired updateStateWithDeltaTime:dt];
   // }
    /*
    float roll = currentAttitude.roll;
    float yaw = currentAttitude.yaw;
    //float turnPower = pitch * TURN_SPEED * turn;
    
    //rocket.body->ApplyTorque(rocket.body->GetMass()*pitch * TURN_SPEED * turn);
    //rocket.body->SetAngularVelocity(turnPower);

    NSString *labelString = 
    [NSString stringWithFormat:@"Roll:%.4f \n Pitch:%.4f \n Yaw:%.4f \n Turn:%.4f",roll,pitch,yaw,turnPower];
    [debugLabel setString:labelString];
 */
    
}

-(void) createBullet:(ccTime)deltaTime {
    //CCLOG(@"Fire Bullet");
    
    /* Old Bullet Fire Method
    if (bulletfired == nil) {
        bulletfired = [[bullet alloc]  initWithWorld:world atLoaction:rocket.position];
        [self addChild:bulletfired];
        
        b2Vec2 bodyCenter = rocket.body->GetWorldCenter();
        b2Vec2 impulse = b2Vec2(0,800);
        b2Vec2 impulseWorld = rocket.body->GetWorldVector(impulse);
        b2Vec2 impulsePoint = rocket.body->GetWorldPoint(b2Vec2(0,40));
        bulletfired.body->ApplyForce(impulseWorld, impulsePoint);
        
    } else {
        bulletTime += deltaTime;
        if (bulletTime > BULLET_TIME) {
            [bulletfired removeFromParentAndCleanup:YES];
            world->DestroyBody(bulletfired.body);
            bulletTime = 0.0;
            bulletfired = nil;
        }
    }*/
    
    if ((bulletTime >= BULLET_TIME) || (bulletCount == 0)){
        if (bulletCount <= TOTAL_BULLETS) {
            bullet *bulletShot = [[bullet alloc] initWithWorld:world atLoaction:rocket.position];
            [sceneSpriteBatchNode addChild:bulletShot];
            b2Vec2 bodyCenter = rocket.body->GetWorldCenter();
            b2Vec2 linVelo = rocket.body->GetLinearVelocity();
            float32 bulletPower;
            if (linVelo.x < 0) {
                bulletPower += -linVelo.x; 
            } else {
                bulletPower += linVelo.x;
            }
            if (linVelo.y < 0) {
                bulletPower += -linVelo.y;
            } else {
                bulletPower += linVelo.y;
            }
            bulletPower *= 200;
            bulletPower = MAX(1000, bulletPower);
            bulletPower = MIN(1700, bulletPower);
            b2Vec2 impulse = b2Vec2(0,bulletPower);
            b2Vec2 impulseWorld = rocket.body->GetWorldVector(impulse);
            b2Vec2 impulsePoint = rocket.body->GetWorldPoint(b2Vec2(0,40));
            bulletShot.body->ApplyForce(impulseWorld, impulsePoint);
            //[bulletShot setDelegate:self];
            bulletCount ++;
            [bulletShot release];
        }
        bulletTime = 0.0;
    }
    bulletTime += deltaTime;
}

- (void) didFlipScreen:(NSNotification *)notification{ 
    [rocket setTurnDirection:[rocket turnDirection]];
} 


-(void) fireAsteroid:(ccTime)dt {
    asteroidTimer += dt;
    if ((asteroidTimer < ASTEROID_TIMER) || (asteroidsCreated >= ASTEROID_LIMIT)) {
        return;
    } else {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        float32 xLaunchPoint;
        float32 yLaunchPoint;
    
        xLaunchPoint = arc4random()%2;
        if (xLaunchPoint == 1) {
            xLaunchPoint -=0.01;
        }
        yLaunchPoint = arc4random()%10;
        yLaunchPoint /= 10;
        
        Asteroid *sprite = [[Asteroid alloc] initWithWorld:world atLoaction:ccp(winSize.width * LEVEL_WIDTH * xLaunchPoint, winSize.height * LEVEL_HEIGHT * yLaunchPoint)];
        [sceneSpriteBatchNode addChild:sprite];
        [sprite release];
        asteroidTimer = 0.0;
        asteroidsCreated += 1;
    }
}

-(void) moveCameraToTarget:(CGPoint) newTarget withDeltaTime:(float) dt;
{
//    [self setPosition:newTarget];

/*
    cameraTarget = ccp(newX, newY);
    
    CGPoint currentPos = [self position];
    
    CGPoint travelVector = ccp(cameraTarget.x - currentPos.x, cameraTarget.y - currentPos.y);
    
    //calculate a new position based on the distance between
    CGPoint newPos;
    
    // calculate the total distance in meters
    float totalDistance = sqrt(travelVector.x*travelVector.x + travelVector.y*travelVector.y) /PTM_RATIO;
    float distanceToMove = totalDistance*CAMERA_CORRECTION_FACTOR;
    
    //if distance to move is greater than the total distance, set the camera to the target point
    if (distanceToMove >totalDistance)
    {
        distanceToMove = totalDistance;
    }
    else if (distanceToMove < CAMERA_MIN_DELTA)
    {
        distanceToMove = 0.0f;
    }
    
    if (totalDistance > 0)
    {
        newPos.x = currentPos.x + travelVector.x * distanceToMove/totalDistance;
        newPos.y = currentPos.y + travelVector.y * distanceToMove/totalDistance;        
    }
    else
    {
        newPos = currentPos;
    }
*/    
    /*    
     //if the distance to travel is zero or below a minimum, we're done
     if ((totalDistance == 0.0f) || (totalDistance < CAMERA_MIN_DELTA) || (distanceToMove >= totalDistance))
     {
     newPos.x =cameraTarget.x;
     newPos.y =cameraTarget.y;
     }
     else
     {
     newPos.x = currentPos.x + travelVector.x * distanceToMove/totalDistance;
     newPos.y = currentPos.y + travelVector.y * distanceToMove/totalDistance;
     }
     */    

    
    
    
    
    
    
    
    
    
    
    CGPoint currentPos = [self position];
    
    // if the new target is far enough from the old target, reset follow parameters
    if ((ABS(cameraTarget.x - newTarget.x)/PTM_RATIO > CAMERA_MIN_DELTA) || (ABS(cameraTarget.y - newTarget.y)/PTM_RATIO > CAMERA_MIN_DELTA))
    {
        cameraTarget = newTarget;
        //figure out the distance in meters from the current position to the new target
        
        cameraMoveVector = b2Vec2((cameraTarget.x - currentPos.x)/PTM_RATIO, (cameraTarget.y - currentPos.y)/PTM_RATIO);
        
        cameraDistanceToTarget = cameraMoveVector.Normalize();
        cameraDistanceTravelled = 0.0f;
    }

    //we want the camera to reach it's target within CAMERA_CATCHUP_TIME
    //accumulatedDT+=dt;
    float cameraSpeed = cameraDistanceToTarget/CAMERA_CATCHUP_TIME;
    
    float distanceToMove = cameraSpeed * dt;
    
    //figure out how far we've gone already
    float distanceToTarget = cameraDistanceToTarget - cameraDistanceTravelled;
    
    if (cameraDistanceTravelled >= cameraDistanceToTarget)
    {
        distanceToMove = 0.0f;
        cameraDistanceToTarget = 0.0f;
    }
    else if (distanceToMove > distanceToTarget)
    {
        distanceToMove = distanceToTarget;
        cameraDistanceToTarget = 0.0f;
    }
    else if (distanceToMove < CAMERA_MIN_DELTA)
    {
        distanceToMove = 0;
        cameraDistanceToTarget = 0.0f;
    }
    
    //convert distance to move back to points
    distanceToMove *= PTM_RATIO;  
    
    //add the distance we are moving to the distancetravelled
    cameraDistanceTravelled += distanceToMove;
    
    CGPoint newCameraPosition = ccp(currentPos.x + cameraMoveVector.x * distanceToMove, currentPos.y + cameraMoveVector.y * distanceToMove);
    
    [self setPosition:newCameraPosition];

}

-(void)followRocket:(float) dt {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;


    b2Vec2 cTarget = rocket.body->GetWorldPoint(b2Vec2(0, 3.5));
                                            
    
    float fixtedPositionY = winSize.height/2;
    float fixtedPositionX = winSize.width/2;
    float newY = fixtedPositionY - cTarget.y * PTM_RATIO;
    float newX = fixtedPositionX - cTarget.x * PTM_RATIO;
    
    newX = MIN(newX,0);
    newX = MAX(newX,-winSize.width * (LEVEL_WIDTH - 1));
    newY = MIN(newY,0);
    newY = MAX(newY,-winSize.height * (LEVEL_HEIGHT-1));
    
    CGPoint newPos = ccp(newX, newY);
    
    [self setPosition:newPos];
    //[self moveCameraToTarget:newPos withDeltaTime:dt];
/*
    NSString *labelString = 
    [NSString stringWithFormat:@"Total: %.2f\nMove: %.2f",totalDistance, distanceToMove];
    [debugLabel setString:labelString];
    [debugLabel setPosition:ccp(-newPos.x+100, -newPos.y+100)];
*/

}

-(void)followRocket2:(float) dt {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    
    b2Vec2 rocketVelocity = rocket.body->GetLinearVelocity();
    b2Vec2 rocketPosition = rocket.body->GetPosition();
    
    //we want the camera to be ahead of the rocket's movement
    float speed = rocketVelocity.Normalize() * PTM_RATIO;
    
    //rocketVelocity = rocket.body->GetLocalVector(b2Vec2(0,1.0));
    
    // the camera target location starts on the rocket (it would be bottom left)
    b2Vec2 cameraPosition;
    cameraPosition.x = rocketPosition.x * PTM_RATIO;
    cameraPosition.y = rocketPosition.y * PTM_RATIO;


    float velocityOffset = CAMERA_VELOCITY_FACTOR*speed;
    
    float theta = atanf(rocketVelocity.y/rocketVelocity.x);
    float a = winSize.width/2.0*0.9;
    float b = winSize.height/2.0*0.9;
    float maximumOffset = a*b/sqrt(b*cosf(theta)*b*cosf(theta) + a*sinf(theta)*a*sinf(theta));
    
    if (velocityOffset >= maximumOffset)
    {
        velocityOffset = maximumOffset;
    }
    rocketVelocity.x = rocketVelocity.x * velocityOffset;
    rocketVelocity.y = rocketVelocity.y * velocityOffset; 
    
    
    // add the velocity offset vector to the camera position
    cameraPosition = cameraPosition + rocketVelocity;
    
    // take 1/2 a screen off the camera location
    // (this would put the rocket center screen)
    cameraPosition.x = cameraPosition.x - winSize.width/2.0;
    cameraPosition.y = cameraPosition.y - winSize.height/2.0;
    
    //now make sure the camera doesn't go outside the level bounds
    float newX = -cameraPosition.x;
    float newY = -cameraPosition.y;

    newX = MIN(0, newX);
    newX = MAX(newX,-winSize.width * (LEVEL_WIDTH - 1));
    newY = MIN(newY,0);
    newY = MAX(newY,-winSize.height * (LEVEL_HEIGHT-1));
    
    CGPoint newPos = ccp(newX, newY);
        
    [self setPosition:newPos];
/*
    NSString *labelString = 
    [NSString stringWithFormat:@"newX: %.2f\nnewY: %.2f",newX, newY];
    [debugLabel setString:labelString];
    [debugLabel setPosition:ccp(-newPos.x+100, -newPos.y+100)];
*/    
    
}




-(void) fireLeft {
    [rocket fireLeftRocket];
}

-(void) fireRight {
    [rocket fireRightRocket];
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches){
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
/*#if NO_TEST
        if ((touchLeft == nil) && (touchRight == nil))
        {
            [self schedule:@selector(fireLeft)];
            touchLeft = touch;
            leftRocketSoundID = PLAYSOUNDEFFECTLOOPED(ROCKET_JET);
            [self schedule:@selector(fireRight)];
            touchRight = touch;
            rightRocketSoundID = PLAYSOUNDEFFECTLOOPED(ROCKET_JET);
        }
#else*/
        if (location.x < [CCDirector sharedDirector].winSize.width/3) {
            if (touchLeft == nil)
            {
                [self schedule:@selector(fireLeft)];
                touchLeft = touch;
                leftRocketSoundID = PLAYSOUNDEFFECTLOOPED(ROCKET_JET);
            }
        } else if (location.x > [CCDirector sharedDirector].winSize.width * 0.6) {
            if (touchRight == nil)
            {
                [self schedule:@selector(fireRight)];
                touchRight = touch;
                rightRocketSoundID = PLAYSOUNDEFFECTLOOPED(ROCKET_JET);
            }
        } else {
            if (touchMiddle == nil)
            {
                [self schedule:@selector(fireLeft)];
                [self schedule:@selector(fireRight)];
                touchMiddle = touch;
                middleRocketSoundID = PLAYSOUNDEFFECTLOOPED(ROCKET_JET);
            }
        }
//#endif
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {

/*#if NO_TEST
        if (touch == touchLeft)
        {
            [self unschedule:@selector(fireLeft)];
            [self unschedule:@selector(fireRight)];
            STOPSOUNDEFFECT(leftRocketSoundID);
            touchLeft = nil;
            touchRight = nil;
            STOPSOUNDEFFECT(rightRocketSoundID);            
        }
#else*/        
        if (touch == touchLeft) {
            [self unschedule:@selector(fireLeft)];
            touchLeft = nil;
            STOPSOUNDEFFECT(leftRocketSoundID);
        } else  if (touch == touchRight) {
            [self unschedule:@selector(fireRight)];
            touchRight = nil;
            STOPSOUNDEFFECT(rightRocketSoundID);
        } else if (touch == touchMiddle) {
            [self unschedule:@selector(fireLeft)];
            [self unschedule:@selector(fireRight)];
            //STOPSOUNDEFFECT(leftRocketSoundID);
            STOPSOUNDEFFECT(middleRocketSoundID);
            touchMiddle = nil;
        }
//#endif
    } 
}
-(void) ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{    
    [self ccTouchesEnded:touches withEvent:event];
}

/*
-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    
    int orientation = 1.0;
    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeLeft) {
        orientation = -1.0;
    }
    float32 velocity = acceleration.y * TURN_SPEED * orientation;
    rocket.body->SetAngularVelocity(velocity);
}
*/


#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}



@end
