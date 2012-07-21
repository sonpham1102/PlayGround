//
//  TODO.h
//  PlayGroound
//
//  Created by alex on 12-07-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//just a file to allow us to put some notes in here, TODO list etc

/* START NOTES
AP: Add support for sound events with multiple versions
 This would mean changing the Plist structure to have a "varations" field
 When a sound is requested, we would check to see if it has any varations, and if so,
 randomly choose one
 Just remember that we need a unique ID for every sound (for the loaded/unloaded array at least)
 
AP: Look at a tutorial on NSDictionaries ... I'm not totally sure what's happening in the sound loading

AP: Write a GetDictionaryFromPlist function for Gamemanager, use it at least twice, probably more 
 
AP: Make sure PTM is correct for each device
 
AP: KIll all sounds on scene change
AP: Kill all sounds when losing focus

END NOTES */