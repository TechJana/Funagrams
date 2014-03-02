//
//  GameViewController.m
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 1/24/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import "GameViewController.h"
#import "AppDelegate.h"

@interface GameViewController ()
{
    NSManagedObjectContext *context;
}
@end

@implementation GameViewController

@synthesize labelScore;
@synthesize buttonScramble;
@synthesize buttonHint;
@synthesize buttonCancel;
@synthesize buttonSubmit;
@synthesize labelHint;
@synthesize labelHintValue;
@synthesize buttonSampleQuestion;
@synthesize buttonSampleResult;
@synthesize labelLevel;
@synthesize currentGameMode;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize currentGameLevel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*- (void)loadView
{
    [super loadView];
    //buttonSampleQuestion.layer.cornerRadius = 100; // this value vary as per your desire
    //buttonSampleQuestion.clipsToBounds = YES;
    
    CALayer * layer = [buttonSampleQuestion layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:0.0]; //when radius is 0, the border is a rectangle
    [layer setBorderWidth:1.0];
    [layer setBorderColor:[[UIColor grayColor] CGColor]];
    
//    [super loadView];
}*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    context = [appDelegate managedObjectContext];

    // Identify the mainMenu ViewController to get the ScoreBoard object
    NSArray* controllers = self.navigationController.viewControllers;
    ViewController* firstViewController = [controllers objectAtIndex:0];
    scoreBoard = firstViewController.gameScoreBoard;
    currentAnagram = [[Anagram alloc] init];
    questionMaxLength = 0;  // set max. length to 0
    hintButtonChar = -1;    // set invalid position
    self.fetchedResultsController = nil;
    
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}

    [self loadQuestionResultButtons];
    //[self getAnagram];
    //[self getAnagramForMode:[NSNumber numberWithInt:currentGameMode]];
    [self getAnagramForModeAndLevel:[NSNumber numberWithInt:currentGameMode] levelId:[NSNumber numberWithInt:currentGameLevel]];
    //[self getAnagramForMode:[NSNumber numberWithInt:currentGameMode] withArg2:[NSNumber numberWithInt:currentGameLevel]];
    [self loadAnagram];
    
    
    labelScore.text = [NSString stringWithFormat:@"%d ", scoreBoard.currentGameScore];
    selectedQuestion = -1;
    selectedResult = -1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonHint_click:(id)sender
{
    [self showHint];
}

- (IBAction)buttonQuestions_click:(id)sender
{
    // check if the same question is selected again, then de-select the button and do nothing
    if (selectedQuestion >= 0  && [buttonQuestions objectAtIndex:selectedQuestion] == sender) {
        [(UIButton *)[buttonQuestions objectAtIndex:selectedQuestion] setBackgroundColor:nil];
        selectedQuestion = -1;
    }
    else
    {
        UIButton *buttonThis = (UIButton *)sender;
        if (selectedResult >= 0)
        {
            // if the result button was selected then set the current selected question as the selected result
            UIButton *buttonResult = (UIButton *)[buttonResults objectAtIndex:selectedResult];
            NSString *resultText = buttonResult.titleLabel.text;
            [buttonResult setTitle:buttonThis.titleLabel.text forState:UIControlStateNormal];
            // set the result in the user result for verification later
            currentAnagram.userResult = [currentAnagram.userResult stringByReplacingCharactersInRange:NSMakeRange(selectedResult, 1) withString:buttonThis.titleLabel.text];
            [buttonThis setTitle:resultText forState:UIControlStateNormal];
            [buttonResult setNeedsDisplay];
            
            [self verifyResult];
        }
        else
        {
            // change the background color to highlight selection
            UIColor *newBackground = buttonThis.tintColor.copy;
            [buttonThis setBackgroundColor:newBackground];
        }
        
        // check for previous selection
        if (selectedQuestion >= 0) {
            // clear pervious selection
            UIButton *previousSelection = (UIButton *)[buttonQuestions objectAtIndex:selectedQuestion];
            [previousSelection setBackgroundColor:nil];
        }
        
        // only if the result was not selected
        if (selectedResult == -1)
        {
            // make the current as new selection
            selectedQuestion = (int)[buttonQuestions indexOfObject:buttonThis];
        }
        else
        {
            // reset the selection
            [(UIButton *)[buttonResults objectAtIndex:selectedResult] setBackgroundColor:nil];
            
            selectedResult = -1;
        }
    }
}

