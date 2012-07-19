//
//  GameManager.m
//  PlayGroound
//
//  Created by alex on 12-07-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameManager.h"
#import "cocos2d.h"
#import "MainMenuScene.h"
#import "IntroLayer.h"
#import "PlayGround1Scene.h"
#import "PlayGround2Scene.h"


@implementation GameManager
//the shared gamemanager variable, returned anytime anyone calls [GameManager sharedGameManager]
//static and starts as nil
static GameManager* _sharedGameManager = nil;

//used for sound files
@synthesize managerSoundState;
@synthesize listOfSoundEffectFiles;
@synthesize soundEffectsState;

//creates the _sharedGameManager (if necessary) and returns a pointer to it
+(GameManager*) sharedGameManager
{
    // the @synchronize directive is used to threadlock this code I think, to prevent multiple threads from trying
    // to create the singleton
    @synchronized ([GameManager class])
    {
        if (!_sharedGameManager)
        {
            [[self alloc] init];
        }
        return _sharedGameManager;
    }
}

+(id) alloc
{
    @synchronized ([GameManager class])
    {
        NSAssert(_sharedGameManager == nil, @"Trying to instantiate a second game manager");
        _sharedGameManager = [super alloc];
        return _sharedGameManager;
    }
    // AP: not sure how this line would ever get called, took it from lcc2d example
    return nil;
}

-(id) init
{
    self = [super init];
    if (self != nil)
    {
        CCLOG(@"Game Manager initialized");
        currentLevel = kLevelUnitialized;
        hasAudioBeenInitialized = NO;
        soundEngine = nil;
        managerSoundState = kAudioManagerUninitialized;
    }
    return self;
}

//////////////////
// SOUND FUNCTIONS
//////////////////

-(void) setupAudioEngine
{
    if (hasAudioBeenInitialized == YES)
    {
        return;
    }
    else
    {
        hasAudioBeenInitialized = YES;
        
        //Not sure about how all this works, but it's to set up the audio engine in another thread
        /* From the book
        The next few lines set up NSOperationQueue and NSInvocationOperation to run the contents of the initAudioAsync method in another thread. This means that as soon as asynchSetupOperation is added to the queue, it starts running in the background and this method returns. This allows the game logic to continue while the audio engine is being initialized and the audio preloaded in the background.
        */
        NSOperationQueue *queue = [[NSOperationQueue new] autorelease];
        NSInvocationOperation *asyncAudioSetupOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(initAudioAsync) object:nil];
        
        [queue addOperation:asyncAudioSetupOperation];
        [asyncAudioSetupOperation autorelease];
    }
}

//AP: copied from SpaceViking, heavily commented already
-(void) initAudioAsync
{
    //init audio engine asynchronously
    
    managerSoundState = kAudioManagerInitializing;
    
    [CDSoundEngine setMixerSampleRate:CD_SAMPLE_RATE_MID];
    
    //the FXPlusMusicIfNoOtherAudio mode will check if the user is playing music and disable background music playback
    [CDAudioManager initAsynchronously:kAMM_FxPlusMusicIfNoOtherAudio];
    
    //wait for the audio manager to initialize
    while ([CDAudioManager sharedManagerState] != kAMStateInitialised)
    {
        [NSThread sleepForTimeInterval:0.1];
    }
    
    //at this point cocosdenshion should be intitialized
    // grab the audio manager and check the state
    CDAudioManager *audioManager = [CDAudioManager sharedManager];
    if (audioManager.soundEngine == nil || audioManager.soundEngine.functioning == NO)
    {
        CCLOG(@"CocosDenshion failed to init, no audio will play");
        managerSoundState = kAudioManagerFailed;
    }
    else
    {
        [audioManager setResignBehavior:kAMRBStopPlay autoHandle:YES];
        soundEngine = [SimpleAudioEngine sharedEngine];
        managerSoundState = kAudioManagerReady;
        CCLOG(@"CocosDenshion is ready");
    }
}

// Used to convert the level ID to a string, needed when reading in the dictionaries to get the right
// mini dictionary
- (NSString*)formatSceneTypeToString:(LevelIDs)levelID
{
    NSString *result = nil;
    switch(levelID)
    {
        case kLevelUnitialized:
            result = @"kLevelUnitialized";
            break;
        case kMainMenu:
            result = @"kMainMenu";
            break;
        case kPlayGround1:
            result = @"kPlayGround1";
            break;
        case kPlayGround2:
            result = @"kPlayGround2";
            break;
        default:
            [NSException raise:NSGenericException format:@"UnHandled Level ID for audio"];
            break;
    }
    return result;
}

