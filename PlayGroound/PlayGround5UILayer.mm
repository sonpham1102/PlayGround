//
//  PlayGround5UILayer.m
//  PlayGroound
//
//  Created by alex on 12-07-30.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayGround5UILayer.h"
#import "PlayGround5Layer.h"
#import "GameManager.h"

//#define LOG_GESTURES

@implementation PlayGround5UILayer

// GESTURE SETUP FUNCTIONS
-(void) setUpPanGesture
{    
    panGestureRecognizer = [[CustomPanGesureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:panGestureRecognizer];
}

-(void) setUpTapGesture
{
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGestureRecognizer.delegate = self;
    tapGestureRecognizer.cancelsTouchesInView = FALSE;
    [self addGestureRecognizer:tapGestureRecognizer];
}

-(void) setUpLongPressGesture
{
    longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    longPressGestureRecognizer.delegate = self;
    [self addGestureRecognizer:longPressGestureRecognizer];  
}

-(void) setUpRotationGesture
{
    rotationsGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotationGesture:)];
    rotationsGestureRecognizer.delegate = self;
    [self addGestureRecognizer:rotationsGestureRecognizer];  
}

-(void) setUpTwoTouchPanGesture
{
    twoTouchPanGestureRecognizer = [[CustomPanGesureRecognizer alloc] initWithTarget:self action:@selector(handleTwoTouchPanGesture:)];
    twoTouchPanGestureRecognizer.delegate = self;
    twoTouchPanGestureRecognizer.minimumNumberOfTouches = 2;
    [self addGestureRecognizer:twoTouchPanGestureRecognizer];
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
            (rotationsGestureRecognizer.state != UIGestureRecognizerStateChanged) &&
            (twoTouchPanGestureRecognizer.state != UIGestureRecognizerStateBegan) &&
            (twoTouchPanGestureRecognizer.state != UIGestureRecognizerStateChanged))
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
#ifdef LOG_GESTURES
        CCLOG(@"Pan gesture started");
#endif
    }
    else if (aPanGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
#ifdef LOG_GESTURES
        CCLOG(@"Pan gesture moved");
#endif
    }
    else if (aPanGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        panEndPoint = [aPanGestureRecognizer locationInView:aPanGestureRecognizer.view];
        panEndPoint = [[CCDirector sharedDirector] convertToGL:panEndPoint];
        
        //tell the gameplay layer that a pan gesture was completed
        [gpLayer handlePan: panStartPoint endPoint:panEndPoint];
#ifdef LOG_GESTURES
        CCLOG(@"Pan ended");
#endif
    }  
}
/*
- (void)handlePanGesture2:(UIPanGestureRecognizer*)aPanGestureRecognizer
{
    CGPoint panPoint = [aPanGestureRecognizer locationInView:[aPanGestureRecognizer view]];
    panPoint = [[CCDirector sharedDirector] convertToGL:panPoint];
    
    if (aPanGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        // log the start point
        [gpLayer handlePanStart:panPoint];
#ifdef LOG_GESTURES
        CCLOG(@"Pan gesture started");
#endif
    }
    else if (aPanGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        [gpLayer handlePanMove:panPoint];

#ifdef LOG_GESTURES
        CCLOG(@"Pan gesture moved");
#endif
    }
    else if (aPanGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [gpLayer handlePanEnd:panPoint];
        
#ifdef LOG_GESTURES
        CCLOG(@"Pan ended");
#endif
    }  
}
*/
 
