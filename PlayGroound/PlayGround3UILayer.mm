//
//  PlayGround3UILayer.m
//  PlayGroound
//
//  Created by alex on 12-07-30.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayGround3UILayer.h"
#import "PlayGround3Layer.h"
#import "GameManager.h"

@implementation PlayGround3UILayer

// GESTURE SETUP FUNCTIONS
-(void) setUpPanGesture
{    
    panGestureRecognizer = [[CustomPanGesureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:panGestureRecognizer];
    //[panGestureRecognizer release];

    panEndPoint = CGPointZero;
    panStartPoint = CGPointZero;
    
    tapPoint = CGPointZero;
}

-(void) setUpTapGesture
{
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGestureRecognizer.delegate = self;
    tapGestureRecognizer.cancelsTouchesInView = FALSE;
    [self addGestureRecognizer:tapGestureRecognizer];
    //[tapGestureRecognizer release];
    
    tapPoint = CGPointZero;  
}

-(void) setUpLongPressGesture
{
    longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    longPressGestureRecognizer.delegate = self;
    [self addGestureRecognizer:longPressGestureRecognizer];
    //[longPressGestureRecognizer release];    
}

-(void) setUpRotationGesture
{
    rotationsGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotationGesture:)];
    rotationsGestureRecognizer.delegate = self;
    [self addGestureRecognizer:rotationsGestureRecognizer];
    //[rotationsGestureRecognizer release];    
}

// DELEGATE FUNCTIONS - allow finer control of touch behaviour
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //if this is the pan gesture recognizer, don't send it touches if the long Press is handling it
    if (gestureRecognizer == panGestureRecognizer)
    {
        if ((longPressGestureRecognizer.state != UIGestureRecognizerStateBegan) &&
            (longPressGestureRecognizer.state != UIGestureRecognizerStateChanged) &&
            (rotationsGestureRecognizer.state != UIGestureRecognizerStateBegan) &&
            (rotationsGestureRecognizer.state != UIGestureRecognizerStateChanged))
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    return YES;
}

-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{    
    if (gestureRecognizer == panGestureRecognizer)
    {
/*
        if ((longPressGestureRecognizer.state != UIGestureRecognizerStateFailed) &&
            (longPressGestureRecognizer.state != UIGestureRecognizerStateEnded) &&
            (longPressGestureRecognizer.state != UIGestureRecognizerStateRecognized) &&
            (longPressGestureRecognizer.state != UIGestureRecognizerStateCancelled))
        {
            return NO;
        }
        else
        {
            return YES;
        }
*/
    }
    return YES;
}

-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{    
    //see if we are talking about the tap recognizer and the pan recognizer
    if ((gestureRecognizer == tapGestureRecognizer) || (otherGestureRecognizer == tapGestureRecognizer))
    {
        if ((gestureRecognizer == panGestureRecognizer) || (otherGestureRecognizer == panGestureRecognizer))
        {
            if ((panGestureRecognizer.state == UIGestureRecognizerStateCancelled) ||
                (panGestureRecognizer.state == UIGestureRecognizerStateEnded) ||
                (panGestureRecognizer.state == UIGestureRecognizerStateFailed))
            {
                return YES;
            }
            else
            {
                return NO;
            }            
        }
        else if ((gestureRecognizer == longPressGestureRecognizer) || (otherGestureRecognizer == longPressGestureRecognizer))
        {
            if ((longPressGestureRecognizer.state == UIGestureRecognizerStateCancelled) ||
                (longPressGestureRecognizer.state == UIGestureRecognizerStateEnded) ||
                (longPressGestureRecognizer.state == UIGestureRecognizerStateFailed))
            {
                return YES;
            }
            else
            {
                return NO;
            }            
            
        }
    }
    if ((gestureRecognizer == rotationsGestureRecognizer) || (otherGestureRecognizer == rotationsGestureRecognizer))
    {
        if ((gestureRecognizer == longPressGestureRecognizer) || (otherGestureRecognizer == longPressGestureRecognizer))
        {
            if ((longPressGestureRecognizer.state == UIGestureRecognizerStateCancelled) ||
                (longPressGestureRecognizer.state == UIGestureRecognizerStateEnded) ||
                (longPressGestureRecognizer.state == UIGestureRecognizerStateFailed))
            {
                return YES;
            }
            else
            {
                return NO;
            }            
            
        }
    }
    return YES;
}

