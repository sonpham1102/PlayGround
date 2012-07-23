//
//  PlayGround1Layer.mm
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "PlayGround1Scene.h"
#import "PlayGround1Layer.h"
// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#import "PhysicsSprite.h"
#import "GameManager.h"
#import "RocketMan.h"

/*
typedef enum {
    UISwipeGestureRecognizerDirectionRight = 1 << 0,
    UISwipeGestureRecognizerDirectionLeft  = 1 << 1,
    UISwipeGestureRecognizerDirectionUp    = 1 << 2,
    UISwipeGestureRecognizerDirectionDown  = 1 << 3
} UISwipeGestureRecognizerDirection;
*/

//AP : MOVE to a plist or something
#define SCREEN_LENGTHS 5.0 //number of screens high for the level 
#define END_ZONE_SENSOR_SIZE 0.10 //multiple of screen height
#define FIXED_POS_Y 0.33f // multiple of screen height

enum {
	kTagParentNode = 1,
};


#pragma mark - HelloWorldLayer

@interface PlayGround1Layer()
-(void) initPhysics;
-(void) addNewSpriteAtPosition:(CGPoint)p;
-(void) createMenu;
-(void) createRocketMan:(CGPoint) location;
@end

@implementation PlayGround1Layer


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
        
        // create the rocket man
        [self createRocketMan:ccp(s.width/2, s.height/5)];
        
        // add it as a child
        [self addChild:rocketMan z:0];
        
        // make sure touches are enabled for it so gesture recognizer gets it
        rocketMan.isTouchEnabled = YES;
        
        // use to do a smoother camera follow
        cameraTarget = CGPointZero;

        // use for 
        panStartPoint = CGPointZero;
        
		
		//Set up sprite
/*		
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
		
		
		[self addNewSpriteAtPosition:ccp(s.width/2, s.height/2)];
*/		
/* set up a swipe handler - USING PAN INSTEAD
        UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGestureRecognizer:)];
        [self addGestureRecognizer:swipeGestureRecognizer];
        swipeGestureRecognizer.direction = (UISwipeGestureRecognizerDirection)(UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft);
        swipeGestureRecognizer.delegate = self;
        [swipeGestureRecognizer release];
*/        
        //! pan gesture recognizer
        UIGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        panGestureRecognizer.delegate = self;
        [self addGestureRecognizer:panGestureRecognizer];
        [panGestureRecognizer release];

        
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Tap screen" fontName:@"Marker Felt" fontSize:32];
		[self addChild:label z:0];
		[label setColor:ccc3(0,0,255)];
		label.position = ccp( s.width/2, s.height-50);
		
		[self scheduleUpdate];
	}
	return self;
}

- (void)handleSwipeGestureRecognizer:(UISwipeGestureRecognizer*)aGestureRecognizer
{
    CCLOG(@"swipe detected");

}