// Copied from spaceviking with some minor changes and more comments
-(NSDictionary*)getSoundEffectsListForLevelWithID:(LevelIDs) levelID
{
    // the SoundEffects plist contains the list of effects per level
    NSString *fullFileName = @"SoundEffects.plist";
    NSString *plistPath;
    
    //get the path to the plist file - looks like Boiler Plate code to me
    NSString *rootPath =
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath])
    {
        plistPath = [[NSBundle mainBundle] pathForResource:@"SoundEffects" ofType:@"plist"];
    }
    
    //read the plist
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    //if the plist is null, the file was not found
    if (plistDictionary == nil)
    {
        CCLOG(@"Error reading SoundEffects.plist");
        return nil;
    }
    
    //First create a full list of sound effects.  This just contains the ID/name pair for each sound
    // (I think)
    //if the list of soundEffectFiles is empty, load it
    if ((listOfSoundEffectFiles == nil) || ([listOfSoundEffectFiles count] < 1))
    {
        [self setListOfSoundEffectFiles:[[NSMutableDictionary alloc] init]];
        for (NSString *levelSoundDirectory in plistDictionary)
        {
            [listOfSoundEffectFiles addEntriesFromDictionary:
             [plistDictionary objectForKey:levelSoundDirectory]];
        }
        //CCLOG(@"Number of SFX Filenames:%d",[listOfSoundEffectFiles count]);
    }
    
    // create a mirror of the list above that contains ID/state
    // Sets the state for each to unloaded
    // When the audio for a scene is loaded, each loaded file will get marked as loaded
    // We use this before playing a sound to make sure it's actually been loaded
    if ((soundEffectsState == nil) || ([soundEffectsState count] < 1))
    {
        [self setSoundEffectsState:[[NSMutableDictionary alloc] init]];
        for (NSString *SoundEffectKey in listOfSoundEffectFiles)
        {
            [soundEffectsState setObject:[NSNumber numberWithBool:SFX_NOTLOADED] forKey:SoundEffectKey];
        }
    }
    
    //return the mini SFX List of this scene
    NSString *levelIDName = [self formatSceneTypeToString:levelID];
    NSDictionary *soundEffectsList = [plistDictionary objectForKey:levelIDName];
    return soundEffectsList;
}


//Taken from SpaceViking mostly
-(void) loadAudioForLevelWithID:(NSNumber *) levelIDNumber
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    LevelIDs levelID = (LevelIDs)[levelIDNumber intValue];
    
    if (managerSoundState == kAudioManagerInitializing)
    {
        int waitCycles = 0;
        while (waitCycles < AUDIO_MAX_WAITTIME)
        {
            [NSThread sleepForTimeInterval:0.1];
            if ((managerSoundState == kAudioManagerReady) || (managerSoundState == kAudioManagerFailed))
            {
                break;
            }
            waitCycles = waitCycles + 1;
        }
    }
    
    // abort if audio manager couldn't be initialized
    if (managerSoundState == kAudioManagerFailed)
    {
        return;
    }
    
    NSDictionary *soundEffectsToLoad = [self getSoundEffectsListForLevelWithID:levelID];
    
    if (soundEffectsToLoad == nil)
    {
        CCLOG(@"Error reading SoundEffects.plist");
        return;
    }
    
    //get all entries and preload
    for (NSString *keyString in soundEffectsToLoad)
    {
//        CCLOG(@"\nLoading Audio Key: %@ File: %@", keyString, [soundEffectsToLoad objectForKey:keyString]);
        [soundEngine preloadEffect:[soundEffectsToLoad objectForKey:keyString]];
        [soundEffectsState setObject:[NSNumber numberWithBool:SFX_LOADED] forKey:keyString];
    }
    [pool release];
}

//Taken from Space Viking mostly
-(void) unloadAudioForLevelWithID:(NSNumber*)levelIDNumber
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    LevelIDs levelID = (LevelIDs) [levelIDNumber intValue];
    
    if (levelID == kLevelUnitialized)
    {
        return;
    }
    
    NSDictionary *soundEffectsToUnload = [self getSoundEffectsListForLevelWithID:levelID];
    if (soundEffectsToUnload == nil)
    {
        CCLOG(@"Error reading SoundEffects.plist");
        return;
    }
    
    if (managerSoundState == kAudioManagerReady)
    {
        for (NSString *keyString in soundEffectsToUnload)
        {
            [soundEffectsState setObject:[NSNumber numberWithBool:SFX_NOTLOADED] forKey:keyString];
            [soundEngine unloadEffect:keyString];
//            CCLOG(@"\nUnloading Audio Key: %@ File: %@", keyString, [soundEffectsToUnload objectForKey:keyString]);
        }
    }
    [pool release];
}

