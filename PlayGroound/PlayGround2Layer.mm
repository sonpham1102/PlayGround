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

#define LEVEL_HEIGHT 5
#define LEVEL_WIDTH 1.5
#define MAX_VELOCITY 5
#define FRICTION_COEFF 0.08

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

-(void) onEnter{
    [super onEnter];
    self.isTouchEnabled = YES;
}

-(void) onExit{
    [super onExit];
    self.isTouchEnabled = NO;
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
        
		// enable events
		
		// Handle this onEnter and onExit
        self.isTouchEnabled = NO;
        
		self.isAccelerometerEnabled = YES;
		CGSize s = [CCDirector sharedDirector].winSize;
		
		// init physics
		[self initPhysics];
		[self createBackground];
        [self createObstacle];
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
        
        rocket = [[Rocket alloc] initWithWorld:world atLocation:ccp(s.width/2, s.height/2)];
        
        
		
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"This is Level 2" fontName:@"Marker Felt" fontSize:32];
		[self addChild:label z:0];
		[label setColor:ccc3(0,0,255)];
		label.position = ccp( s.width/2, s.height-50);
        
        [self addChild:rocket z:100];
		
		[self scheduleUpdate];
	}
	return self;
}

-(void) createBackground {
    
    tileMapNode = [CCTMXTiledMap
                tiledMapWithTMXFile:@"SpaceBackground.tmx"];
    [self addChild:tileMapNode z:-5];
}

-(void) dealloc
{
	delete world;
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
	
	[super dealloc];
}

-(void)createObstacle {
    //Spikes * spikes;
    CGSize winSize = [CCDirector sharedDirector].winSize;
    Obstacle * obstacle;
    obstacle = [[[Obstacle alloc] initWithWorld:world atLoaction:ccp(winSize.width * 1.5 / 2, 0)] autorelease];
    [self addChild:obstacle];
}

-(void) initPhysics
{
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	b2Vec2 gravity;
	gravity.Set(0.0f, -10.0f);
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
    [rocket updateStateWithDeltaTime:dt];
	[self followRocket];
}

-(void)followRocket {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;

    b2Vec2 position = rocket.body->GetPosition();
    
    float fixtedPositionY = winSize.height/2;
    float fixtedPositionX = winSize.width/2;
    float newY = fixtedPositionY - position.y * PTM_RATIO;
    float newX = fixtedPositionX - position.x * PTM_RATIO;
    
    newX = MIN(newX,0);
    newX = MAX(newX,-winSize.width * (LEVEL_WIDTH - 1));
    newY = MIN(newY,0);
    newY = MAX(newY,-winSize.height * (LEVEL_HEIGHT-1));
    
    CGPoint newPos = ccp(newX, newY);
    
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