- (IBAction)buttonResults_click:(id)sender
{
    // check if the same result is selected again, then de-select the button and do nothing
    if (selectedResult >= 0  && [buttonResults objectAtIndex:selectedResult] == sender) {
        [(UIButton *)[buttonResults objectAtIndex:selectedResult] setBackgroundColor:nil];
        selectedResult = -1;
    }
    else
    {
        UIButton *buttonThis = (UIButton *)sender;
        if (selectedQuestion >= 0)
        {
            // if the question button was selected then set the current selected result as the selected question
            UIButton *buttonQuestion = (UIButton *)[buttonQuestions objectAtIndex:selectedQuestion];
            NSString *resultText = buttonQuestion.titleLabel.text;
            [buttonQuestion setTitle:buttonThis.titleLabel.text forState:UIControlStateNormal];
            // set the result in the user result for verification later
            currentAnagram.userResult = [currentAnagram.userResult stringByReplacingCharactersInRange:NSMakeRange((int)[buttonResults indexOfObject:buttonThis], 1) withString:resultText];
            [buttonThis setTitle:resultText forState:UIControlStateNormal];
            [buttonThis setNeedsDisplay];
            
            [self verifyResult];
        }
        else
        {
            // change the background color to highlight selection
            UIColor *newBackground = buttonThis.tintColor.copy;
            [buttonThis setBackgroundColor:newBackground];
        }
        
        // check for previous selection
        if (selectedResult >= 0) {
            // clear pervious selection
            UIButton *previousSelection = (UIButton *)[buttonResults objectAtIndex:selectedResult];
            [previousSelection setBackgroundColor:nil];
        }
        
        // only if the question was not selected
        if (selectedQuestion == -1)
        {
            // make the current as new selection
            selectedResult = (int)[buttonResults indexOfObject:buttonThis];
        }
        else
        {
            // reset the selection
            [(UIButton *)[buttonQuestions objectAtIndex:selectedQuestion] setBackgroundColor:nil];

            selectedQuestion = -1;
        }
    }
}

- (IBAction)buttonSubmit_click:(id)sender
{
    BOOL result;
    result = [self verifyResult];
    
    
}

- (IBAction)buttonScramble_click:(id)sender
{
    [self getQuestionRemaining];
    
    //Scramble the letters in the Question
    currentAnagram.questionRemaining = [self doScramble:currentAnagram.questionRemaining];
    
    //Load the scrambled letters as Buttons
    [self loadQuestionRemaining];
}
    
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Games" inManagedObjectContext:appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"gameId" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:appDelegate.managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:@"Root"];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}

- (NSString*) doScramble:(NSString*)scrambledWord{
    NSString * result = @"";
    scrambledWord = [scrambledWord stringByReplacingOccurrencesOfString:@" " withString:@""];
    //scrambledWord = [scrambledWord uppercaseString];
    int length = [scrambledWord length];
    NSMutableArray *letters = [NSMutableArray arrayWithCapacity:length];
    
    for(int i = 0; i < length; i++){
        char ch = [scrambledWord characterAtIndex:i];
        NSString * cur = [NSString stringWithFormat:@"%c", ch];
        [letters insertObject:cur atIndex:i];
    }
    
    NSLog(@"LETTERS:: %@", letters);
    
    for(int i = length - 1; i >= 0; i--){
        int j = arc4random() % (i + 1);
        //NSLog(@"%d %d", i, j);
        //swap at positions i and j
        NSString * str_i = [letters objectAtIndex:i];
        [letters replaceObjectAtIndex:i withObject:[letters objectAtIndex:j]];
        [letters replaceObjectAtIndex:j withObject:str_i];
    }
    NSLog(@"NEW SHUFFLED LETTERS %@", letters);
    
    
    for(int i = 0; i < length; i++){
        result = [result stringByAppendingString:[letters objectAtIndex:i]];
    }
    
    result = [NSString stringWithFormat:@"%@%*s", result, currentAnagram.question.length-result.length, ""];
    
    NSLog(@"Final string: '%@'", result);
    
    return result;
    
}

