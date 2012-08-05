//
//  PlayGround2Layer.h
//  PlayGroound
//
//  Created by Jason Parlour on 12-07-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



#import <GameKit/GameKit.h>
#import "GlobalConstants.h"
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "Rocket.h"
#import "SimpleAudioEngine.h"
#import <CoreMotion/CoreMotion.h>
#import "bullet.h"


// HelloWorldLayer
@interface PlayGround2Layer : CCLayer <PlayGround2LayerDelegate>
{
    Rocket *rocket;
	CCTexture2D *spriteTexture_;	// weak ref
	b2World* world;                 // strong ref
    b2Body* mainBody;
	GLESDebugDraw *m_debugDraw;		// strong ref
    CCTMXTiledMap *tileMapNode;
    
    UITouch* touchLeft;
    UITouch* touchRight;
    UITouch* touchMiddle;
    
    //HACK I'm not sure that the rocked sounds should be handled by the layer
    //it would make more sense to be in the Rocket
    //ALuint leftRocketSoundID;
    //ALuint rightRocketSoundID;
    ALuint leftRocketSoundID;
    ALuint rightRocketSoundID;
    ALuint middleRocketSoundID;
    
    CCParallaxNode *parallaxNode;
    
    float32 asteroidTimer;
    int asteroidsCreated;
    
    CMMotionManager *motionManager;
    CCLabelBMFont *debugLabel;
    CMAttitude *referenceAttitude;
    
    int bulletCount;
    int turn;
    CGPoint cameraTarget;
    float bulletTime;
    b2Vec2 cameraMoveVector;
    float cameraDistanceToTarget;
    float cameraDistanceTravelled;
    CCSpriteBatchNode *sceneSpriteBatchNode;
    int loopCount;

}

@property (nonatomic,retain) CMMotionManager *motionManager;
@property (nonatomic,assign) CCLabelBMFont *debugLabel;

@end