// GESTURE HANDLERS
- (void)handlePanGesture:(UIPanGestureRecognizer*)aPanGestureRecognizer
{
    if (aPanGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        // log the start point
        panStartPoint = [aPanGestureRecognizer locationInView:[aPanGestureRecognizer view]];
        panStartPoint = [[CCDirector sharedDirector] convertToGL:panStartPoint];
        //AP : Need to subtract any movement of the view
        //panStartPoint.x -= [self position].x;
        //panStartPoint.y -= [self position].y;
        //CCLOG(@"Pan started");
    }
    else if (aPanGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        //CCLOG(@"Pan gesture moved");
    }
    else if (aPanGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        panEndPoint = [aPanGestureRecognizer locationInView:aPanGestureRecognizer.view];
        panEndPoint = [[CCDirector sharedDirector] convertToGL:panEndPoint];
        
        //tell the gameplay layer that a pan gesture was completed
        [gpLayer handlePan: panStartPoint endPoint:panEndPoint];
        //CCLOG(@"Pan ended");
    }  
}

- (void)handleTapGesture:(UITapGestureRecognizer*)aTapGestureRecognizer
{
    if (aTapGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        //CCLOG(@"Tap started");
    }
    else if (aTapGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        tapPoint = [aTapGestureRecognizer locationInView:aTapGestureRecognizer.view];
        tapPoint = [[CCDirector sharedDirector] convertToGL:tapPoint];
        
        //tell the gameplay layer that a tap gesture was completed
        [gpLayer handleTap: tapPoint];
        //CCLOG(@"Tap ended");
    }    
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer*)aLongPressGestureRecognizer
{
    if (aLongPressGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        //CCLOG(@"Long Press started");
        [gpLayer handleLongPress:TRUE];
    }
    else if (aLongPressGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        //CCLOG(@"Long Press moved");
    }
    else if (aLongPressGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        //CCLOG(@"Long Press ended");
        [gpLayer handleLongPress:FALSE];
    }
    else if (aLongPressGestureRecognizer.state == UIGestureRecognizerStateCancelled)
    {
        //CCLOG(@"Long Press cancelled");
        [gpLayer handleLongPress:FALSE];        
    }
}

- (void)handleRotationGesture:(UIRotationGestureRecognizer*)aRotationGestureRecognizer
{
    if (aRotationGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        //if a panGesture is in progress, kill it
        if ((panGestureRecognizer.state == UIGestureRecognizerStateBegan) ||
            (panGestureRecognizer.state == UIGestureRecognizerStateChanged))
        {
            panGestureRecognizer.enabled = NO;
            panGestureRecognizer.enabled = YES;
        }
        
        //CCLOG(@"Rotation started");
        //store the angle that we started at
        rotStartingAngle = aRotationGestureRecognizer.rotation;
    }
    else if (aRotationGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        //CCLOG(@"Rotation moved");
        float rotationDelta = aRotationGestureRecognizer.rotation - rotStartingAngle;
        [gpLayer handleRotation:rotationDelta];
        rotStartingAngle = aRotationGestureRecognizer.rotation;
    }
    else if (aRotationGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [gpLayer handleRotation:0.0f];
        //CCLOG(@"Rotation ended");
    }    
}