- (void)getAnagram
{
#if TEST_MODE_DEF
    currentAnagram.question = @"DORMITORY";
    currentAnagram.questionRemaining = [currentAnagram.question copy];
    currentAnagram.result = @"DIRTY ROOM";
    currentAnagram.hint = @"Dormitory";
    currentAnagram.level = 1;
    currentAnagram.levelDescription = @"Level 1";
    currentAnagram.hintPercentile = 90.0/100.0;
    currentAnagram.hintsProvided = 0;
    currentAnagram.maxHintCount = currentAnagram.question.length * currentAnagram.hintPercentile;
    currentAnagram.levelMaxScore = 1500;
#endif
    
    currentAnagram.userResult = [NSString stringWithFormat:@"%*s", currentAnagram.result.length, ""];

    // get Anagram which doesn't exceed questionMaxLength
    //questionMaxLength;
}

- (void)getAnagramForMode:(NSNumber*)numModeId
{
    NSEntityDescription *gamesEntity = [NSEntityDescription entityForName:@"Games" inManagedObjectContext:context];
    NSFetchRequest *gamesFetchRequest = [[NSFetchRequest alloc] init];
    [gamesFetchRequest setEntity:gamesEntity];
    
    NSString *allowedLength = [NSString stringWithFormat:@".{%d,%d}", 0, questionMaxLength];
    
    NSPredicate *gamesPredicate = [NSPredicate predicateWithFormat:@"modeId = %@ AND anagram.questionText MATCHES %@",numModeId,allowedLength];
    //NSPredicate *gamesPredicate = [NSPredicate predicateWithFormat:@"modeId = %@",numModeId];

    [gamesFetchRequest setPredicate:gamesPredicate];
    
    NSError *error;
    
    NSArray *matchingGamesforMode = [context executeFetchRequest:gamesFetchRequest error:&error];
    
    NSLog(@"ModeID: %@ - Games for this mode: %lu ", numModeId,(unsigned long)matchingGamesforMode.count);
    
    if (matchingGamesforMode.count > 0)
    {
    
        NSInteger randomGameId = arc4random()% (matchingGamesforMode.count + 0);
        //currentGame = [[Games alloc] init];
        currentGamesFromModel = [NSEntityDescription insertNewObjectForEntityForName:@"Games" inManagedObjectContext:context];
        
        currentGamesFromModel = (Games*)[matchingGamesforMode objectAtIndex:randomGameId];
        NSLog(@"Current Game ID : %@", currentGamesFromModel.gameId);
       
//        NSEntityDescription *anagramsEntity = [NSEntityDescription entityForName:@"Anagrams" inManagedObjectContext:context];
//        NSFetchRequest *anagramsFetchRequest = [[NSFetchRequest alloc] init];
//        [anagramsFetchRequest setEntity:anagramsEntity];
//
//        NSPredicate *anagramsPredicate = [NSPredicate predicateWithFormat:@"ANY anagramId == %@",[NSNumber numberWithInt:randomGameId]];
//        
//        //NSPredicate *anagramsPredicate = [NSPredicate predicateWithFormat:@"questionText = 'ELVIS'"];
//        [anagramsFetchRequest setPredicate:anagramsPredicate];
//        //NSError *error;
//        NSArray *randomAnagram = [context executeFetchRequest:anagramsFetchRequest error:&error];
//        //currentAnagram = [context executeFetchRequest:fetchRequest error:&error];
//        NSLog(@"This is a child object: %@", [randomAnagram objectAtIndex:0]);
        
        //Assign the attributes of randomAnagram object to the Current Anagram
        currentAnagram.hint = currentGamesFromModel.anagram.questionText;
        currentAnagram.question = [currentGamesFromModel.anagram.questionText stringByReplacingOccurrencesOfString:@" " withString:@""];
        currentAnagram.questionRemaining = [currentAnagram.question copy];
        currentAnagram.result = currentGamesFromModel.anagram.answerText;
        currentAnagram.level = (int)currentGamesFromModel.levelId;
        currentAnagram.levelDescription = currentGamesFromModel.level.levelDescription;
        currentAnagram.hintPercentile = [currentGamesFromModel.mode.hintsPercentile floatValue];
        currentAnagram.hintsProvided = 0;
        currentAnagram.maxHintCount = currentAnagram.question.length * currentAnagram.hintPercentile;
        currentAnagram.levelMaxScore = (int)currentGamesFromModel.maxScore;
        currentAnagram.userResult = [NSString stringWithFormat:@"%*s", currentAnagram.result.length, ""];
    }
    else
        NSLog(@"No Games available for this mode.");
}

