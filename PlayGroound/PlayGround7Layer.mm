//
//  PlayGround7Layer.mm
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "PlayGround7Scene.h"
#import "PlayGround7Layer.h"
// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#import "GameCharPhysics.h"

#import "SmashBallChain.h"
#import "SBBlock.h"

#import "GameManager.h"

#import "SimpleQueryCallback.h"

#define NUM_CHAINS 9
#define SCREEN_WIDTHS 3
#define CAMERA_X_OFFSET 0.3

enum {
	kTagParentNode = 1,
};


@interface PlayGround7Layer()
-(void) initPhysics;
@end

@implementation PlayGround7Layer

- (void) registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
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

-(void) createBackground {
    
//    CGSize winSize = [CCDirector sharedDirector].winSize;
}

-(void) createSmashBall: (CGPoint) location
{
    b2Vec2 loc = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    //create the smash ball
    smashBallMain = [[SmashBallMain alloc] initWithWorld:world atLocation:loc];
    [sceneSpriteBatchNode addChild:smashBallMain z:5];
    
    //create the first chain link
    loc.x = SBM_JOINT_OFFSET + SBC_JOINT_OFFSET;
    loc.y = 0.0f;
    loc = smashBallMain.body->GetWorldPoint(loc);
    SmashBallChain* chain = [[SmashBallChain alloc] initWithWorld:world atLocation:loc];
    b2RevoluteJointDef revJointDef;
    revJointDef.Initialize(smashBallMain.body, chain.body, smashBallMain.body->GetWorldPoint(b2Vec2(SBM_JOINT_OFFSET,0)));
    world->CreateJoint(&revJointDef);
    [sceneSpriteBatchNode addChild:chain z:5];
    [chain release];

    // create all remaining chains
    for (int i = 1; i < NUM_CHAINS; i++)
    {
        loc.x = SBC_JOINT_OFFSET*2.0;
        loc.y = 0.0f;
        loc = chain.body->GetWorldPoint(loc);
        SmashBallChain* nextChain = [[SmashBallChain alloc] initWithWorld:world atLocation:loc];
        revJointDef.Initialize(chain.body, nextChain.body, chain.body->GetWorldPoint(b2Vec2(SBC_JOINT_OFFSET,0)));
        world->CreateJoint(&revJointDef);
        [sceneSpriteBatchNode addChild:nextChain z:5];
        [nextChain release];
        chain = nextChain;
    }
    //create the end ball and link it to the third chain
    loc.x = SBC_JOINT_OFFSET + SBE_JOINT_OFFSET;
    loc.y = 0.0f;
    loc = chain.body->GetWorldPoint(loc);
    smashBallEnd = [[SmashBallEnd alloc] initWithWorld:world atLocation:loc];
    revJointDef.Initialize(chain.body, smashBallEnd.body, chain.body->GetWorldPoint(b2Vec2(SBC_JOINT_OFFSET,0)));
    world->CreateJoint(&revJointDef);

    [sceneSpriteBatchNode addChild:smashBallEnd z:5];
}

#define BLOCKS_WIDE 5
#define BLOCKS_HIGH 5
#define BLOCK_HORIZ_SPACE SBB_WIDTH*0.05
#define BLOCK_VERT_SPACE SBB_HEIGHT*0.05

-(void) createBlocks
{
    //for now just create a stack in the middle of the screen

    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    float startingX = winSize.width/2.0/PTM_RATIO - 0.5f*(BLOCKS_WIDE*SBB_WIDTH + (BLOCKS_WIDE - 1)*BLOCK_HORIZ_SPACE) + SBB_WIDTH/2.0;
    
    b2Vec2 loc = b2Vec2(startingX, SBB_HEIGHT/2.0);
    
    for (int i = 0; i < BLOCKS_HIGH; i++)
    {
        //create a row
        for (int j = 0; j < BLOCKS_WIDE; j++)
        {
            SBBlock* block = [[SBBlock alloc] initWithWorld:world atLocation:loc];
            [sceneSpriteBatchNode addChild:block z:4];
            [block release];
            loc.x += SBB_WIDTH + BLOCK_HORIZ_SPACE;
        }
        loc.y += SBB_HEIGHT + BLOCK_VERT_SPACE;
        loc.x = startingX;
    }
}

#define END_ZONE_SENSOR_RATIO 0.1

