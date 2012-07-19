//
//  GameManager.h
//  PlayGroound
//
//  Created by alex on 12-07-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalConstants.h"
#import "SimpleAudioEngine.h"
#import "AudioContants.h"

@interface GameManager : NSObject
{
    LevelIDs currentLevel;
    
    // Variables to Track Audio Options
    BOOL isMusicON;
    BOOL isSoundEffectsON;

    // Added for audio
    BOOL hasAudioBeenInitialized;
    
    GameManagerSoundState managerSoundState;
    SimpleAudioEngine *soundEngine;
    
    // the list of sound names taken from the Plist
    NSMutableDictionary *listOfSoundEffectFiles;
    // build in conjunction with the list above, contains a loaded/not loaded flag
    NSMutableDictionary *soundEffectsState;
}

+(GameManager*)sharedGameManager;
-(void) runLevelWithID:(LevelIDs) levelID; 

@property (readwrite) GameManagerSoundState managerSoundState;
@property (nonatomic, retain) NSMutableDictionary *listOfSoundEffectFiles;
@property (nonatomic, retain) NSMutableDictionary *soundEffectsState;
@property (readwrite) BOOL isMusicON;
@property (readwrite) BOOL isSoundEffectsON;

-(void)setupAudioEngine;
//plays a sound effect.  The key and the file it plays are found in the Plist
//Returns an int to be used to stop the sound
-(ALuint)playSoundEffect:(NSString*)soundEffectKey;
//for looped sound effects
-(ALuint)playSoundEffectLooped:(NSString*)soundEffectKey;

//stop a sound effect using the id
-(void)stopSoundEffect:(ALuint)soundEffectID;
//play background music for the level ID
//AP: this is different than the lcc2d approach so we can store the music/level in a Plist
-(void)playBackgroundTrack:(LevelIDs)levelID;
-(void)stopBackgroundTrack;


@end