- (int)getLastIncompleteLevelInMode:(NSNumber*)modeId
{
    int levelId = -1;
    Games *games;
    
    NSEntityDescription *gamesEntity = [NSEntityDescription entityForName:@"Games" inManagedObjectContext:context];
    NSFetchRequest *gamesFetchRequest = [[NSFetchRequest alloc] init];
    [gamesFetchRequest setEntity:gamesEntity];
    
    NSPredicate *gamesPredicate = [NSPredicate predicateWithFormat:@"modeId = %@ AND score = nil", modeId];
    NSSortDescriptor *gamesSortByLevel = [[NSSortDescriptor alloc] initWithKey:@"levelId" ascending:YES];
    
    [gamesFetchRequest setPredicate:gamesPredicate];
    [gamesFetchRequest setSortDescriptors:@[gamesSortByLevel]];
    [gamesFetchRequest setFetchLimit:1];
    
    NSError *error;
    
    NSArray *matchingGamesforMode = [context executeFetchRequest:gamesFetchRequest error:&error];
    
    NSLog(@"ModeID: %@ - Games for this mode: %lu ", modeId,(unsigned long)matchingGamesforMode.count);
    
    if (matchingGamesforMode.count > 0)
    {
        games = (Games*)[matchingGamesforMode objectAtIndex:0];
        NSLog(@"Current Game ID : %@", games.gameId);
        
        //Assign the attributes of randomAnagram object to the Current Anagram
        levelId = [games.levelId intValue];
    }
    else
    {
        NSLog(@"No Levels available for this mode.");
        levelId = 1;
    }
        
    return levelId;
}