-(void) createEndZoneSensor
{
    CGSize s = [CCDirector sharedDirector].winSize;
    
    b2BodyDef endZoneSensorDef;
    endZoneSensorDef.type = b2_staticBody;
    
    float endZoneWidth = END_ZONE_SENSOR_RATIO * s.width/PTM_RATIO;

    endZoneSensorDef.position.Set(s.width/PTM_RATIO*SCREEN_WIDTHS - endZoneWidth/2.0,s.height/2.0/PTM_RATIO);
    
    endZoneSensor = world->CreateBody(&endZoneSensorDef);
    
    b2PolygonShape shape;
    shape.SetAsBox(endZoneWidth/2.0, s.height/2.0/PTM_RATIO);
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
    fixtureDef.isSensor = true;
    fixtureDef.density = 0.0;
    
    endZoneSensor->CreateFixture(&fixtureDef);
    
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
        
        [self createSmashBall:ccp(s.width/5.0, s.height/5.0)];
        
        [self createBlocks];
        
        [self createEndZoneSensor];
        
        [self createBackground];
		
		[self scheduleUpdate];
        
        blocksSmashed = 0;
        gameOver = false;
        
        label = [CCLabelTTF labelWithString:@"" fontName:@"Helvetica" fontSize:48.0];
        label.position = ccp(s.width/2, s.height/2);
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
	groundBody = world->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	b2EdgeShape groundBox;		
	
	// bottom
	
	groundBox.Set(b2Vec2(0,0), b2Vec2(s.width*SCREEN_WIDTHS/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// top
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(s.width*SCREEN_WIDTHS/PTM_RATIO,s.height/PTM_RATIO));
	groundBody->CreateFixture(&groundBox,0);
	
	// left
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(0,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// right
	groundBox.Set(b2Vec2(s.width*SCREEN_WIDTHS/PTM_RATIO,s.height/PTM_RATIO), b2Vec2(s.width*SCREEN_WIDTHS/PTM_RATIO,0));
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
    
    //ccDrawLine(debugLineStartPoint, debugLineEndPoint);
	
	kmGLPopMatrix();
}


-(void) handlePan:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{

}

-(void) handleTap:(CGPoint)tapPoint
{

}

-(void) handleRotation:(float)angleDelta
{

}

-(void) handleLongPress:(BOOL)continueFiring
{

}

-(void) updateCameraPosition
{
    CGPoint ballLocation = ccp(smashBallMain.body->GetPosition().x*PTM_RATIO, smashBallMain.body->GetPosition().y*PTM_RATIO);
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    float newX = ballLocation.x - CAMERA_X_OFFSET * winSize.width;
    newX = MAX(newX, 0);
    newX = MIN(newX, (SCREEN_WIDTHS - 1)*winSize.width);
    
    [self setPosition:ccp(-newX, 0.0f)];
    [label setPosition:ccp(newX + winSize.width/2.0,winSize.height/2.0)];
}

-(void) resetLevel:(id) sender
{
    [[GameManager sharedGameManager] runLevelWithID:kPlayGround7];
}

-(void) startGameOver
{
    gameOver = true;
    [self displayText:[NSString stringWithFormat:@"Blocks Smashed: %i", blocksSmashed] andOnCompleteCallTarget:self selector:@selector(resetLevel:)];    
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
    
    int32 velocityIterations = 50;
    int32 positionIterations = 50;
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
    
    CCArray *listOfObjectsToDestroy = [CCArray array];

    CCArray *listOfGameObjects = [sceneSpriteBatchNode children];
    for (GameChar *tempChar in listOfGameObjects)
    {
        [tempChar updateStateWithDeltaTime:dt];
        if ([tempChar gameObjType] == kObjTypeBlock)
        {
            GameCharPhysics *object = (GameCharPhysics*) tempChar;
            if (object.destroyMe == true)
            {
                [listOfObjectsToDestroy addObject:object];
            }
        }
    }    
    for (GameCharPhysics *tempChar in listOfObjectsToDestroy)
    {
        world->DestroyBody(tempChar.body);
        tempChar.body = NULL;
        [tempChar removeFromParentAndCleanup:YES];
        blocksSmashed++;
    }
    // check for endzone contact
    if (!gameOver)
    {
        b2ContactEdge *edge = endZoneSensor->GetContactList();
        while (edge)
        {
            b2Contact *contact = edge->contact;
            if (contact->IsTouching())
            {
                b2Fixture *fixtureA = contact->GetFixtureA();
                b2Fixture *fixtureB = contact->GetFixtureB();
                b2Body *bodyA = fixtureA->GetBody();
                b2Body *bodyB = fixtureB->GetBody();
            
                if ((bodyA == smashBallMain.body) || (bodyB == smashBallMain.body) ||
                    (bodyA == smashBallEnd.body) || (bodyB == smashBallEnd.body))
                {
                    [self startGameOver];
                }
            }
            edge = edge->next;
        }
    }    
    
    [self updateCameraPosition];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInView:[touch view]];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    b2Vec2 locationWorld = b2Vec2(touchLocation.x/PTM_RATIO, touchLocation.y/PTM_RATIO);
    
    b2AABB aabb;
    b2Vec2 delta = b2Vec2(1.0/PTM_RATIO, 1.0/PTM_RATIO);
    
    aabb.lowerBound = locationWorld - delta;
    aabb.upperBound = locationWorld + delta;
    
    SimpleQueryCallback callback(locationWorld);
    
    world->QueryAABB(&callback, aabb);
    
    if (callback.fixtureFound)
    {
        b2Body *body = callback.fixtureFound->GetBody();
        
        GameCharPhysics *sprite = (GameCharPhysics *) body->GetUserData();
        if (sprite == NULL) return FALSE;
        if (![sprite mouseJointAccept]) return FALSE;
        
        b2MouseJointDef mouseJointDef;
        mouseJointDef.bodyA = groundBody;
        mouseJointDef.bodyB = body;
        mouseJointDef.target = locationWorld;
        mouseJointDef.maxForce = 10000*body->GetMass();
        mouseJointDef.collideConnected = true;
        
        mouseJoint = (b2MouseJoint *) world->CreateJoint(&mouseJointDef);
        body->SetAwake(true);
        return YES;
    }
    
    return TRUE;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInView:[touch view]];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    b2Vec2 locationWorld = b2Vec2(touchLocation.x/PTM_RATIO, touchLocation.y/PTM_RATIO);
    if (mouseJoint)
    {
        mouseJoint->SetTarget(locationWorld);
    }
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (mouseJoint)
    {
        world->DestroyJoint(mouseJoint);
        mouseJoint = NULL;
    }
}

@end
