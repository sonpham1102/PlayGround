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

#define LEVEL_HEIGHT 5 //25
#define LEVEL_WIDTH 2 //10
#define MAX_VELOCITY 5
//#define FRICTION_COEFF 0.08

#define ASTEROID_TIMER 0.5
#define ASTEROID_LIMIT 75

// used in FollowRocket2
#define CAMERA_VELOCITY_FACTOR 0.6

#define CAMERA_DENSITY 3.0 //weight of the camera body
#define CAMERA_LINEAR_DAMP 20.0 //the linear dampening for the camera, causes it to drag behind
#define CAMERA_SPRING 10.0 //the spring force that pulls the camera towards its target

// AP: clean this shit up once I get a smooth camera follow
#define CAMERA_CORRECTION_FACTOR 0.1 // affects the speed at which the camera will try to follow the rocket
#define CAMERA_MIN_DELTA 0.5
#define CAMERA_CATCHUP_TIME 1.0 //1 second
#define MAX_CAMERA_SPEED 1.0 //(in M/s)

#define BULLET_TIME 0.1
#define TOTAL_BULLETS 100000

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
        fireSide = 10;
        
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
        lastCameraPos = b2Vec2_zero;
        lastCameraVel = b2Vec2_zero;
        
		// Handle this onEnter and onExit
        self.isTouchEnabled = NO;
        
		self.isAccelerometerEnabled = YES;
		CGSize s = [CCDirector sharedDirector].winSize;
		
		// init physics
        
		[self initPhysics];
        // init contact listener
        contactListener = new Level1ContactListener();
        world->SetContactListener(contactListener);
        
		[self createBackground];
        [self createObstacle];
        //[self initAsteroids];
		//Set up sprite
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Playground2Atlas.plist"];
        sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"Playground2Atlas.png" capacity:250];
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
    delete contactListener;
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
    
    b2FixtureDef fixtureDef;
    fixtureDef.isSensor = true;
    fixtureDef.density = 0.0;
    
    b2BodyDef cameraBodyDef;
    cameraBodyDef.type = b2_dynamicBody;
    cameraBodyDef.position = b2Vec2(0.0f,0.0f);
    cameraBody = world->CreateBody(&cameraBodyDef);
    
    b2CircleShape circle;
    circle.m_radius = 0.5;
    circle.m_p = b2Vec2(0.0f, 0.0f);
    
    fixtureDef.shape = &circle;
    fixtureDef.density = CAMERA_DENSITY;
    
    cameraBody->SetLinearDamping(CAMERA_LINEAR_DAMP);
    cameraBody->CreateFixture(&fixtureDef);
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
    
}

-(void) createBullet:(ccTime)deltaTime {
    
    if ((bulletTime >= BULLET_TIME) || (bulletCount == 0)){
        if (bulletCount <= TOTAL_BULLETS) {
            b2Vec2 firePoint = rocket.body->GetWorldPoint(b2Vec2(fireSide/PTM_RATIO,25/PTM_RATIO));
            bullet *bulletShot = [[bullet alloc] initWithWorld:world atLoaction:firePoint];
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
            fireSide *= -1;
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
    
    [self updateCameraPosition:newPos];

}

-(void) updateCameraPosition:(CGPoint) newTarget
{
    b2Vec2 currentPos = b2Vec2([self position].x/PTM_RATIO, [self position].y/PTM_RATIO);
    b2Vec2 nextPos = b2Vec2(newTarget.x/PTM_RATIO, newTarget.y/PTM_RATIO);
    
    b2Vec2 forceVector = nextPos - currentPos;
    
    float forceMag = forceVector.Normalize();
    
    forceMag *= forceMag * CAMERA_SPRING * cameraBody->GetMass();
    
    forceVector.x *= forceMag;
    forceVector.y *= forceMag;
    
    cameraBody->ApplyForce(forceVector, cameraBody->GetPosition());
    
    [self setPosition:ccp(cameraBody->GetPosition().x * PTM_RATIO, cameraBody->GetPosition().y * PTM_RATIO)];
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
        
    [self updateCameraPosition:newPos];   
    
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