- (void)updateScoreForGame:(NSNumber *)gameId
{
    NSError *error;
    Games *games;
    Scores *scores;

    NSEntityDescription *gamesEntity = [NSEntityDescription entityForName:@"Games" inManagedObjectContext:context];
    NSFetchRequest *gamesFetchRequest = [[NSFetchRequest alloc] init];
    [gamesFetchRequest setEntity:gamesEntity];
    NSPredicate *gamesPredicate = [NSPredicate predicateWithFormat:@"gameId = %@",gameId];
    [gamesFetchRequest setPredicate:gamesPredicate];
    [gamesFetchRequest setFetchLimit:1];
    
    NSEntityDescription *scoresEntity = [NSEntityDescription entityForName:@"Scores" inManagedObjectContext:context];
    NSFetchRequest *scoresFetchRequest = [[NSFetchRequest alloc] init];
    [scoresFetchRequest setEntity:(NSEntityDescription *)scoresEntity];
    NSSortDescriptor *scoreSortByScoreId = [[NSSortDescriptor alloc] initWithKey:@"scoreId" ascending:NO];
    [scoresFetchRequest setSortDescriptors:@[scoreSortByScoreId]];
    [scoresFetchRequest setFetchLimit:1];
    
    NSArray *matchingGames = [context executeFetchRequest:gamesFetchRequest error:&error];
    
    NSLog(@"GameID: %@ - Game for this gameId: %lu ", gameId,(unsigned long)matchingGames.count);
    
    if (matchingGames.count > 0)
    {
        games = (Games*)[matchingGames objectAtIndex:0];
        NSLog(@"Current Game ID : %@", games.gameId);
        
        NSArray *matchingScores = [context executeFetchRequest:scoresFetchRequest error:&error];
        
        int64_t scoreId=1;
        if (matchingScores.count > 0)
        {
            scores = (Scores*)[matchingScores objectAtIndex:0];
            NSLog(@"Current Score ID : %@", scores.scoreId);
            scoreId = [scores.scoreId longLongValue] + 1;
        }

        scores = [NSEntityDescription
                  insertNewObjectForEntityForName:@"Scores"
                  inManagedObjectContext:context];
        scores.gameId = games.gameId;
        scores.score = [NSNumber numberWithInt:scoreBoard.currentGameScore];
        scores.scoreId = [NSNumber numberWithLongLong:scoreId];
        scores.playedOn = [NSDate date];
        scores.game = games;
        
        games.score = scores;
        
        if (![context save:&error])
        {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
    else
    {
        NSLog(@"No Game available for this gameId.");
    }
}


- (void)getAnagramForModeAndLevel:(NSNumber*)numModeId levelId:(NSNumber*)numLevelId
{
    NSEntityDescription *gamesEntity = [NSEntityDescription entityForName:@"Games" inManagedObjectContext:context];
    NSFetchRequest *gamesFetchRequest = [[NSFetchRequest alloc] init];
    [gamesFetchRequest setEntity:gamesEntity];
    
    int levelId = -1;
    if ([numLevelId intValue] == -1) {
        levelId = [self getLastIncompleteLevelInMode:numModeId];
    }

    NSString *allowedLength = [NSString stringWithFormat:@".{%d,%d}", 0, questionMaxLength];
    
    NSPredicate *gamesPredicate = [NSPredicate predicateWithFormat:@"modeId = %@ AND levelId = %@ AND anagram.questionText MATCHES %@ AND score = nil",numModeId, [NSNumber numberWithInt:levelId], allowedLength];
    
    [gamesFetchRequest setPredicate:gamesPredicate];
    
    NSError *error;
    
    NSArray *matchingGamesforMode = [context executeFetchRequest:gamesFetchRequest error:&error];
    
    NSLog(@"ModeID: %@ - Games for this mode: %lu ", numModeId,(unsigned long)matchingGamesforMode.count);
    
    if (matchingGamesforMode.count > 0)
    {
        
        NSInteger randomGameId = arc4random()% (matchingGamesforMode.count + 0);
        //currentGamesFromModel = [NSEntityDescription insertNewObjectForEntityForName:@"Games" inManagedObjectContext:context];
        
        currentGamesFromModel = (Games*)[matchingGamesforMode objectAtIndex:randomGameId];
        NSLog(@"Current Game ID : %@", currentGamesFromModel.gameId);
        
        //Assign the attributes of randomAnagram object to the Current Anagram
        currentAnagram.question = [currentGamesFromModel.anagram.questionText stringByReplacingOccurrencesOfString:@" " withString:@""];
        currentAnagram.questionRemaining = [currentAnagram.question copy];
        currentAnagram.result = currentGamesFromModel.anagram.answerText;
        currentAnagram.hint = currentGamesFromModel.anagram.questionText;
        currentAnagram.level = [currentGamesFromModel.levelId intValue];
        NSLog(@"currentGamesFromModel.levelId:%@ - %d",currentGamesFromModel.levelId, currentAnagram.level);
        currentAnagram.levelDescription = currentGamesFromModel.level.levelDescription;
        currentAnagram.hintPercentile = [currentGamesFromModel.mode.hintsPercentile floatValue];
        currentAnagram.hintsProvided = 0;
        currentAnagram.maxHintCount = currentAnagram.question.length * currentAnagram.hintPercentile;
        currentAnagram.levelMaxScore = [currentGamesFromModel.maxScore intValue];
        NSLog(@"currentGamesFromModel.levelId:%@ - %d",currentGamesFromModel.maxScore, currentAnagram.levelMaxScore);
        currentAnagram.userResult = [NSString stringWithFormat:@"%*s", currentAnagram.result.length, ""];
        currentAnagram.gameId = currentGamesFromModel.gameId;
    }
    else
        NSLog(@"No Games available for this mode.");
}


- (void) loadQuestionResultButtons
{
    UIButton *buttonIndex;
    int indexButton=0, buttonCount=0, buttonSpacingWidth=4;
    CGRect screenRect = [[UIScreen mainScreen] bounds];

    buttonQuestions = [[NSMutableArray alloc] init];
    buttonResults = [[NSMutableArray alloc] init];

    buttonCount=( screenRect.size.height - (2 * buttonSampleQuestion.frame.origin.x) ) / (buttonSampleQuestion.frame.size.width + buttonSpacingWidth);
    questionMaxLength = buttonCount;
    
    // CREATE QUESTION BUTTONS
    // Archive the button to unarchive a copy every time
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject: buttonSampleQuestion];
    
    for (indexButton=0; indexButton<buttonCount; indexButton++) {
        // Unarchive a copy of the Archived button
        buttonIndex = [NSKeyedUnarchiver unarchiveObjectWithData: archivedData];
        
        // Moving X position with the required spacing
        buttonIndex.frame = CGRectMake(buttonIndex.frame.origin.x + ( indexButton * (buttonIndex.frame.size.width + buttonSpacingWidth) ), buttonIndex.frame.origin.y, buttonIndex.frame.size.width, buttonIndex.frame.size.height);
        
        // Reset the value of the button to empty string to load the required question
        [buttonIndex setTitle:@" " forState:UIControlStateNormal];
        [buttonIndex addTarget:self action:@selector(buttonQuestions_click:) forControlEvents:UIControlEventTouchUpInside];
        
        [self setButtonBorder:buttonIndex];
        
        [self.view addSubview:buttonIndex];
        
        // Add the new button to the array for future use
        [buttonQuestions insertObject:buttonIndex atIndex:buttonQuestions.count];
    }

    // CREATE ANSWER BUTTONS
    // Archive the button to unarchive a copy every time
    archivedData = [NSKeyedArchiver archivedDataWithRootObject: buttonSampleResult];
    
    for (indexButton=0; indexButton<buttonCount; indexButton++) {
        // Unarchive a copy of the Archived button
        buttonIndex = [NSKeyedUnarchiver unarchiveObjectWithData: archivedData];
        
        // Moving X position with the required spacing
        buttonIndex.frame = CGRectMake(buttonIndex.frame.origin.x + ( indexButton * (buttonIndex.frame.size.width + buttonSpacingWidth) ), buttonIndex.frame.origin.y, buttonIndex.frame.size.width, buttonIndex.frame.size.height);
        
        // Reset the value of the button to box character to initiate play mode
        [buttonIndex setTitle:@" " forState:UIControlStateNormal];
        [buttonIndex addTarget:self action:@selector(buttonResults_click:) forControlEvents:UIControlEventTouchUpInside];
        
        [self setButtonBorder:buttonIndex];
        
        [self.view addSubview:buttonIndex];
        
        // Add the new button to the array for future use
        [buttonResults insertObject:buttonIndex atIndex:buttonResults.count];
    }
    
    buttonSampleQuestion.hidden = true;
    buttonSampleResult.hidden = true;
}

- (void) setButtonBorder:(UIButton *)buttonThis
{
    // set the border
    buttonThis.layer.cornerRadius = 10;
    buttonThis.layer.borderWidth = 1;
    buttonThis.layer.borderColor = [UIColor blueColor].CGColor;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [buttonThis.titleLabel setFont:[UIFont systemFontOfSize:40]];
    }
    else
    {
        [buttonThis.titleLabel setFont:[UIFont systemFontOfSize:27]];
    }
}