- (void)handlePanGesture:(UIPanGestureRecognizer*)aPanGestureRecognizer
{
    if (aPanGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        // log the start point
        panStartPoint = [aPanGestureRecognizer locationInView:aPanGestureRecognizer.view];
    }
    else if (aPanGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint endLocation = [aPanGestureRecognizer locationInView:aPanGestureRecognizer.view];
        
        //see if the pan actually intersected one of the sides of the rocket man
        CGRect boundingBox = rocketMan.boundingBox;
        
        float left = CGRectGetMinX(boundingBox);        
        float right = CGRectGetMinX(boundingBox);
        float top = CGRectGetMinX(boundingBox);
        float bottom = CGRectGetMinX(boundingBox);
        
        //check left side
        
        
    }
    
/*    
    - (void)panGesture:(UIPanGestureRecognizer *)sender {
        if (sender.state == UIGestureRecognizerStateBegan) {
            startLocation = [sender locationInView:self.view];
        }
        else if (sender.state == UIGestureRecognizerStateEnded) {
            CGPoint stopLocation = [sender locationInView:self.view];
            CGFloat dx = stopLocation.x - startLocation.x;
            CGFloat dy = stopLocation.y - startLocation.y;
            CGFloat distance = sqrt(dx*dx + dy*dy );
            NSLog(@"Distance: %f", distance);
        }
    }
*/
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
	CCMenuItemLabel *reset = [CCMenuItemFont itemWithString:@"Main Menu" block:^(id sender){
		[[GameManager sharedGameManager] runLevelWithID:kMainMenu];
	}];
	
	CCMenu *menu = [CCMenu menuWithItems: reset, nil];
	
	[menu alignItemsVertically];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	[menu setPosition:ccp( size.width*0.9, size.height*0.9)];
	
	
	[self addChild: menu z:-1];	
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
	
	groundBox.Set(b2Vec2(0,0), b2Vec2(s.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// top
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO*SCREEN_LENGTHS), b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO*SCREEN_LENGTHS));
	groundBody->CreateFixture(&groundBox,0);
	
	// left
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO*SCREEN_LENGTHS), b2Vec2(0,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// right
	groundBox.Set(b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO*SCREEN_LENGTHS), b2Vec2(s.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
    
    b2BodyDef endZoneSensorDef;
    endZoneSensorDef.type = b2_staticBody;
    endZoneSensorDef.position.Set(0, s.height/PTM_RATIO*SCREEN_LENGTHS - s.height/PTM_RATIO*END_ZONE_SENSOR_SIZE);
    
    endZoneSensor = world->CreateBody(&endZoneSensorDef);
    
    b2PolygonShape shape;
    shape.SetAsBox(s.width/PTM_RATIO, s.height/PTM_RATIO * END_ZONE_SENSOR_SIZE);
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
    fixtureDef.isSensor = true;
    fixtureDef.density = 0.0;
    
    endZoneSensor->CreateFixture(&fixtureDef);
}

-(void) createRocketMan:(CGPoint) location
{
    rocketMan = [[RocketMan alloc] initWithWorld:world atLocation:location];
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
	b2Body *body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(.5f, .5f);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	body->CreateFixture(&fixtureDef);
	
	[sprite setPhysicsBody:body];
}

-(void) resetRocketManPosition
{
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    rocketMan.body->SetTransform( b2Vec2(screenSize.width/2/PTM_RATIO, screenSize.height/5/PTM_RATIO), 0.0f);
    rocketMan.body->SetLinearVelocity(b2Vec2_zero);
    rocketMan.body->SetAngularVelocity(0.0);
}

-(void) followRocketMan
{
    // calculate where we would like the camera to be
    CGSize winSize = [CCDirector sharedDirector].winSize;
    float newY = rocketMan.position.y - winSize.height*FIXED_POS_Y;
    newY = MAX(newY, 0);
    newY = MIN(newY, winSize.height * SCREEN_LENGTHS-winSize.height);
    CGPoint newPos = ccp(self.position.x, -newY);
    
    // move to the new position gradually
    
    
    [self setPosition:newPos];
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

/* AP, need to set up a spritebatchnode to do this
    CCArray *listOfGameObjects = [sceneSpriteBatchNode children];
    for (GameCharacter *tempChar in listOfGameObjects)
    {
        [tempChar updateStateWithDeltaTime:dt andListOfGameObjects:listOfGameObjects];
    }
*/
    
    // see if the rocketMan is in the end zone
    b2ContactEdge *edge = rocketMan.body->GetContactList();
    while (edge)
    {
        b2Contact *contact = edge->contact;
        if (contact->IsTouching())
        {
            b2Fixture *fixtureA = contact->GetFixtureA();
            b2Fixture *fixtureB = contact->GetFixtureB();
            b2Body *bodyA = fixtureA->GetBody();
            b2Body *bodyB = fixtureB->GetBody();

            if ((bodyA == endZoneSensor) || (bodyB == endZoneSensor))
            {
                [self resetRocketManPosition];
            }
        }
        edge = edge->next;
    }

    
    [self followRocketMan];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    rocketMan.body->ApplyLinearImpulse(b2Vec2(0,rocketMan.body->GetMass() * 5.0), rocketMan.body->GetWorldCenter());
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

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
