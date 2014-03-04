//
//  GameViewController.h
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 1/24/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "Anagram.h"
#import <QuartzCore/QuartzCore.h>
#import <iAd/iAd.h>
#import "GCHelper.h"
#import "Games.h"
#import "Anagrams.h"
#import "Levels.h"
#import "Modes.h"
#import "Scores.h"

@interface GameViewController : UIViewController <ADBannerViewDelegate, UIAlertViewDelegate> /*<UIActionSheetDelegate, GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate, GameCenterManagerDelegate>*/
{
    IBOutlet UILabel *labelScore;
    IBOutlet UIButton *buttonHint;
    IBOutlet UIButton *buttonScramble;
    IBOutlet UIButton *buttonCancel;
    IBOutlet UIButton *buttonSubmit;
    IBOutlet UILabel *labelHint;
    IBOutlet UILabel *labelHintValue;
    IBOutlet UIButton *buttonSampleQuestion;
    IBOutlet UIButton *buttonSampleResult;
    IBOutlet UILabel *labelLevel;
    IBOutlet UILabel *labelInvalidAnswer;
    
    IBOutlet UILabel *labelIncorrectResult;
    
    ScoreBoard *scoreBoard;
    Anagram *currentAnagram;
    Games *currentGamesFromModel;
    //Anagrams *currentAnagramsFromModel;
    //Levels *currentLevelsFromModel;
    //Modes *currentModesFromModel;
    NSMutableArray *anagramHistory;
	//GameCenterManager* gameCenterManager;
    
    NSMutableArray *buttonQuestions;
    NSMutableArray *buttonResults;
    
    int selectedQuestion;
    int selectedResult;
    
    int questionMaxLength;
    
    int hintButtonChar;
}

- (IBAction) buttonHint_click:(id)sender;
- (IBAction) buttonQuestions_click:(id)sender;
- (IBAction) buttonResults_click:(id)sender;
- (IBAction) buttonSubmit_click:(id)sender;
- (IBAction)buttonScramble_click:(id)sender;

- (void) loadHint;
- (void) loadAnagram;
- (BOOL) verifyResult;
- (void) loadQuestionResultButtons;
- (void) showHint;
- (void) getQuestionRemaining;
- (void) loadQuestionRemaining;
- (void) scoreThisGame;
- (void) reportScore;


@property (retain, nonatomic) IBOutlet UILabel *labelScore;
@property (retain, nonatomic) IBOutlet UIButton *buttonHint;
@property (retain, nonatomic) IBOutlet UIButton *buttonScramble;
@property (retain, nonatomic) IBOutlet UIButton *buttonCancel;
@property (retain, nonatomic) IBOutlet UIButton *buttonSubmit;
@property (retain, nonatomic) IBOutlet UILabel *labelHint;
@property (retain, nonatomic) IBOutlet UILabel *labelHintValue;
@property (retain, nonatomic) IBOutlet UIButton *buttonSampleQuestion;
@property (retain, nonatomic) IBOutlet UIButton *buttonSampleResult;
@property (retain, nonatomic) IBOutlet UILabel *labelLevel;
@property (retain, nonatomic) IBOutlet UILabel *labelIncorrectResult;
@property (retain, nonatomic) IBOutlet UILabel *labelInvalidAnswer;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (readwrite, nonatomic) int currentGameMode;
@property (readwrite, nonatomic) int currentGameLevel;

@end