- (void)loadQuestionRemaining
{
    //@"▢"
    int indexButton;
    
    // load question
    for (indexButton=0; (indexButton<buttonQuestions.count && indexButton<currentAnagram.questionRemaining.length); indexButton++) {
        UIButton *buttonIndex = [buttonQuestions objectAtIndex:indexButton];
        [buttonIndex setTitle:[currentAnagram.questionRemaining substringWithRange:NSMakeRange(indexButton, 1)] forState:UIControlStateNormal];
    }
}

- (void)loadAnagram
{
    //@"▢"
    int indexButton;

    if (currentAnagram.question.length <= questionMaxLength)
    {
        [self loadQuestionRemaining];
        
        // make any additional button invisible
        for (indexButton=currentAnagram.questionRemaining.length; indexButton<buttonQuestions.count; indexButton++)
        {
            UIButton *buttonIndex = [buttonQuestions objectAtIndex:indexButton];
            buttonIndex.hidden = true;
        }
        
        // load answer positioning
        for (indexButton=0; (indexButton<buttonResults.count && indexButton<currentAnagram.result.length); indexButton++) {
            if ([currentAnagram.result characterAtIndex:indexButton] == ' ')
            {
                UIButton *buttonIndex = [buttonResults objectAtIndex:indexButton];
                buttonIndex.hidden = true;
            }
        }
        // make any additional button invisible
        for ( ; indexButton<buttonResults.count; indexButton++)
        {
            UIButton *buttonIndex = [buttonResults objectAtIndex:indexButton];
            buttonIndex.hidden = true;
        }
    }
    else
    {
        NSLog(NSLocalizedString(@"Error 10001", nil), questionMaxLength);
    }
    
    labelHintValue.text = currentAnagram.hint;  // load hint
    labelLevel.text = currentAnagram.levelDescription;  // load level description
}