// plays the background music for the Level 
-(void) playBackgroundTrack:(LevelIDs)levelID
{
    //wait to make sure the sound engine is initialized
    if ((managerSoundState != kAudioManagerReady) && (managerSoundState != kAudioManagerFailed))
    {
        int waitCycles = 0;
        while (waitCycles < AUDIO_MAX_WAITTIME)
        {
            [NSThread sleepForTimeInterval:0.1f];
            if ((managerSoundState == kAudioManagerReady) || (managerSoundState == kAudioManagerFailed))
            {
                break;
            }
            waitCycles = waitCycles + 1;
        }
    }
    if (managerSoundState == kAudioManagerReady)
    {
        if ([soundEngine isBackgroundMusicPlaying])
        {
            [soundEngine stopBackgroundMusic];
        }
        
        //get the track file name from the Plist
        NSString *fullFileName = @"BackgroundMusic.plist";
        NSString *plistPath;
        
        //get the path to the plist file - looks like Boiler Plate code to me
        NSString *rootPath =
        [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
        if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath])
        {
            plistPath = [[NSBundle mainBundle] pathForResource:@"BackgroundMusic" ofType:@"plist"];
        }
        
        //read the plist
        NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        
        //if the plist is null, the file was not found
        if (plistDictionary == nil)
        {
            CCLOG(@"Error reading BackgroundMusic.plist");
            return;
        }

        NSString *levelIDName = [self formatSceneTypeToString:levelID];
        NSString *trackFileName = [plistDictionary objectForKey:levelIDName];
        
        if (trackFileName.length != 0)
        {
            [soundEngine preloadEffect:trackFileName];
            [soundEngine playBackgroundMusic:trackFileName loop:YES];
        }
    }
}

-(void) stopSoundEffect:(ALuint)soundEffectID
{
    if (managerSoundState == kAudioManagerReady)
    {
        [soundEngine stopEffect:soundEffectID];
    }
}

-(ALuint) playSoundEffect:(NSString *)soundEffectKey
{
    ALuint soundID = 0;
    if (managerSoundState == kAudioManagerReady)
    {
        NSNumber *isFXLoaded = [soundEffectsState objectForKey:soundEffectKey];
        if ([isFXLoaded boolValue] == SFX_LOADED)
        {
            soundID = [soundEngine playEffect:
                       [listOfSoundEffectFiles objectForKey:soundEffectKey]];
        }
        else
        {
            CCLOG(@"GameMgr: SoundEffect %@ is not loaded.", soundEffectKey);
        }
    }
    else
    {
        CCLOG(@"GameMgr: Sound Manager is not ready, cannot play %@.", soundEffectKey);
    }
    return soundID;
}

//////////////////
// Level switching
//////////////////

-(void) runLevelWithID:(LevelIDs)levelID
{
    LevelIDs oldLevel = currentLevel;
    currentLevel = levelID;
    id sceneToRun = nil;
    
    switch (levelID) {
        case kMainMenu:
            sceneToRun = [IntroLayer scene];
            break;
        case kPlayGround1:
            sceneToRun = [PlayGround1Scene node];
            break;
        case kPlayGround2:
            sceneToRun = [PlayGround2Scene node];
            break;
            
        default:
            CCLOG(@"Unknown Level ID, can't change scenes");
            return;
            break;
    }
    
    //see if a new scene was found
    if (sceneToRun == nil)
    {
        //nope, so nothing to do
        currentLevel = oldLevel;
        return;
    }
    
    //Special case Menu code goes here
    if (IS_IPAD())
    {
    }
    else 
    {
    }
    
    // load the sounds for the new scene
    [self performSelectorInBackground: @selector(loadAudioForLevelWithID:)
                           withObject:[NSNumber numberWithInt: currentLevel]];
    
    //switch to the new Level's scene
    if ([[CCDirector sharedDirector] runningScene] == nil)
    {
        [[CCDirector sharedDirector] runWithScene:sceneToRun];
    }
    else
    {
        [[CCDirector sharedDirector] replaceScene:sceneToRun];
    }
    
    [self performSelectorInBackground: @selector(unloadAudioForLevelWithID:)
                          withObject:[NSNumber numberWithInt: oldLevel]];
    
    //AP: note sure if this should go here, or called by the init or onenter for the level itself
    [self playBackgroundTrack:currentLevel];
}


@end
