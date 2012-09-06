//
//  PlayGround5Layer.h
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "GunBot.h"

#define PTM_RATIO (IS_IPAD() ? (8.0*1024.0/480.0) : 8.0)

@interface PlayGround5Layer : CCLayer
{
	CCTexture2D *spriteTexture_;	// weak ref
	b2World* world;					// strong ref
	GLESDebugDraw *m_debugDraw;		// strong ref
    
    CCSpriteBatchNode *sceneSpriteBatchNode;
    
    GunBot* gunBot;
    bool lpStarted;
    
    CCLabelTTF *label;
    
    int enemySpawnTarget;
    float timePerEnemy;
    bool isCreatingWave;
    int currentWaveNumber;
    int enemiesAllocated;
    
    int leftGateTarget;
    int leftGateCount;
    int topGateTarget;
    int topGateCount;
    int rightGateTarget;
    int rightGateCount;
    int bottomGateTarget;
    int bottomGateCount;
    float leftGateTimer;
    float rightGateTimer;
    float topGateTimer;
    float bottomGateTimer;
    
    bool isReadyToSpawn;
    
    bool gameOver;
}

-(void) handlePan:(CGPoint) startPoint endPoint:(CGPoint) endPoint;
-(void) handleTap:(CGPoint) tapPoint;
-(void) handleRotation:(float) angleDelta;
-(void) handleLongPressStart:(CGPoint) point;
-(void) handleLongPressMove:(CGPoint) point;
-(void) handleLongPressEnd:(CGPoint) point;

@end

