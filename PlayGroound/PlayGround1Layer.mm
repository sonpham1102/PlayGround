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
#define CAMERA_CORRECTION_FACTOR 3.0 // affects the speed at which the camera will try to follow the rocket
#define CAMERA_MIN_DELTA 0.001
#define MIN_PAN_LENGTH_SQ 0.20 //in meters, squared

enum {
	kTagParentNode = 1,
};


#pragma mark - HelloWorldLayer

@interface PlayGround1Layer()
-(void) initPhysics;
-(void) addNewSpriteAtPosition:(CGPoint)p;
-(void) createRocketMan:(CGPoint) location;
@end

@implementation PlayGround1Layer

-(void) createBackground {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    tileMapNode = [CCTMXTiledMap
                   tiledMapWithTMXFile:@"Playground1Background.tmx"];
    [tileMapNode setPosition:ccp(winSize.width, winSize.height*SCREEN_LENGTHS/2.0)];
    [tileMapNode setPosition:ccp(0.0, 0.0)];
    [tileMapNode setScaleY:SCREEN_LENGTHS];
    [self addChild:tileMapNode z:-10];

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
		        
        // create the rocket man
        [self createRocketMan:ccp(s.width/2, s.height/5)];
        
        // add it as a child
        [self addChild:rocketMan z:0];
        
        // make sure touches are enabled for it so gesture recognizer gets it
        //rocketMan.isTouchEnabled = YES;
        
        // use to do a smoother camera follow
        cameraTarget = CGPointZero;
        
        //_panRaycastCallback = new PanRayCastCallback();
        
        debugLineEndPoint = CGPointZero;
        debugLineStartPoint = CGPointZero;      
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Tap screen" fontName:@"Marker Felt" fontSize:32];
		[self addChild:label z:0];
		[label setColor:ccc3(0,0,255)];
		label.position = ccp( s.width/2, s.height-50);
        
        [self createBackground];
		
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
    
    //ccDrawLine(debugLineStartPoint, debugLineEndPoint);
	
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

-(void) followRocketMan:(float) dt
{
    // calculate where we would like the camera to be
    CGSize winSize = [CCDirector sharedDirector].winSize;
    float newY = rocketMan.position.y - winSize.height*FIXED_POS_Y;
    newY = MAX(newY, 0);
    newY = MIN(newY, winSize.height * SCREEN_LENGTHS-winSize.height);
    
    
    cameraTarget = ccp(self.position.x, -newY);

    // move to the new position gradually
    // calculate a "speed" for the catchup that is proportional to how far away the current position is
    // from the target
    CGPoint currentPos = [self position];
    
    CGPoint travelVector = ccp(cameraTarget.x - currentPos.x, cameraTarget.y - currentPos.y);
    
    //calculate a new position based on the distance between
    CGPoint newPos;
    
    float totalDistanceSquared = travelVector.x*travelVector.x + travelVector.y*travelVector.y;
    
    //if the distance to travel is zero, we're done
    if (totalDistanceSquared == 0.0f)
    {
        return;
    }
    float sqrtTD = sqrtf(totalDistanceSquared);    

    float distanceToMove = sqrtTD*CAMERA_CORRECTION_FACTOR*dt;
    
    //make sure we don't overshoot, and check if we are close enough
    if (((distanceToMove * distanceToMove) > totalDistanceSquared) || (distanceToMove < CAMERA_MIN_DELTA))
    {
        newPos.x =cameraTarget.x;
        newPos.y =cameraTarget.y;
    }
    else 
    {
        newPos.x = currentPos.x + travelVector.x * distanceToMove/sqrtTD;
        newPos.y = currentPos.y + travelVector.y * distanceToMove/sqrtTD;
    }
    
    [self setPosition:newPos];
}

-(void) handlePan:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    
    //make sure the length is big enough, otherwise ignore
    b2Vec2 slashVector = b2Vec2((endPoint.x - startPoint.x)/PTM_RATIO, (endPoint.y - startPoint.y)/PTM_RATIO);
    if (slashVector.LengthSquared() < MIN_PAN_LENGTH_SQ)
    {
        CCLOG(@"Pan too short %.2f vs %.2f", slashVector.LengthSquared(), MIN_PAN_LENGTH_SQ);         
        return;
    }
    else
    {
        CCLOG(@"Pan good %.2f", slashVector.LengthSquared());
    }
    
    debugLineStartPoint = startPoint;
    debugLineEndPoint = endPoint;
    
    // give the rocked the parameters for the pan move
    // AP this is two functions in case I want to use collision detection to see if touch actually hits the 
    // rocket
    [rocketMan planPanMove:startPoint endPoint:endPoint];
    [rocketMan executePanMove];
    
    //AP - here's where I would check for a "valid" pan (for now all pans are valid) 
    
    //AP : Need to subtract any movement of the view
    //panEndPoint.x -= [self position].x;
    //panEndPoint.y -= [self position].y;
    
    
    // perform a raycast, if the line hits the rocketman
//    world->RayCast(_panRaycastCallback, b2Vec2(panStartPoint.x/PTM_RATIO, panStartPoint.y/PTM_RATIO),
//                   b2Vec2(panEndPoint.x/PTM_RATIO, panEndPoint.y/PTM_RATIO));
    
    
    /*
     //see if the pan actually intersected one of the sides of the rocket man
     CGRect boundingBox = rocketMan.boundingBox;
     
     float left = CGRectGetMinX(boundingBox);        
     float right = CGRectGetMaxX(boundingBox);
     float top = CGRectGetMinX(boundingBox);
     float bottom = CGRectGetMinX(boundingBox);
     
     float determinant; 
     */        
    

    
    
}

-(void) handleTap:(CGPoint)tapPoint
{
    [rocketMan planTapMove:tapPoint];
    [rocketMan executeTapMove];
}

-(void) handleRotation:(float)angleDelta
{
    [rocketMan planRotationMove:angleDelta];
    [rocketMan executeRotationMove];
}

-(void) handleLongPress:(BOOL)continueFiring
{
    [rocketMan planLongPressMove:continueFiring];
    [rocketMan executeLongPressMove];
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
    //HACK for now just call the update on the rocket manually
    [rocketMan updateStateWithDeltaTime:dt andListOfGameObjects:nil];
    
    
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

    
    [self followRocketMan:dt];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    rocketMan.body->ApplyLinearImpulse(b2Vec2(0,rocketMan.body->GetMass() * 5.0), rocketMan.body->GetWorldCenter());
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
