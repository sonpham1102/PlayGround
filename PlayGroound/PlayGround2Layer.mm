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

enum {
	kTagParentNode = 1,
};


#pragma mark - HelloWorldLayer

@interface PlayGround2Layer()
-(void) initPhysics;
-(void) addNewSpriteAtPosition:(CGPoint)p;
-(void) createMenu;
@end

@implementation PlayGround2Layer


-(id) init
{
	if( (self=[super init])) {
		
		// enable events
		
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		CGSize s = [CCDirector sharedDirector].winSize;
		
		// init physics
		[self initPhysics];
		
		// create reset button
		[self createMenu];
		
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
        [self createBall];
		
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"This is Level 2" fontName:@"Marker Felt" fontSize:32];
		[self addChild:label z:0];
		[label setColor:ccc3(0,0,255)];
		label.position = ccp( s.width/2, s.height-50);
		
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

-(void) createMenu
{
	// Default font size will be 22 points.
	[CCMenuItemFont setFontSize:22];
	
	// Reset Button
	CCMenuItemLabel *reset = [CCMenuItemFont itemWithString:@"Main Menu" block:^(id sender)
    {
		[[GameManager sharedGameManager] runLevelWithID:kMainMenu];
	}];
	//JP : Not using Achievements and Leader Boards of now
    /*
	// Achievement Menu Item using blocks
	CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:@"Achievements" block:^(id sender) {
		
		
		GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
		achivementViewController.achievementDelegate = self;
		
		AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
		
		[[app navController] presentModalViewController:achivementViewController animated:YES];
		
		[achivementViewController release];
	}];
	
	// Leaderboard Menu Item using blocks
	CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"Leaderboard" block:^(id sender) {
		
		
		GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
		leaderboardViewController.leaderboardDelegate = self;
		
		AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
		
		[[app navController] presentModalViewController:leaderboardViewController animated:YES];
		
		[leaderboardViewController release];
	}];*/
	
    //JP: Removed menu options for Achievments and LeaderBoards, Also Reduced Size of text;
    [reset setScale:0.75f];
	//CCMenu *menu = [CCMenu menuWithItems:itemAchievement, itemLeaderboard, reset, nil];
    CCMenu *menu = [CCMenu menuWithItems:reset, nil];
    
	
	[menu alignItemsVertically];
	
    //JP: Repositioned Menu to Upper Right Corner
    //    Should use IPAD Idiom to set properly
	CGSize size = [[CCDirector sharedDirector] winSize];
	[menu setPosition:ccp( size.width*0.9, size.height*0.95)];
	
	
	[self addChild: menu z:-1];	
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
	
	kmGLPopMatrix();
}

-(void) createBall{
    
    CGSize p = [CCDirector sharedDirector].winSize;
    
    b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(p.width/2/PTM_RATIO, p.height/2/PTM_RATIO);
	//b2Body *body = world->CreateBody(&bodyDef);
    mainBody = world->CreateBody(&bodyDef);
    
    b2CircleShape dynamicCircle;
    dynamicCircle.m_radius = 0.6f;
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicCircle;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
    fixtureDef.restitution = 0.25;
	mainBody->CreateFixture(&fixtureDef);}

-(void) addNewSpriteAtPosition:(CGPoint)p
{
	CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);
	CCNode *parent = [self getChildByTag:kTagParentNode];
	
	//We have a 64x64 sprite sheet with 4 different 32x32 images.  The following code is
	//just randomly picking one of the images
	int idx = (CCRANDOM_0_1() > .5 ? 0:1);
	int idy = (CCRANDOM_0_1() > .5 ? 0:1);
	PhysicsSprite *sprite = [PhysicsSprite spriteWithTexture:spriteTexture_ rect:CGRectMake(32 * idx,32 * idy,32,32)];						
	[parent addChild:sprite];
	
	sprite.position = ccp( p.x, p.y);
	
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	//b2Body *body = world->CreateBody(&bodyDef);
    mainBody = world->CreateBody(&bodyDef);
    
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(.5f, .5f);//These are mid points for our 1m box
	

	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
    fixtureDef.restitution = 0.25;
	mainBody->CreateFixture(&fixtureDef);
	
	[sprite setPhysicsBody:mainBody];
}

-(void) update: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);	
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //AP : just adding a sound test here
    PLAYSOUNDEFFECT(PUZZLE_SKULL);
    
    
    //JP Dont want to add bodies on touches now 
    /*
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		
		[self addNewSpriteAtPosition: location];
	}*/
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
