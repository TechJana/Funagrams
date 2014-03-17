//
//  GlobalConstants.h
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 2/26/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    kGameModeBeginner = 1,
    kGameModeIntermediate = 2,
    kGameModeExpert = 3
}eGameMode;

extern NSString* const kSettingsMusic;
extern NSString* const kSettingsGameMode;
extern int const kGameLevelLastIncompleteLevel;

//game leader
extern NSString* const kLeaderBoardHighScore;
extern NSString* const kLeaderBoardLevel01;
extern NSString* const kLeaderBoardLevel02;
extern NSString* const kLeaderBoardLevel03;
extern NSString* const kLeaderBoardLevel04;
extern NSString* const kLeaderBoardLevel05;
extern NSString* const kLeaderBoardLevel06;
extern NSString* const kLeaderBoardLevel07;
extern NSString* const kLeaderBoardLevel08;
extern NSString* const kLeaderBoardLevel09;
extern NSString* const kLeaderBoardLevel10;
extern NSString* const kLeaderBoardLevel11;
extern NSString* const kLeaderBoardLevel12;
extern NSString* const kLeaderBoardLevel13;
extern NSString* const kLeaderBoardLevel14;
extern NSString* const kLeaderBoardLevel15;
extern NSString* const kLeaderBoardLevel16;
extern NSString* const kLeaderBoardLevel17;
extern NSString* const kLeaderBoardLevel18;
extern NSString* const kLeaderBoardLevel19;
extern NSString* const kLeaderBoardLevel20;
extern NSMutableArray* kLeaderBoardLevels;

@interface GlobalConstants : NSObject

@end
