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

#define LEVEL_HEIGHT 10
#define LEVEL_WIDTH 2

enum {
	kTagParentNode = 1,
};


#pragma mark - HelloWorldLayer

@interface PlayGround2Layer()
-(void) initPhysics;
@end

@implementation PlayGround2Layer


-(id) init
{
	if( (self=[super init])) {
		
        touchRight = nil;
        touchLeft = nil;
        
        leftRocketSoundID = 0;
        rightRocketSoundID = 0;
        
		// enable events
		
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		CGSize s = [CCDirector sharedDirector].winSize;
		
		// init physics
		[self initPhysics];
		[self createBackground];
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
		
		[self scheduleUpdate];
	}
	return self;
}

-(void) createBackground {
    CCSprite *backgroundImage;
    if (IS_IPAD())
    {
        //indicates game is running on an IPAD
        backgroundImage = [CCSprite spriteWithFile:@"Space_Background_iPad.png"];
    }
    else
    {
        backgroundImage = [CCSprite spriteWithFile:@"Space_Background_iPhone.png"];
    }
    
    backgroundImage.scaleX = LEVEL_WIDTH;
    backgroundImage.scaleY = LEVEL_HEIGHT;
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    [backgroundImage setPosition:CGPointMake(screenSize.width * LEVEL_WIDTH/2, screenSize.height * LEVEL_HEIGHT/2)];
    [self addChild:backgroundImage z:-5];
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
	gravity.Set(0.0f, -10.0f);
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
        }
    }
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
        
        if (location.x < [CCDirector sharedDirector].winSize.width/2) {
            if (touchLeft == nil)
            {
                [self schedule:@selector(fireLeft)];
                touchLeft = touch;
                leftRocketSoundID = PLAYSOUNDEFFECTLOOPED(ROCKET_JET);
            }
        } else {
            if (touchRight == nil)
            {
                [self schedule:@selector(fireRight)];
                touchRight = touch;
                rightRocketSoundID = PLAYSOUNDEFFECTLOOPED(ROCKET_JET);
            }
        }
    }    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        
        if (touch == touchLeft) {
            [self unschedule:@selector(fireLeft)];
            touchLeft = nil;
            STOPSOUNDEFFECT(leftRocketSoundID);
        } else  if (touch == touchRight) {
            [self unschedule:@selector(fireRight)];
            touchRight = nil;
            STOPSOUNDEFFECT(rightRocketSoundID);
        }
    } 
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