-(id) initWithGameplayLayer:(PlayGround3Layer *)gameplayLayer;
{
    if( (self=[super init]))
    {
        [self createMenu];
        gpLayer = gameplayLayer;
        self.isTouchEnabled = YES;

        [self setUpPanGesture];
        [self setUpTapGesture];
        [self setUpLongPressGesture];
        [self setUpRotationGesture];
        
        // this should give the tap the best chance of being recognized before the pan
        [panGestureRecognizer requireGestureRecognizerToFail:tapGestureRecognizer];

        isGPLayerAcceptingInput = false;
        
        //start gesture disabled
        panGestureRecognizer.enabled = false;
        tapGestureRecognizer.enabled = false;
        longPressGestureRecognizer.enabled = false;
        rotationsGestureRecognizer.enabled = false;
                
        CGSize s = [CCDirector sharedDirector].winSize;
        
        timerLabel = [CCLabelTTF labelWithString:@"Tap screen" fontName:@"Marker Felt" fontSize:32];
		[self addChild:timerLabel z:0];
		[timerLabel setColor:ccc3(0,0,255)];
        timerLabel.position = ccp(s.width-50, s.height/2);
        timerLabel.rotation = 90.0;
        bestTimeLabel = [CCLabelTTF labelWithString:@"--.--" fontName:@"Marker Felt" fontSize:32];
		[self addChild:bestTimeLabel z:0];
		[bestTimeLabel setColor:ccc3(0,255,0)];
        bestTimeLabel.position = ccp(s.width-100, s.height/2);
        bestTimeLabel.rotation = 90.0;
        
        [self scheduleUpdate];
    }
    return self;
}

-(void) update: (ccTime) dt
{
    //see if the gpLayer has stopped/started accepting input
    if (isGPLayerAcceptingInput && ![gpLayer isAcceptingInput])
    {
       //disable the gesture recognizers
        panGestureRecognizer.enabled = false;
        tapGestureRecognizer.enabled = false;
        longPressGestureRecognizer.enabled = false;
        rotationsGestureRecognizer.enabled = false;
        isGPLayerAcceptingInput = false;
    }
    else if (!isGPLayerAcceptingInput && [gpLayer isAcceptingInput])
    {
        panGestureRecognizer.enabled = true;
        tapGestureRecognizer.enabled = true;
        longPressGestureRecognizer.enabled = true;
        rotationsGestureRecognizer.enabled = true; 
        isGPLayerAcceptingInput = true;
    }
    //get the string for the timer label from the gp layer
    [timerLabel setString:[gpLayer getTimerString]];
    [bestTimeLabel setString:[gpLayer getBestTimeString]];
}

-(void) createMenu
{
	// Default font size will be 22 points.
	[CCMenuItemFont setFontSize:22];
	
	// Main Menu Button
	CCMenuItemLabel *mainMenu = [CCMenuItemFont itemWithString:@"Main Menu" block:^(id sender)
                              {
                                  [[GameManager sharedGameManager] runLevelWithID:kMainMenu];
                              }];
    [mainMenu setScale:0.75f];

	// reset Button
	CCMenuItemLabel *reset = [CCMenuItemFont itemWithString:@"Reset" block:^(id sender)
                                 {
                                     [[GameManager sharedGameManager] runLevelWithID:kPlayGround3];
                                 }];
    [reset setScale:0.75f];

	// switch level Button
	CCMenuItemLabel *nextLevel = [CCMenuItemFont itemWithString:@"Next" block:^(id sender)
                              {
                                  int currentLevel = [GameManager sharedGameManager].PG3Level;
                                  currentLevel++;
                                  if (currentLevel > 4)
                                  {
                                      currentLevel = 1;
                                  }
                                  [GameManager sharedGameManager].PG3Level = currentLevel;
                                  [[GameManager sharedGameManager] runLevelWithID:kPlayGround3];
                              }];
    [nextLevel setScale:0.75f];
    
    
    CCMenu *menu = [CCMenu menuWithItems:mainMenu, reset, nextLevel, nil];
    	
	[menu alignItemsVertically];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	[menu setPosition:ccp( size.width*0.9, size.height*0.95)];	
	
	[self addChild: menu z:-1];	
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
	    
    //ccDrawLine(panStartPoint, panEndPoint);
	
	kmGLPopMatrix();
}

-(void) dealloc
{
    [tapGestureRecognizer release];
    [panGestureRecognizer release];
    [longPressGestureRecognizer release];
    [rotationsGestureRecognizer release];
    
    [super dealloc];
}



@end
