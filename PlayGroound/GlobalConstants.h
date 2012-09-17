//
//  GlobalConstants.h
//  PlayGroound
//
//  Created by alex on 12-07-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

// ONLY constants needed by all levels should go in here
//#import "Box2D.h"

#ifndef PlayGroound_GlobalConstants_h
#define PlayGroound_GlobalConstants_h


//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
//#define PTM_RATIO (IS_IPAD() ? (32.0*1024.0/480.0) : 32.0)

// Used by the GameManager to know which scene (level) to switch to
// Following the lcc2d example, 0 = no level, and menu's all have id's under 100
// The reason for the menu ID range is so that the game manager can check if the level is a menu level or not
// (because if does some screen scaling for menu's
typedef enum
{
    kLevelUnitialized = 0,
    kMainMenu = 1,
    kOptionsMenu = 2,
    kPlayGround1 = 100,
    kPlayGround2 = 120,
    kPlayGround3 = 140,
    kPlayGround4 = 160,
    kPlayGround5 = 180,
    kPlayGround6 = 200,
    kPlayGround7 = 220
} LevelIDs;

// GameObj types
typedef enum {
    kObjTypeRocket,
    kObjTypeObstacle,
    kObjTypeNone,
    kObjTypeAsteroid,
    kObjTypeBullet,
    kObjTypeMissle,
    kObjTypeGravityWell,
    kObjTypeTurboPad,
    kObjTypeBounceTriangle,
    kObjTypeObstacleBlock,
    kObjTypeGunBot,
    kObjTypeEnemy,
    kObjTypePaddle,
    kObjTypeBall,
    kObjTypeBlock,
}GameObjType;

// GameChar states
typedef enum {
    kStateSpawning,
    kStateIdle,
    kStateManeuver
}CharStates;

// PG5Collision categories and masks
typedef enum {
    kCollCatGunBot = 0x0001,
    kCollCatEnemy = 0x0002,
    kCollCatBullet = 0x0004,
    kCollCatWall = 0x0008,
    // the gunbot can collide with everything except bullets
    kCollMaskGunBot = 0x000A,
    kCollMaskEnemy = 0x0007,
    kCollMaskBullet = 0x000A,
    kCollMaskWall = 0x0005
} PG5CollFilters;

// PG7Collision categories and masks
typedef enum {
    kCollCatSBM = 0x0001,
    kCollMaskSBM = 0x000D,
    kCollCatSBC = 0x0002,
    kCollMaskSBC = 0x0000,
    kCollCatSBE = 0x0004,
    kCollMaskSBE = 0x000D,
    kCollCatSBB = 0x0008,
    kCollMaskSBB = 0x000D
} PG7CollFilters;


@protocol PlayGround2LayerDelegate

-(void) createBullet:(ccTime)deltaTime withTarget:(CGPoint)bulletTarget withVelocity:(CGPoint)targetVelocity;
-(void) decrementBulletCount;
-(void) addParticleEffect:(CCParticleSystemQuad*)effect;
-(void) createExplosionAtLocation:(CGPoint)location;
-(void) decrementMissleCount;
-(void) switchWeapons;
-(void) addAsteroidDestroyed;
-(void) decrementAsteroidCount;
@end

@protocol PlayGround4LayerDelegate

-(CGPoint) getLeftTouchPos;
-(CGPoint) getRightTouchPos;

@end


// A macro to determine if iPad or not
#ifdef UI_USER_INTERFACE_IDIOM//()
#define IS_IPAD() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#else
#define IS_IPAD() (NO)
#endif

#endif