- (void)handleTapGesture:(UITapGestureRecognizer*)aTapGestureRecognizer
{
    if (aTapGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
#ifdef LOG_GESTURES
        CCLOG(@"Tap started");
#endif
    }
    else if (aTapGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint tapPoint = [aTapGestureRecognizer locationInView:aTapGestureRecognizer.view];
        tapPoint = [[CCDirector sharedDirector] convertToGL:tapPoint];
        
        //tell the gameplay layer that a tap gesture was completed
        [gpLayer handleTap: tapPoint];
#ifdef LOG_GESTURES
        CCLOG(@"Tap ended");
#endif        
    }    
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer*)aLongPressGestureRecognizer
{
    CGPoint lpPoint = [aLongPressGestureRecognizer locationInView:aLongPressGestureRecognizer.view];
    lpPoint = [[CCDirector sharedDirector] convertToGL:lpPoint];
    
    if (aLongPressGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
#ifdef LOG_GESTURES
        CCLOG(@"Long Press started");
#endif        
        [gpLayer handleLongPressStart:lpPoint];
    }
    else if (aLongPressGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
#ifdef LOG_GESTURES
        CCLOG(@"Long Press moved");
#endif
        [gpLayer handleLongPressMove:lpPoint];
    }
    else if (aLongPressGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
#ifdef LOG_GESTURES
        CCLOG(@"Long Press ended");
#endif
        [gpLayer handleLongPressEnd:lpPoint];
    }
    else if (aLongPressGestureRecognizer.state == UIGestureRecognizerStateCancelled)
    {
#ifdef LOG_GESTURES
        CCLOG(@"Long Press cancelled");
#endif
        [gpLayer handleLongPressEnd:lpPoint];        
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
        // if a two touch pan gesture is in progress, kill it
        if ((twoTouchPanGestureRecognizer.state == UIGestureRecognizerStateBegan) ||
            (twoTouchPanGestureRecognizer.state == UIGestureRecognizerStateChanged))
        {
            twoTouchPanGestureRecognizer.enabled = NO;
            twoTouchPanGestureRecognizer.enabled = YES;
        }
        
#ifdef LOG_GESTURES        
        CCLOG(@"Rotation started");
#endif
        //store the angle that we started at
        rotStartingAngle = aRotationGestureRecognizer.rotation;
    }
    else if (aRotationGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
#ifdef LOG_GESTURES
        CCLOG(@"Rotation moved");
#endif
    }
    else if (aRotationGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        float rotationDelta = aRotationGestureRecognizer.rotation - rotStartingAngle;
        [gpLayer handleRotation:rotationDelta];
#ifdef LOG_GESTURES
        CCLOG(@"Rotation ended");
#endif
    }    
}

- (void)handleTwoTouchPanGesture:(CustomPanGesureRecognizer*)aTwoTouchPanGestureRecognizer
{
    CGPoint centroidPoint = [aTwoTouchPanGestureRecognizer locationInView:aTwoTouchPanGestureRecognizer.view];
    centroidPoint = [[CCDirector sharedDirector] convertToGL:centroidPoint];
    CGPoint panVelocity = [aTwoTouchPanGestureRecognizer velocityInView:aTwoTouchPanGestureRecognizer.view];
    panVelocity = [[CCDirector sharedDirector] convertToGL:panVelocity];
    
    if (aTwoTouchPanGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        //if a panGesture is in progress, kill it
        if ((panGestureRecognizer.state == UIGestureRecognizerStateBegan) ||
            (panGestureRecognizer.state == UIGestureRecognizerStateChanged))
        {
            panGestureRecognizer.enabled = NO;
            panGestureRecognizer.enabled = YES;
        }
#ifdef LOG_GESTURES
        CCLOG(@"Two Touch Pan started");
#endif        
    }
    else if (aTwoTouchPanGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
#ifdef LOG_GESTURES
        CCLOG(@"Two Touch Pan moved");
#endif
    }
    else if (aTwoTouchPanGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
#ifdef LOG_GESTURES
        CCLOG(@"Two Touch Pan ended");
#endif
        [gpLayer handleTwoTouchPan:centroidPoint withVelocity:panVelocity];
    }
    else if (aTwoTouchPanGestureRecognizer.state == UIGestureRecognizerStateCancelled)
    {
#ifdef LOG_GESTURES
        CCLOG(@"Two Touch Pan cancelled");
#endif      
    }
}
//////////////////////////


-(id) initWithGameplayLayer:(PlayGround5Layer *)gameplayLayer;
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
        [self setUpTwoTouchPanGesture];
        
        // this should give the tap the best chance of being recognized before the pan
        [panGestureRecognizer requireGestureRecognizerToFail:tapGestureRecognizer];

//        CGSize s = [CCDirector sharedDirector].winSize;
    }
    return self;
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

 	// Reset Button
	CCMenuItemLabel *reset = [CCMenuItemFont itemWithString:@"Reset" block:^(id sender)
                                 {
                                     [[GameManager sharedGameManager] runLevelWithID:kPlayGround5];
                                 }];
    [reset setScale:0.75f];    
    
    
    
    CCMenu *menu = [CCMenu menuWithItems:mainMenu, reset, nil];
    	
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
    [twoTouchPanGestureRecognizer release];
    
    [super dealloc];
}



@end
