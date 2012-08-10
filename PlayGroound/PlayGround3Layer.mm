//
//  PlayGround3Layer.mm
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "PlayGround3Scene.h"
#import "PlayGround3Layer.h"
// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#import "PhysicsSprite.h"
#import "GameManager.h"
#import "RocketMan3.h"

/*
typedef enum {
    UISwipeGestureRecognizerDirectionRight = 1 << 0,
    UISwipeGestureRecognizerDirectionLeft  = 1 << 1,
    UISwipeGestureRecognizerDirectionUp    = 1 << 2,
    UISwipeGestureRecognizerDirectionDown  = 1 << 3
} UISwipeGestureRecognizerDirection;
*/

//AP : MOVE to a plist or something
#define SCREEN_LENGTHS 3.0 //number of screens high for the level 
#define SCREEN_WIDTHS 5.0
#define END_ZONE_SENSOR_SIZE 0.10 //multiple of screen height
#define FIXED_POS_Y 0.33f // multiple of screen height
#define FIXED_POS_X 0.33f // multiple of screen width
#define CAMERA_CORRECTION_FACTOR 3.0 // affects the speed at which the camera will try to follow the rocket
#define CAMERA_MIN_DELTA 0.001
#define MIN_PAN_LENGTH_SQ 0.20 //in meters, squared

#define CAMERA_DENSITY 3.0 //weight of the camera body
#define CAMERA_LINEAR_DAMP 20.0 //the linear dampening for the camera, causes it to drag behind
#define CAMERA_SPRING 10.0 //the spring force that pulls the camera towards its target

#define CAMERA_VELOCITY_FACTOR 1.5 //multiplied by rocket velocity to push camera back

enum {
	kTagParentNode = 1,
};


#pragma mark - HelloWorldLayer

@interface PlayGround3Layer()
-(void) initPhysics;
-(void) addNewSpriteAtPosition:(CGPoint)p;
-(void) createRocketMan:(CGPoint) location;
@end

@implementation PlayGround3Layer

-(void) createBackground {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    tileMapNode = [CCTMXTiledMap
                   tiledMapWithTMXFile:@"Playground1Background.tmx"];
    [tileMapNode setPosition:ccp(winSize.width*SCREEN_WIDTHS/2.0, winSize.height*SCREEN_LENGTHS/2.0)];
    [tileMapNode setPosition:ccp(0.0, 0.0)];
    [tileMapNode setScaleY:SCREEN_LENGTHS];
    [tileMapNode setScaleX:SCREEN_WIDTHS];
    [self addChild:tileMapNode z:-10];
}

-(NSString *)getTimerString;
{
    return timerString;
}

#define HORIZONTAL_MIN_SPACE 20.0
#define HORIZONTAL_MAX_SPACE 30.0
#define VERTICAL_MAX_SPACE 15.0
#define VERTICAL_MIN_SPACE 5.0
#define MIN_OBSTACLE_WIDTH 2.0
#define MAX_OBSTACLE_WIDTH 6.0
#define MIN_OBSTACLE_HEIGHT 20.0
#define MAX_OBSTACLE_HEIGHT 40.0

-(void) createObstacleAtLocation: (b2Vec2) location withWidth: (float) width withHeight: (float) height
{
    b2BodyDef obstacleDef;
    obstacleDef.type = b2_staticBody;
        
    obstacleDef.position.Set(location.x + width/2.0, location.y + height/2.0);
    
    b2Body *body = world->CreateBody(&obstacleDef);
    
    b2PolygonShape shape;
    
    shape.SetAsBox(width/2.0, height/2.0);
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
    //fixtureDef.isSensor = true;
    fixtureDef.density = 0.0;
    fixtureDef.restitution = 1.2f;
    fixtureDef.friction = 0.0f;
    
    
    body->CreateFixture(&fixtureDef);
    
}

