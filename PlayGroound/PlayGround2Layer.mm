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

#define LEVEL_HEIGHT 25
#define LEVEL_WIDTH 10
#define MAX_VELOCITY 5
#define FRICTION_COEFF 0.08
#define TURN_SPEED 20.0
#define ASTEROID_TIMER 0.5
#define ASTEROID_LIMIT 30

#define CAMERA_CORRECTION_FACTOR 0.1 // affects the speed at which the camera will try to follow the rocket
#define CAMERA_MIN_DELTA 0.01


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

@synthesize asteroidCache;
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
        
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft){
            turn = -1;
        } else {
            turn = 1;
        }
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
		
#if 1
		// Use batch node. Faster
		CCSpriteBatchNode *parent = [CCSpriteBatchNode batchNodeWithFile:@"blocks.png" capacity:100];
		spriteTexture_ = [parent texture];
#else
		// doesn't use batch node. Slower
		spriteTexture_ = [[CCTextureCache sharedTextureCache] addImage:@"blocks.png"];
		CCNode *parent = [CCNode node];
#endif
		[self addChild:parent z:0 tag:kTagParentNode];
		
		//[self addNewSpriteAtPosition:ccp(s.width/2, s.height/2)];
        //JP Creating a Ball to play with instead of Box
        //[self createBall];
        
        //rocket = [[Rocket alloc] initWithWorld:world atLocation:ccp(s.width * 1.5 /2 + 70.0, s.height*0.16)];
        rocket = [[Rocket alloc] initWithWorld:world atLocation:ccp(s.width * LEVEL_WIDTH/2, s.height*LEVEL_HEIGHT/2)];
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
        [self addChild:rocket z:100];

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
    
     asteroidCache = [[CCArray alloc] initWithCapacity:25];
     
     for (int i = 0; i < 25; i++)
     {
     Asteroid *sprite = [[[Asteroid alloc] initWithWorld:world atLoaction:ccp(winSize.width * 0.5 + (5*i), winSize.height * 0.5)] autorelease];
     sprite.position = ccp(winSize.width/2,winSize.height/2);
     [self addChild:sprite];
     [asteroidCache addObject:sprite];
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
    
    int32 velocityIterations = 3;
    int32 positionIterations = 2;
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
            b2Vec2 velocity = b->GetLinearVelocity();
#if USE_MAX_VELOCITY            
            if (velocity.LengthSquared() > MAX_VELOCITY*MAX_VELOCITY)
            {
                float velocityScale = MAX_VELOCITY/velocity.Length();
                
                b2Vec2 newVelocity = b2Vec2(velocity.x * velocityScale, velocity.y *velocityScale);
                b->SetLinearVelocity(newVelocity);

            }
#else //use drag
            b2Vec2 force = velocity;
            force.Normalize();
            force=-force;
            force*=velocity.LengthSquared()*FRICTION_COEFF;
            b->ApplyForceToCenter(force);
#endif
        }
    }
    //JP HACK to run the rocket update should use:
    //  CCArray *listOfGameObjects = [sceneSpriteBatchNode children];
    //  for (GameCharacter *tempChar in listOfGameObjects) {
    //     [tempChar updateStateWithDeltaTime:dt
    //                  andListOfGameObjects:listOfGameObjects];
    //  }
    [self fireAsteroid:dt];
    [rocket updateStateWithDeltaTime:dt];
	[self followRocket:dt];
    
    
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
    float roll = currentAttitude.roll;
    float yaw = currentAttitude.yaw;
    float turnPower = pitch * TURN_SPEED * turn;
    
    rocket.body->ApplyTorque(rocket.body->GetMass()*pitch * TURN_SPEED * turn);
    //rocket.body->SetAngularVelocity(turnPower);

    NSString *labelString = 
    [NSString stringWithFormat:@"Roll:%.4f \n Pitch:%.4f \n Yaw:%.4f \n Turn:%.4f",roll,pitch,yaw,turnPower];
    [debugLabel setString:labelString];
 
    
}

- (void) didFlipScreen:(NSNotification *)notification{ 
    turn *= -1;
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
        [self addChild:sprite];
        asteroidTimer = 0.0;
        asteroidsCreated += 1;
    }
}

-(void)followRocket:(float) dt {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;


    b2Vec2 cTarget = rocket.body->GetWorldPoint(b2Vec2(0, 4.5));
                                            
    
    float fixtedPositionY = winSize.height/2;
    float fixtedPositionX = winSize.width/2;
    float newY = fixtedPositionY - cTarget.y * PTM_RATIO;
    float newX = fixtedPositionX - cTarget.x * PTM_RATIO;
    
    newX = MIN(newX,0);
    newX = MAX(newX,-winSize.width * (LEVEL_WIDTH - 1));
    newY = MIN(newY,0);
    newY = MAX(newY,-winSize.height * (LEVEL_HEIGHT-1));
    
    //CGPoint newPos = ccp(newX, newY);
    
    //[self setPosition:newPos];
    
    cameraTarget = ccp(newX, newY);
    
    CGPoint currentPos = [self position];
    
    CGPoint travelVector = ccp(cameraTarget.x - currentPos.x, cameraTarget.y - currentPos.y);
    
    //calculate a new position based on the distance between
    CGPoint newPos;
    
    float totalDistance = sqrt(travelVector.x*travelVector.x + travelVector.y*travelVector.y);
    
    //if the distance to travel is zero, we're done
    if (totalDistance == 0.0f)
    {
        return;
    }
    
    float distanceToMove = totalDistance*CAMERA_CORRECTION_FACTOR;
    
    //make sure we don't overshoot, and check if we are close enough
    if ((distanceToMove > totalDistance) || (distanceToMove < CAMERA_MIN_DELTA))
    {
        newPos.x =cameraTarget.x;
        newPos.y =cameraTarget.y;
    }
    else 
    {
        newPos.x = currentPos.x + travelVector.x * distanceToMove/totalDistance;
        newPos.y = currentPos.y + travelVector.y * distanceToMove/totalDistance;
    }
    
    [self setPosition:newPos];

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
