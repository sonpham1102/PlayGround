//
//  PlayGround1UILayer.m
//  PlayGroound
//
//  Created by alex on 12-07-30.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayGround1UILayer.h"
#import "PlayGround1Layer.h"
#import "GameManager.h"


@implementation PlayGround1UILayer

-(void) setUpPanGesture
{
    self.isTouchEnabled = YES;
    
    UIPanGestureRecognizer* panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:panGestureRecognizer];
    [panGestureRecognizer release];
    
    panEndPoint = CGPointZero;
    panStartPoint = CGPointZero;
}

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
    }
    else if (aPanGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        panEndPoint = [aPanGestureRecognizer locationInView:aPanGestureRecognizer.view];
        panEndPoint = [[CCDirector sharedDirector] convertToGL:panEndPoint];

        //tell the gameplay layer that a pan gesture was completed
        [gpLayer handlePan: panStartPoint endPoint:panEndPoint];
    }    
}

-(id) initWithGameplayLayer:(PlayGround1Layer *)gameplayLayer;
{
    if( (self=[super init]))
    {
        [self createMenu];
        gpLayer = gameplayLayer;
        [self setUpPanGesture];
    }
    return self;
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
    [reset setScale:0.75f];

    CCMenu *menu = [CCMenu menuWithItems:reset, nil];
    	
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
	    
    ccDrawLine(panStartPoint, panEndPoint);
	
	kmGLPopMatrix();
}



@end