- (void)getQuestionRemaining
{
    int indexButton;
    NSString *questionValue=@"";
    UIButton *buttonThis;
    
    // concatenate the values in result button
    for (indexButton=0; indexButton<buttonQuestions.count; indexButton++) {
        buttonThis = (UIButton *)[buttonQuestions objectAtIndex:indexButton];
        if (![buttonThis.titleLabel.text  isEqual: @""] && buttonThis.titleLabel.text != nil) {
            questionValue = [questionValue stringByAppendingString:buttonThis.titleLabel.text];
        }
    }
    
    currentAnagram.questionRemaining = questionValue;
}

- (BOOL)verifyResult
{
    NSString *resultValue=@"", *resultAnswer=@"";
    
    // clean-up to compare
    resultValue = currentAnagram.userResult;
    resultValue = [resultValue stringByReplacingOccurrencesOfString:@" " withString:@""];
    resultValue = [resultValue uppercaseString];
    
    // clean-up to compare
    resultAnswer = currentAnagram.result;
    resultAnswer = [resultAnswer stringByReplacingOccurrencesOfString:@" " withString:@""];
    resultAnswer = [resultAnswer uppercaseString];
    
    if ([resultAnswer isEqualToString:resultValue])
    {
        [self scoreThisGame];
        labelScore.text = [NSString stringWithFormat:@"%d", scoreBoard.currentGameScore];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GameOverTitle", nil)
                                        message:[NSString stringWithFormat:@"%@%d", NSLocalizedString(@"GameOverDescription", nil), scoreBoard.currentGameScore]
                                        delegate:self
                                    cancelButtonTitle:NSLocalizedString(@"GameOverCancelButtonTitle", nil)
                                    otherButtonTitles:NSLocalizedString(@"GameOverNextButtonTitle", nil),nil];
        [alert show];
        [self reportScore];
        
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

- (void)reportScore
{
    [[GCHelper defaultHelper] reportScore:scoreBoard.currentGameScore forLeaderboardID:kLeaderBoardIdentifier];
}

- (void)scoreThisGame
{
    // score = (1 - hintsProvided/maxHintCount) * levelMaxScore
    int score = 0;
    score = currentAnagram.levelMaxScore +
        ((1.0 - (currentAnagram.hintsProvided / currentAnagram.maxHintCount)) * currentAnagram.levelMaxScore);
    scoreBoard.currentGameScore = score;
    
    [self updateScoreForGame:currentAnagram.gameId];
    [self reportScore];
}

- (void)fadeOffHint:(id)sender
{
    // fade off the Hint selection
    if (hintButtonChar != -1)
    {
        // clear pervious selection
        UIButton *previousSelection = (UIButton *)[buttonResults objectAtIndex:hintButtonChar];
        [previousSelection setBackgroundColor:nil];
        
        hintButtonChar = -1;
    }
}

- (void)showHint
{
    // if the hint is already visible, turn it off
    if (hintButtonChar != -1)
    {
        [self fadeOffHint:nil];
    }
    
    // if the hints provided exceeds max hint to show, stop this process
    if (currentAnagram.hintsProvided >= currentAnagram.maxHintCount)
    {
        buttonHint.enabled = FALSE;
    }
    
    int indexButton;
    NSString *currentChar;
    UIButton *buttonResult, *buttonQuestion;
    NSMutableArray *indexArray = [[NSMutableArray alloc] init];
    
    // identify a random character which is not selected right by user
    for (indexButton=0; indexButton<currentAnagram.result.length; indexButton++)
    {
        buttonResult = (UIButton *)[buttonResults objectAtIndex:indexButton];
        if (![buttonResult.titleLabel.text  isEqual: @""] && buttonResult.titleLabel.text != nil) {
            currentChar = [NSString stringWithFormat:@"%c", [currentAnagram.result characterAtIndex:indexButton]];
            if (![buttonResult.titleLabel.text isEqualToString:currentChar]) {
                [indexArray addObject:[NSNumber numberWithInt:indexButton]];
            }
        }
    }

    // only if there is pending invalid result character, suggest answer
    if (indexArray.count > 0)
    {
        NSNumber *tempValue = (NSNumber *)[indexArray objectAtIndex:(arc4random() % (indexArray.count + 0))];
        hintButtonChar = [tempValue intValue];
        
        // remove the random selection from the Question/Result from incorrect position
        NSString *newResult = [NSString stringWithFormat:@"%c", [currentAnagram.result characterAtIndex:hintButtonChar]];
        for (indexButton=0; indexButton<buttonQuestions.count; indexButton++)
        {
            buttonQuestion = (UIButton *)[buttonQuestions objectAtIndex:indexButton];
            if (![buttonQuestion.titleLabel.text  isEqual: @""] && buttonQuestion.titleLabel.text != nil) {
                if ([buttonQuestion.titleLabel.text isEqualToString:newResult]) {   // set the question as the current content of result button
                    [buttonQuestion setTitle:((UIButton *)[buttonResults objectAtIndex:hintButtonChar]).titleLabel.text forState:UIControlStateNormal];
                    break;
                }
            }
        }
        
        // set the right character for the random selection
        buttonResult = (UIButton *)[buttonResults objectAtIndex:hintButtonChar];
        [buttonResult setTitle:newResult forState:UIControlStateNormal];
        // set the result in the user result for verification later
        currentAnagram.userResult = [currentAnagram.userResult stringByReplacingCharactersInRange:NSMakeRange(hintButtonChar, 1) withString:newResult];

        
        // highlight the random character with specific color
        UIButton *previousSelection = (UIButton *)[buttonResults objectAtIndex:hintButtonChar];
        [previousSelection setBackgroundColor:[UIColor greenColor]];
        
        [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(fadeOffHint:) userInfo:nil repeats:NO];

        currentAnagram.hintsProvided = currentAnagram.hintsProvided + 1;
        
        // if the hints provided exceeds max hint to show, stop this process
        if (currentAnagram.hintsProvided >= currentAnagram.maxHintCount)
        {
            buttonHint.enabled = FALSE;
        }
    }
    else
    {
        buttonHint.enabled = FALSE;
    }
}

#pragma mark iAd Delegate Methods
-(void) bannerViewDidLoadAd:(ADBannerView *)banner
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    [banner setAlpha:1];
    [UIView commitAnimations];
}

-(void) bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    [banner setAlpha:0];
    [UIView commitAnimations];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Next Level >> "])
    {
        NSLog(@"Next Level button was selected.");
        [self getAnagramForModeAndLevel:[NSNumber numberWithInt:currentGameMode] levelId:[NSNumber numberWithInt:currentGameLevel]];
    }
    else if([title isEqualToString:@"<< Play again"])
    {
        NSLog(@"Play again button was selected.");
        currentAnagram.hintsProvided = 0;
        currentAnagram.questionRemaining = [currentAnagram.question copy];
        currentAnagram.userResult = [NSString stringWithFormat:@"%*s", currentAnagram.result.length, ""];
        //[buttonQuestions objectAtIndex:selectedQuestion]
        //[buttonResults objectAtIndex:selectedQuestion]
        [self loadQuestionResultButtons];
        [self loadAnagram];
    }
}

#pragma mark GameCenter View Controllers
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	[self dismissViewControllerAnimated:YES completion:nil];
	//[viewController release];
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController;
{
	[self dismissViewControllerAnimated: YES completion:nil];
	//[viewController release];
}

@end