-(void) createObstacleRow: (float) atX withWidth: (float) width
{
    float maxY = [CCDirector sharedDirector].winSize.height * SCREEN_LENGTHS/PTM_RATIO; //in meters
    float yLocation = 0.0f; // in meters
    
    while (yLocation < maxY)
    {
        //determine a random height for the obstacle row
        float height = (float)arc4random()/(float)0x100000000;
        height = MIN_OBSTACLE_HEIGHT + height * (MAX_OBSTACLE_HEIGHT - MIN_OBSTACLE_HEIGHT);
        [self createObstacleAtLocation:b2Vec2(atX, yLocation) withWidth:width withHeight:height];
        
        yLocation += height;
        
        //determine a random spacing for the next object
        height = (float)arc4random()/(float)0x100000000;
        height = VERTICAL_MIN_SPACE + height * (VERTICAL_MAX_SPACE - VERTICAL_MIN_SPACE);
        
        yLocation += height;
    }
}

-(void) createObstacles
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    float xLocation = 0.7*winSize.width / PTM_RATIO; // in meters
    
    float lastXLocation = winSize.width * (SCREEN_WIDTHS - 0.75) / PTM_RATIO; //in meters
    
    while (xLocation < lastXLocation)
    {
        //determine a random height for the obstacle row
        float width = (float)arc4random()/(float)0x100000000;
        width = MIN_OBSTACLE_WIDTH + width * (MAX_OBSTACLE_WIDTH - MIN_OBSTACLE_WIDTH);
        [self createObstacleRow:xLocation withWidth:width];
        
        xLocation += width;
        
        //determine a random spacing for the next row
        width = (float)arc4random()/(float)0x100000000;
        width = HORIZONTAL_MIN_SPACE + width*(HORIZONTAL_MAX_SPACE - HORIZONTAL_MIN_SPACE);
        
        xLocation += width;
    }
}

-(void) setString3:(id)sender
{
    timerString = @"3";
}

-(void) setString2:(id)sender
{
    timerString = @"2";
}

-(void) setString1:(id)sender
{
    timerString = @"1";
}

-(void) setStringGo:(id)sender
{
    timerString = @"GO!";
    acceptingInput = true;
    raceTimer = 0.0;
}

-(void) startStartSequence
{
    acceptingInput = false;
    CCDelayTime *delay = [CCDelayTime actionWithDuration:1.0];
    CCCallFuncN *action3 = [CCCallFuncN actionWithTarget:self selector:@selector(setString3:)];
    CCCallFuncN *action2 = [CCCallFuncN actionWithTarget:self selector:@selector(setString2:)];
    CCCallFuncN *action1 = [CCCallFuncN actionWithTarget:self selector:@selector(setString1:)];
    CCCallFuncN *actionGO = [CCCallFuncN actionWithTarget:self selector:@selector(setStringGo:)];
    CCSequence *actionList = [CCSequence actions:action3, delay, action2, delay, action1, delay, actionGO, nil];
    
    [self runAction:actionList];
}

