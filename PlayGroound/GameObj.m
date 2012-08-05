//
//  GameObj.m
//  PlayGroound
//
//  Created by alex on 12-07-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameObj.h"

@implementation GameObj

@synthesize gameObjType;

-(id) init
{
    if ((self=[super init]))
    {
        gameObjType = kObjTypeNone;
    }
    return self;
}

-(void)updateStateWithDeltaTime:(ccTime)dt
{
    //OVERRIDE
}

-(void) changeState:(CharStates)newState
{
    //OVERRIDE
}

-(CGRect) adjustedBoundingBox
{
    //OVERRIDE as necessary
    return [self boundingBox];
}
-(CCAnimation*) loadPlistForAnimationWithName:(NSString *)animationName andClassName:(NSString *)className
{
    CCAnimation *animationToReturn = nil;
    NSString *fullFileName = [NSString stringWithFormat:@"%@.plist", className];
    NSString *plistPath;
    
    //get the string for the path to the plist file
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath])
    {
        plistPath = [[NSBundle mainBundle] pathForResource:className ofType:@"plist"];
    }
    
    //read in the plist file
    NSDictionary *plistDictionary =[NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    //see if the file was found, if not return nil
    if (plistDictionary == nil)
    {
        CCLOG(@"error reading the plist: %@.plist", className);
        return nil;
    }
    
    // get the mini dictionary for this animation
    NSDictionary *animationSettings = [plistDictionary objectForKey:animationName];
    if (animationSettings == nil)
    {
        CCLOG(@"Could not locate AnimationWithName: %@", animationName);
        return nil;
    }
    
    //get the delay value
    float animationDelay = [[animationSettings objectForKey:@"delay"] floatValue];
    animationToReturn = [CCAnimation animation];
    [animationToReturn setDelayPerUnit:animationDelay];
    
    //add the frames to the animation
    NSString *animationPrefix = [animationSettings objectForKey:@"filenamePrefix"];
    NSString *animationFrames = [animationSettings objectForKey:@"animationFrames"];
    NSArray *animationFrameNumbers = [animationFrames componentsSeparatedByString:@","];
    
    for (NSString *frameNumber in animationFrameNumbers)
    {
        NSString *frameName = [NSString stringWithFormat:@"%@%@.png", animationPrefix, frameNumber];
        [animationToReturn addSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]];
    }
    
    return animationToReturn;
}

@end
