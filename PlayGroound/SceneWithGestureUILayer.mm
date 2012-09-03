//
//  SceneWithGestureUILayer.m
//  PlayGroound
//
//  Created by alex on 12-07-30.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SceneWithGestureUILayer.h"
#import "SceneWithGestureLayer.h"
#import "GameManager.h"

#define LOG_GESTURES

@implementation SceneWithGestureUILayer

// GESTURE SETUP FUNCTIONS
-(void) setUpPanGesture
{    
    panGestureRecognizer = [[CustomPanGesureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:panGestureRecognizer];

    panEndPoint = CGPointZero;
    panStartPoint = CGPointZero;
}

-(void) setUpTapGesture
{
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGestureRecognizer.delegate = self;
    tapGestureRecognizer.cancelsTouchesInView = FALSE;
    [self addGestureRecognizer:tapGestureRecognizer];
    
    tapPoint = CGPointZero;  
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
        tapPoint = [aTapGestureRecognizer locationInView:aTapGestureRecognizer.view];
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
    if (aLongPressGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
#ifdef LOG_GESTURES
        CCLOG(@"Long Press started");
#endif
        [gpLayer handleLongPress:TRUE];
    }
    else if (aLongPressGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
#ifdef LOG_GESTURES
        CCLOG(@"Long Press moved");
#endif
    }
    else if (aLongPressGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
#ifdef LOG_GESTURES
        CCLOG(@"Long Press ended");
#endif
        [gpLayer handleLongPress:FALSE];
    }
    else if (aLongPressGestureRecognizer.state == UIGestureRecognizerStateCancelled)
    {
#ifdef LOG_GESTURES
        CCLOG(@"Long Press cancelled");
#endif
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
        float rotationDelta = aRotationGestureRecognizer.rotation - rotStartingAngle;
        [gpLayer handleRotation:rotationDelta];
        rotStartingAngle = aRotationGestureRecognizer.rotation;
    }
    else if (aRotationGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [gpLayer handleRotation:0.0f];
#ifdef LOG_GESTURES
        CCLOG(@"Rotation ended");
#endif
    }    
}

-(id) initWithGameplayLayer:(SceneWithGestureLayer *)gameplayLayer;
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
/*
        //start gesture disabled
        panGestureRecognizer.enabled = false;
        tapGestureRecognizer.enabled = false;
        longPressGestureRecognizer.enabled = false;
        rotationsGestureRecognizer.enabled = false;
*/                
        CGSize s = [CCDirector sharedDirector].winSize;
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
    
    CCMenu *menu = [CCMenu menuWithItems:mainMenu, nil];
    	
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