-(void) onEnter
{
    [self startStartSequence];
    [super onEnter];
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
        [self createRocketMan:ccp(s.width/2.0/PTM_RATIO, s.height/5.0/PTM_RATIO)];
        
        // add it as a child
        [self addChild:rocketMan z:0];
        
        [self createObstacles];
        
        // make sure touches are enabled for it so gesture recognizer gets it
        //rocketMan.isTouchEnabled = YES;
        
        // use to do a smoother camera follow
        cameraTarget = CGPointZero;
        lastCameraPos = b2Vec2_zero;
        lastCameraVel = b2Vec2_zero;
        
        //_panRaycastCallback = new PanRayCastCallback();
        
        debugLineEndPoint = CGPointZero;
        debugLineStartPoint = CGPointZero;
        
        raceTimer = 0.0f;
        acceptingInput = false;
                
        [self createBackground];
        
        [self startStartSequence];
		
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
	
	groundBox.Set(b2Vec2(0,0), b2Vec2(s.width/PTM_RATIO*SCREEN_WIDTHS,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// top
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO*SCREEN_LENGTHS), b2Vec2(s.width/PTM_RATIO*SCREEN_WIDTHS,s.height/PTM_RATIO*SCREEN_LENGTHS));
	groundBody->CreateFixture(&groundBox,0);
	
	// left
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO*SCREEN_LENGTHS), b2Vec2(0,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// right
	groundBox.Set(b2Vec2(s.width/PTM_RATIO*SCREEN_WIDTHS,s.height/PTM_RATIO*SCREEN_LENGTHS), b2Vec2(s.width/PTM_RATIO*SCREEN_WIDTHS,0));
	groundBody->CreateFixture(&groundBox,0);
    
    b2BodyDef endZoneSensorDef;
    endZoneSensorDef.type = b2_staticBody;
    //endZoneSensorDef.position.Set(0, s.height/PTM_RATIO*SCREEN_LENGTHS - s.height/PTM_RATIO*END_ZONE_SENSOR_SIZE);
    endZoneSensorDef.position.Set(s.width/PTM_RATIO*SCREEN_WIDTHS - s.width/PTM_RATIO*END_ZONE_SENSOR_SIZE/2.0,s.height/2.0);

    endZoneSensor = world->CreateBody(&endZoneSensorDef);
    
    b2PolygonShape shape;
    //shape.SetAsBox(s.width/PTM_RATIO * SCREEN_WIDTHS, s.height/PTM_RATIO * END_ZONE_SENSOR_SIZE);
    shape.SetAsBox(s.width/PTM_RATIO*END_ZONE_SENSOR_SIZE/2.0, s.height/2.0);
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
    fixtureDef.isSensor = true;
    fixtureDef.density = 0.0;
    
    endZoneSensor->CreateFixture(&fixtureDef);
    
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

-(void) createRocketMan:(CGPoint) location
{
    rocketMan = [[RocketMan3 alloc] initWithWorld:world atLocation:location];
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
    [self startStartSequence];
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    rocketMan.body->SetTransform( b2Vec2(screenSize.width/2/PTM_RATIO, screenSize.height/5/PTM_RATIO), -M_PI_2);
    rocketMan.body->SetLinearVelocity(b2Vec2_zero);
    rocketMan.body->SetAngularVelocity(0.0);
}

-(void) moveCameraToTarget2:(CGPoint) newTarget withDeltaTime:(float) dt;
{
    cameraTarget = newTarget;
    
    b2Vec2 currentPos = b2Vec2([self position].x/PTM_RATIO, [self position].y/PTM_RATIO);
    b2Vec2 nextPos = b2Vec2(cameraTarget.x/PTM_RATIO, cameraTarget.y/PTM_RATIO);
        
    // current velocity is the distance travelled during the current dt
    b2Vec2 currentVel = currentPos - lastCameraPos;
    currentVel.x /= dt;
    currentVel.y /= dt;
        
    //ma = Fspring - Fdrag
    //ma = kSpring*x - kDrag*vel
//    float kSpring = 1500.0f;
//    float kDrag = 250.0f;
//    float mass = 15.0f;
    float kSpring = 1200.0f;
    float kDrag = 300.0f;
    float mass = 15.0f;

    float FSpringX = (nextPos.x - currentPos.x)*kSpring;
    float FSpringY = (nextPos.y - currentPos.y)*kSpring;
    float FDragX = currentVel.x*kDrag;
    float FDragY = currentVel.y*kDrag;
    
    float xAcc = (FSpringX - FDragX)/mass;
    float yAcc = (FSpringY - FDragY)/mass;
    
    // the new velocity assumes the dt will be the same
    b2Vec2 nextVel = b2Vec2(currentVel.x + xAcc*dt, currentVel.y + yAcc*dt);
    
    // calculate the new position assuming the dt will be the same
    nextPos.x = currentPos.x + nextVel.x*dt;
    nextPos.y = currentPos.y + nextVel.y*dt;
        
    [self setPosition:ccp(nextPos.x*PTM_RATIO, nextPos.y*PTM_RATIO)];
    
    float xError = nextPos.x*PTM_RATIO-newTarget.x;
    float yError = nextPos.y*PTM_RATIO-newTarget.y;
    
    if ((xError != 0.0) || (yError != 0.0))
    {
        CCLOG(@"x error: %.2f\ny error: %.2f",xError, yError);
    }
    
    lastCameraPos = currentPos;
    lastCameraVel = currentVel;
}

#define CAMERA_MAX_VELOCITY 40.0
#define CAMERA_MAX_ACCELERATION 5000.0

-(void) moveCameraToTarget:(CGPoint) newTarget withDeltaTime:(float) dt;
{
    cameraTarget = newTarget;
    
    b2Vec2 currentPos = b2Vec2([self position].x/PTM_RATIO, [self position].y/PTM_RATIO);
    b2Vec2 nextPos = b2Vec2(cameraTarget.x/PTM_RATIO, cameraTarget.y/PTM_RATIO);
    
    //calculate the velocity and acceleration we are being asked to execute for next frame
    //(assume this frame's dt will be the same as the current dt)
    
    // current velocity is the distance travelled during the current dt
    b2Vec2 currentVel = currentPos - lastCameraPos;
    currentVel.x /= dt;
    currentVel.y /= dt;
    
    // the new velocity assumes the dt will be the same
    b2Vec2 nextVel = nextPos - currentPos;
    nextVel.x /= dt;
    nextVel.y /= dt;
    
    // calculate the new acceleration assuming the dt will be the same
    b2Vec2 nextAcc = nextVel - currentVel;
    nextAcc.x /= dt;
    nextAcc.y /= dt;
    
    BOOL recalcVel = FALSE;
    BOOL recalcPos = FALSE;
    
    double newAccMag = nextAcc.Normalize();
    
    // limit the acceleration if it's positive
    if ((nextAcc.x > 0) || (nextAcc.y > 0))
    {
        if (newAccMag > CAMERA_MAX_ACCELERATION)
        {
            recalcVel = TRUE;
            recalcPos = TRUE;
            CCLOG(@"Acc Limited: %.2f (%.2f)", newAccMag, CAMERA_MAX_ACCELERATION);
            newAccMag = CAMERA_MAX_ACCELERATION;
        }
    }
        
    nextAcc.x *= newAccMag;
    nextAcc.y *= newAccMag;
        
    if (recalcVel)
    {
        nextVel.x = currentVel.x + dt*nextAcc.x;
        nextVel.y = currentVel.y + dt*nextAcc.y;
    }
    
    double nextVelMag = nextVel.Normalize();
    if (nextVelMag > CAMERA_MAX_VELOCITY)
    {
        recalcPos = TRUE;
        CCLOG(@"Vel Limited: %.2f (%.2f)", nextVelMag, CAMERA_MAX_VELOCITY);
        nextVelMag = CAMERA_MAX_VELOCITY;
    }

    nextVel.x *= nextVelMag;
    nextVel.y *= nextVelMag;
    
    if (recalcPos)
    {
        nextPos.x = currentPos.x + dt*nextVel.x;
        nextPos.y = currentPos.y + dt*nextVel.y;
    }
/*    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    nextPos.x = MIN(0, nextPos.x);
    nextPos.x = MAX(nextPos.x,-winSize.width * (SCREEN_WIDTHS - 1));
    nextPos.y = MIN(nextPos.y,0);
    nextPos.y = MAX(nextPos.y,-winSize.height * (SCREEN_LENGTHS -1));
*/
        
    [self setPosition:ccp(nextPos.x*PTM_RATIO, nextPos.y*PTM_RATIO)];

    float xError = nextPos.x*PTM_RATIO-newTarget.x;
    float yError = nextPos.y*PTM_RATIO-newTarget.y;
    
    if ((xError != 0.0) || (yError != 0.0))
    {
        CCLOG(@"x error: %.2f\ny error: %.2f",xError, yError);
    }
    
    lastCameraPos = currentPos;
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

-(void) followRocketMan:(float) dt
{
    // calculate where we would like the camera to be
    CGSize winSize = [CCDirector sharedDirector].winSize;
    float newY = rocketMan.position.y - winSize.height*FIXED_POS_Y;
    float newX = rocketMan.position.x - winSize.width*FIXED_POS_X;
    newY = MAX(newY, 0);
    newY = MIN(newY, winSize.height * SCREEN_LENGTHS-winSize.height);

    newX = MAX(newX, 0);
    newX = MIN(newX, winSize.width * SCREEN_WIDTHS-winSize.width);
   
    CGPoint newPos = ccp(-newX, -newY);

//    [self moveCameraToTarget:newPos withDeltaTime:dt];
    [self moveCameraToTarget2:newPos withDeltaTime:dt];
    //[self moveCameraToTarget2:newPos withDeltaTime:dt];
    //[self updateCameraPosition:newPos];
}

-(void) followRocketMan2:(float) dt
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    
    b2Vec2 rocketVelocity = rocketMan.body->GetLinearVelocity();
    b2Vec2 rocketPosition = rocketMan.body->GetPosition();
    b2Vec2 forwardVector = rocketMan.body->GetWorldVector(b2Vec2(0.0f, 1.0f));

    //zero out the rocket velocity if it's not in +ve x
    if (rocketVelocity.x < 0.0f)
    {
        rocketVelocity.x = 0.0f;
    }
    
    //we want the camera to be ahead of the rocket's movement
    float speed = rocketVelocity.Normalize() * PTM_RATIO;;
/*
    float dotProduct = rocketVelocity.x * forwardVector.x + rocketVelocity.y * forwardVector.y;
    
    if (dotProduct > 0)
    {
        speed *= dotProduct;
    }
    else
    {
        speed = 0;
    }
*/    
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
    newX = MAX(newX,-winSize.width * (SCREEN_WIDTHS - 1));
    newY = MIN(newY,0);
    newY = MAX(newY,-winSize.height * (SCREEN_LENGTHS -1));
    
    CGPoint newPos = ccp(newX, newY);
    // limit velocity/acc
    //[self moveCameraToTarget:newPos withDeltaTime:dt];
    // do a force calculation
    //[self moveCameraToTarget2:newPos withDeltaTime:dt];
    // use a physics object for the camera
    [self updateCameraPosition:newPos];
    //try averagin the point
    //newPos.x = (newPos.x + [self position].x)/2.0f;
    //newPos.y = (newPos.y + [self position].y)/2.0f;
    //[self setPosition:newPos];
    
}

-(void) handlePan:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    
    //make sure the length is big enough, otherwise ignore
    b2Vec2 slashVector = b2Vec2((endPoint.x - startPoint.x)/PTM_RATIO, (endPoint.y - startPoint.y)/PTM_RATIO);
    if (slashVector.LengthSquared() < MIN_PAN_LENGTH_SQ)
    {
        //CCLOG(@"Pan too short %.2f vs %.2f", slashVector.LengthSquared(), MIN_PAN_LENGTH_SQ);         
        return;
    }
    else
    {
        //CCLOG(@"Pan good %.2f", slashVector.LengthSquared());
    }
    
    debugLineStartPoint = startPoint;
    debugLineEndPoint = endPoint;
    
    // give the rocked the parameters for the pan move
    // AP this is two functions in case I want to use collision detection to see if touch actually hits the 
    // rocket
    // CONVERT the points to meters before sending them to rocket 
    startPoint = ccpMult(startPoint, 1.0/PTM_RATIO);
    endPoint = ccpMult(endPoint, 1.0/PTM_RATIO);
    [rocketMan planPanMove:startPoint endPoint:endPoint];
    [rocketMan executePanMove];
    
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

    // this means the race is on
    if(acceptingInput)
    {
        raceTimer+=dt;
        timerString = [NSString stringWithFormat:@"%.2f", raceTimer];
    }
    
    [self followRocketMan2:dt];
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

-(bool) isAcceptingInput {return acceptingInput;}

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
