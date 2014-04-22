//
//  GameViewController.m
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 1/24/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import "GameViewController.h"
#import "AppDelegate.h"
#import "GlobalConstants.h"
#import "ImageLabelView.h"
#import "AHAlertView.h"
#import "Tile.h"

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
@synthesize labelIncorrectResult;
@synthesize labelInvalidAnswer;
@synthesize currentGameMode;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize currentGameLevel;
@synthesize imageSampleQuestion;
@synthesize imageSampleResult;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    currentAnagram = [[ExtendedAnagram alloc] init];
    questionMaxLength = 0;  // set max. length to 0
    hintButtonChar = -1;    // set invalid position
    self.fetchedResultsController = nil;
    labelInvalidAnswer.hidden = YES;    // hide invalid answer in the start
    imageSpacingWidth = 0;  // spacing between tiles
    rootView = [[[UIApplication sharedApplication] keyWindow] rootViewController].view;
    
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    questionMaxLength = ( screenRect.size.height - (2 * imageSampleQuestion.frame.origin.x) ) / (imageSampleQuestion.frame.size.width + imageSpacingWidth);

    [self getAnagramForModeAndLevel:[NSNumber numberWithInt:currentGameMode] levelId:[NSNumber numberWithInt:currentGameLevel]];
    [self loadQuestionResultHolderImages];
    [self loadAnagram];
    
    labelScore.text = @"0";
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
            // hide the Invalid Answer label if the user attempted to change a value
            if (!labelInvalidAnswer.hidden) {
                labelInvalidAnswer.hidden = YES;
            }
            
            // if the result button was selected then set the current selected question as the selected result
            UIButton *buttonResult = (UIButton *)[buttonResults objectAtIndex:selectedResult];
            NSString *resultText = buttonResult.titleLabel.text;
            [buttonResult setTitle:buttonThis.titleLabel.text forState:UIControlStateNormal];
            // set the result in the user result for verification later
            currentAnagram.userResult = [currentAnagram.userResult stringByReplacingCharactersInRange:NSMakeRange(selectedResult, 1) withString:buttonThis.titleLabel.text];
            [buttonThis setTitle:resultText forState:UIControlStateNormal];
            [buttonResult setNeedsDisplay];
            
            labelIncorrectResult.hidden = YES;
            
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
            // hide the Invalid Answer label if the user attempted to change a value
            if (!labelInvalidAnswer.hidden) {
                labelInvalidAnswer.hidden = YES;
            }
            
            // if the question button was selected then set the current selected result as the selected question
            UIButton *buttonQuestion = (UIButton *)[buttonQuestions objectAtIndex:selectedQuestion];
            NSString *resultText = buttonQuestion.titleLabel.text;
            [buttonQuestion setTitle:buttonThis.titleLabel.text forState:UIControlStateNormal];
            // set the result in the user result for verification later
            currentAnagram.userResult = [currentAnagram.userResult stringByReplacingCharactersInRange:NSMakeRange((int)[buttonResults indexOfObject:buttonThis], 1) withString:resultText];
            [buttonThis setTitle:resultText forState:UIControlStateNormal];
            [buttonThis setNeedsDisplay];
            
            labelIncorrectResult.hidden = YES;
            
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
    if ([currentAnagram.questionRemaining stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate playSoundFile:NSLocalizedString(@"SoundScrambleTileFileName", nil)];
    }

    //Scramble the letters in the Question
    currentAnagram.questionRemaining = [self doScramble:currentAnagram.questionRemaining];
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
    NSMutableArray *questionTiles = [Tile getTilesFor:YES fromTilesArray:tiles];    //get all Question tiles
    CGSize screenSize = [rootView convertRect:[[UIScreen mainScreen] bounds] fromView:nil].size;
    CGPoint orgin;

    orgin = CGPointMake((screenSize.width - ( currentAnagram.questionText.length * (imageSampleResult.frame.size.width + imageSpacingWidth) ) - imageSpacingWidth) / 2, 0);

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

        if (i != j)
        {
            //swap at positions i and j
            NSString * str_i = [letters objectAtIndex:i];
            [letters replaceObjectAtIndex:i withObject:[letters objectAtIndex:j]];
            [letters replaceObjectAtIndex:j withObject:str_i];
            
            // swap tile index & location
            Tile *iTile = [questionTiles objectAtIndex:i];
            Tile *jTile = [questionTiles objectAtIndex:j];
            int tempIndex = iTile.index;
            iTile.index = jTile.index;
            jTile.index = tempIndex;
            [iTile.image setFrame:CGRectMake(orgin.x + ( iTile.index * (iTile.image.frame.size.width + imageSpacingWidth) ), iTile.image.frame.origin.y, iTile.image.frame.size.width, iTile.image.frame.size.height)];
            [jTile.image setFrame:CGRectMake(orgin.x + ( jTile.index * (jTile.image.frame.size.width + imageSpacingWidth) ), jTile.image.frame.origin.y, jTile.image.frame.size.width, jTile.image.frame.size.height)];
        }
    }
    NSLog(@"NEW SHUFFLED LETTERS %@", letters);
    
    
    for(int i = 0; i < length; i++){
        result = [result stringByAppendingString:[letters objectAtIndex:i]];
    }
    
    result = [NSString stringWithFormat:@"%@%*s", result, currentAnagram.questionText.length-result.length, ""];
    
    NSLog(@"Final string: '%@'", result);
    
    return result;
    
}

- (void)getAnagramForMode:(NSNumber*)numModeId
{
    NSEntityDescription *gamesEntity = [NSEntityDescription entityForName:@"Games" inManagedObjectContext:context];
    NSFetchRequest *gamesFetchRequest = [[NSFetchRequest alloc] init];
    [gamesFetchRequest setEntity:gamesEntity];
    
    NSString *allowedLength = [NSString stringWithFormat:@".{%d,%d}", 0, questionMaxLength];
    
    NSPredicate *gamesPredicate = [NSPredicate predicateWithFormat:@"mode.modeId = %@ AND anagram.questionText MATCHES %@",numModeId,allowedLength];
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
       
        //Assign the attributes of randomAnagram object to the Current Anagram
        currentAnagram.questionRemaining = [currentAnagram.questionText copy];
        currentAnagram.userResult = [NSString stringWithFormat:@"%*s", currentAnagram.answerText.length, ""];
        currentAnagram.hintsProvided = 0;
        currentAnagram.maxHintCount = currentAnagram.questionText.length * [currentAnagram.hintsPercentile floatValue];
    }
    else
    {
        NSLog(@"No Games available for this mode.");
    }
}

- (int)getLastIncompleteLevelInMode:(NSNumber*)modeId
{
    int levelId = -1;
    Games *games;
    NSError *error;
    NSMutableArray *levelIds = [[NSMutableArray alloc] init];
    
    NSEntityDescription *gamesEntity = [NSEntityDescription entityForName:@"Games" inManagedObjectContext:context];
    NSFetchRequest *gamesFetchRequest = [[NSFetchRequest alloc] init];
    [gamesFetchRequest setEntity:gamesEntity];
    
    NSPredicate *gamesPredicate = [NSPredicate predicateWithFormat:@"mode.modeId = %@ AND score != nil", modeId];

    [gamesFetchRequest setPredicate:gamesPredicate];
    [gamesFetchRequest setReturnsDistinctResults:YES];
    [gamesFetchRequest setPropertiesToFetch:@[@"levelId"]];
    
    NSArray *matchingGamesforMode = [context executeFetchRequest:gamesFetchRequest error:&error];
    
    NSLog(@"ModeID: %@ - Games for this mode: %lu ", modeId,(unsigned long)matchingGamesforMode.count);
    
    if (matchingGamesforMode.count > 0)
    {
        for (int indexCount=0; indexCount<matchingGamesforMode.count; indexCount++) {
            games = (Games *)[matchingGamesforMode objectAtIndex:indexCount];
            [levelIds insertObject:games.level.levelId atIndex:levelIds.count];
        }
        
        gamesEntity = [NSEntityDescription entityForName:@"Games" inManagedObjectContext:context];
        gamesFetchRequest = [[NSFetchRequest alloc] init];
        [gamesFetchRequest setEntity:gamesEntity];
        
        gamesPredicate = [NSPredicate predicateWithFormat:@"mode.modeId = %@ AND score = nil AND NOT level.levelId IN %@", modeId, levelIds];
        NSSortDescriptor *gamesSortByLevel = [[NSSortDescriptor alloc] initWithKey:@"levelId" ascending:YES];
        
        [gamesFetchRequest setPredicate:gamesPredicate];
        [gamesFetchRequest setSortDescriptors:@[gamesSortByLevel]];
        [gamesFetchRequest setFetchLimit:1];
        
        matchingGamesforMode = [context executeFetchRequest:gamesFetchRequest error:&error];
        
        NSLog(@"ModeID: %@ - Games for this mode: %lu ", modeId,(unsigned long)matchingGamesforMode.count);
        
        if (matchingGamesforMode.count > 0)
        {
            games = (Games*)[matchingGamesforMode objectAtIndex:0];
            NSLog(@"Current Game ID : %@", games.gameId);
            
            //Assign the attributes of randomAnagram object to the Current Anagram
            levelId = [games.level.levelId intValue];
        }
        else
        {
            NSLog(@"No Levels available for this mode.");
            levelId = 1;
        }
        //Assign the attributes of randomAnagram object to the Current Anagram
        levelId = [games.level.levelId intValue];
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
        scores.score = [NSNumber numberWithInt:scoreBoard.currentGameScore];
        scores.scoreId = [NSNumber numberWithLongLong:scoreId];
        scores.playedOn = [NSDate date];
        scores.game = games;
        
        if (games.score == nil) {
            games.score = [[NSSet alloc] init];
        }
        NSMutableSet *scoreSet = [NSMutableSet setWithSet:games.score];
        [scoreSet addObject:scores];
        games.score = [NSSet setWithArray:[scoreSet allObjects]];
        //[games.score setValue:scores forKey:[NSString stringWithFormat:@"%d", games.score.count+1]];
        
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
    else{
        levelId = [numLevelId intValue];
    }

    NSString *allowedLength = [NSString stringWithFormat:@".{%d,%d}", 0, questionMaxLength];
    
    NSPredicate *gamesPredicate = [NSPredicate predicateWithFormat:@"(SUBQUERY(mode, $mode, $mode.modeId == %@).@count) > 0 AND (SUBQUERY(level, $level, $level.levelId == %@).@count) > 0 AND (SUBQUERY(anagram, $anagram, $anagram.questionText MATCHES %@ AND $anagram.answerText MATCHES %@).@count) > 0 AND score.@count=0", numModeId, [NSNumber numberWithInt:levelId], allowedLength, allowedLength];
    
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
        currentAnagram.gameId = currentGamesFromModel.gameId;
        currentAnagram.maxScore = currentGamesFromModel.maxScore;
        currentAnagram.anagramId = currentGamesFromModel.anagram.anagramId;
        currentAnagram.questionText = currentGamesFromModel.anagram.questionText;
        currentAnagram.answerText = currentGamesFromModel.anagram.answerText;
        currentAnagram.levelId = currentGamesFromModel.level.levelId;
        currentAnagram.levelDescription = currentGamesFromModel.level.levelDescription;
        currentAnagram.modeId = currentGamesFromModel.mode.modeId;
        currentAnagram.modeDescription = currentGamesFromModel.mode.modeDescription;

        currentAnagram.questionRemaining = [currentAnagram.questionText copy];
        currentAnagram.userResult = [NSString stringWithFormat:@"%*s", currentAnagram.answerText.length, ""];
        currentAnagram.hintsProvided = 0;
        currentAnagram.maxHintCount = currentAnagram.questionText.length * [currentAnagram.hintsPercentile floatValue];
    }
    else
    {
        NSLog(@"No Games available for this mode.");
    }
}


- (void) loadQuestionResultHolderImages
{
    UIImageView *imageIndex;
    int indexImage=0;
    CGSize screenSize = [rootView convertRect:[[UIScreen mainScreen] bounds] fromView:nil].size;
    CGPoint orgin;
    
    imageHolderQuestions = [[NSMutableArray alloc] init];
    imageHolderResults = [[NSMutableArray alloc] init];
    
    // making this method re-runnable
    imageSampleQuestion.hidden = NO;
    imageSampleResult.hidden = NO;

    // CREATE QUESTION HOLDER IMAGES
    // Archive the button to unarchive a copy every time
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject: imageSampleResult];
    
    orgin = CGPointMake((screenSize.width - ( currentAnagram.questionText.length * (imageSampleResult.frame.size.width + imageSpacingWidth) ) - imageSpacingWidth) / 2, 0);
    for (indexImage=0; indexImage<currentAnagram.questionText.length; indexImage++) {
        if ([currentAnagram.questionText characterAtIndex:indexImage] != ' ')
        {
            // Unarchive a copy of the Archived button
            imageIndex = [NSKeyedUnarchiver unarchiveObjectWithData: archivedData];
            
            // Moving X position with the required spacing
            imageIndex.frame = CGRectMake(orgin.x + ( indexImage * (imageIndex.frame.size.width + imageSpacingWidth) ), imageSampleQuestion.frame.origin.y, imageIndex.frame.size.width, imageIndex.frame.size.height);
            
            [imageIndex setImage:[UIImage imageNamed:@"TileHolderImage"]];
            
            [self.view addSubview:imageIndex];
            
            // Add the new button to the array for future use
            [imageHolderQuestions addObject:imageIndex];
        }
    }
    
    // CREATE ANSWER HOLDER IMAGES
    // Archive the button to unarchive a copy every time
    orgin = CGPointMake((screenSize.width - ( currentAnagram.answerText.length * (imageSampleResult.frame.size.width + imageSpacingWidth) ) - imageSpacingWidth) / 2, 0);
    for (indexImage=0; indexImage<currentAnagram.answerText.length; indexImage++) {
        if ([currentAnagram.answerText characterAtIndex:indexImage] != ' ')
        {
            // Unarchive a copy of the Archived button
            imageIndex = [NSKeyedUnarchiver unarchiveObjectWithData: archivedData];
            
            // Moving X position with the required spacing
            imageIndex.frame = CGRectMake(orgin.x + ( indexImage * (imageIndex.frame.size.width + imageSpacingWidth) ), imageIndex.frame.origin.y, imageIndex.frame.size.width, imageIndex.frame.size.height);
            
            [imageIndex setImage:[UIImage imageNamed:@"TileHolderImage"]];
            
            [self.view addSubview:imageIndex];
            
            // Add the new button to the array for future use
            [imageHolderResults addObject:imageIndex];
        }
    }
    
    imageSampleQuestion.hidden = YES;
    imageSampleResult.hidden = YES;
}

- (void) setButtonBorder:(UIButton *)buttonThis
{
    // set the border
    //buttonThis.layer.cornerRadius = 10;
    //buttonThis.layer.borderWidth = 1;
    //buttonThis.layer.borderColor = [UIColor blueColor].CGColor;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [buttonThis.titleLabel setFont:[UIFont systemFontOfSize:45]];
    }
    else
    {
        [buttonThis.titleLabel setFont:[UIFont systemFontOfSize:30]];
    }
}

- (void)loadQuestionRemaining
{
    //@"▢"
    int indexImage;
    
    // load question
    for (NSString *keyIndex in imageQuestions) {
        UIImageView *imageIndex = [imageQuestions valueForKey:keyIndex];
        UIImage *img = [ImageLabelView drawText:[currentAnagram.questionRemaining substringWithRange:NSMakeRange(indexImage, 1)]
                                        inImage:[UIImage imageNamed:@"TileImage"]
                                        atPoint:CGPointMake(-1, -1)];
        imageIndex.accessibilityLabel = [currentAnagram.questionRemaining substringWithRange:NSMakeRange(indexImage, 1)];
        [imageIndex setImage:img];
    }
}

- (void)loadAnagram
{
    if (currentAnagram.questionText.length <= questionMaxLength)
    {
        // CREATE QUESTION HOLDER IMAGES
        int indexImage;
        UIImageView *imageIndex, *imageHolderQuestion;
        // Archive the button to unarchive a copy every time
        NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject: imageSampleQuestion];

        tiles = [[NSMutableArray alloc] init];
        
        for (indexImage=0; indexImage<currentAnagram.questionText.length; indexImage++) {
            // Unarchive a copy of the Archived button
            imageIndex = [NSKeyedUnarchiver unarchiveObjectWithData: archivedData];
            
            imageHolderQuestion = (UIImageView *)[imageHolderQuestions objectAtIndex:indexImage];
            
            Tile *indexTile = [[Tile alloc] init];
            indexTile.text = [NSString stringWithFormat:@"%c", [currentAnagram.questionText characterAtIndex:indexImage]];
            indexTile.index = indexImage;
            [indexTile renderTile];

            // Moving X position with the required spacing
            indexTile.image.frame = CGRectMake(imageHolderQuestion.frame.origin.x, imageHolderQuestion.frame.origin.y, imageSampleQuestion.frame.size.width, imageSampleQuestion.frame.size.height);
            
            [self.view addSubview:indexTile.image];
            
            // Add the new button to the array for future use
            [tiles addObject:indexTile];
        }
    }
    else
    {
        NSLog(NSLocalizedString(@"Error 10001", nil), questionMaxLength);
    }
    
    labelHintValue.text = currentAnagram.questionText;  // load hint
    labelLevel.text = currentAnagram.levelDescription;  // load level description
}

- (void) tileMovedToIndexIn:(int)index inQuestion:(BOOL)isToQuestion fromIndex:(int)fromIndex fromQuestion:(BOOL)isFromQuestion fromTileIndex:(int)tileIndex
{
    Tile *thisTile = (Tile *)[tiles objectAtIndex:tileIndex];

    thisTile.index = index;
    
    if (isToQuestion)
    {
        // write code to move this alphabet to Question Remaining phrase
        thisTile.isQuestion = YES;
        currentAnagram.questionRemaining = [currentAnagram.questionRemaining stringByReplacingCharactersInRange:NSMakeRange(index, 1) withString:thisTile.text];
        currentAnagram.userResult = [currentAnagram.userResult stringByReplacingCharactersInRange:NSMakeRange(fromIndex, 1) withString:@" "];
    }
    else
    {
        // write code to move this alphabet to User Answer phrase
        thisTile.isQuestion = NO;
        currentAnagram.userResult = [currentAnagram.userResult stringByReplacingCharactersInRange:NSMakeRange(index, 1) withString:thisTile.text];
        currentAnagram.questionRemaining = [currentAnagram.questionRemaining stringByReplacingCharactersInRange:NSMakeRange(fromIndex, 1) withString:@" "];
    }
}

- (BOOL)verifyResult
{
    NSString *resultValue=@"", *resultAnswer=@"";
    
    // clean-up to compare
    resultValue = currentAnagram.userResult;
    resultValue = [resultValue stringByReplacingOccurrencesOfString:@" " withString:@""];
    resultValue = [resultValue uppercaseString];
    
    // clean-up to compare
    resultAnswer = currentAnagram.answerText;
    resultAnswer = [resultAnswer stringByReplacingOccurrencesOfString:@" " withString:@""];
    resultAnswer = [resultAnswer uppercaseString];
    

    if (resultAnswer.length ==  resultValue.length)
    {
        if ([resultAnswer isEqualToString:resultValue])
        {
            [self scoreThisGame];
            labelScore.text = [NSString stringWithFormat:@"%d", scoreBoard.currentGameScore];
            
            AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            [appDelegate playSoundFile:NSLocalizedString(@"SoundApplauseFileName", nil)];
            
            AHAlertView *alert = [[AHAlertView alloc] initWithTitle:NSLocalizedString(@"GameOverTitle", nil)
                                                            message:[NSString stringWithFormat:@"%@%d", NSLocalizedString(@"GameOverDescription", nil), scoreBoard.currentGameScore]];
            [alert setBackgroundImage:[UIImage imageNamed:@"AlertBackgroundImage"]];
            [alert setCancelButtonBackgroundImage:[UIImage imageNamed:@"ButtonImage"] forState:UIControlStateNormal];
            [alert setButtonBackgroundImage:[UIImage imageNamed:@"ButtonImage"] forState:UIControlStateNormal];
            [alert setCancelButtonTitle:NSLocalizedString(@"GameOverCancelButtonTitle", nil) block:^{[self playAgainCurrentLevel];}];
            [alert addButtonWithTitle:NSLocalizedString(@"GameOverNextButtonTitle", nil) block:^{[self playNextLevel];}];
            [alert setContentInsets:UIEdgeInsetsMake(12, 18, 12, 18)];
            [alert setButtonTitleTextAttributes:[AHAlertView textAttributesWithFont:[UIFont boldSystemFontOfSize:16]
                                                                    foregroundColor:[UIColor colorWithRed:43.0/255.0 green:30.0/255.0 blue:14.0/255.0 alpha:1.0]
                                                                        shadowColor:[UIColor grayColor]
                                                                       shadowOffset:CGSizeMake(0, -1)]];
            alert.dismissalStyle = AHAlertViewDismissalStyleZoomDown;
            // border radius
            [alert.layer setCornerRadius:15.0f];
            alert.layer.masksToBounds = YES;
            // border
            [alert.layer setBorderColor:[UIColor colorWithRed:28.0/255.0 green:41.0/255.0 blue:85.0/255.0 alpha:1.0].CGColor];
            [alert.layer setBorderWidth:1.0f];
            [alert show];
            [self reportScore];
            
            return TRUE;
        }
        else
        {
            AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            [appDelegate playSoundFile:NSLocalizedString(@"SoundOhNoFileName", nil)];
            
            return FALSE;
        }
    }
    else
    {
        // if there is no character in the result, then it doesn't help the user to look for more hint
        if ([currentAnagram.userResult stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
            buttonHint.enabled = TRUE;
            currentAnagram.hintsProvided = 0;
        }
        else {
            //[self getQuestionRemaining];
            // if there is no character in the question, then let the user know they haven't found the answer yet
            if ([currentAnagram.questionRemaining stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
                labelInvalidAnswer.hidden = NO;
            }
        }
        return FALSE;
    }
}

- (void)reportScore
{
    [[GCHelper defaultHelper] reportScore:scoreBoard.currentGameScore forLeaderboardID:(NSString *)[kLeaderBoardLevels objectAtIndex:[currentAnagram.levelId intValue]]];
}

- (void)scoreThisGame
{
    // score = (1 - hintsProvided/maxHintCount) * levelMaxScore
    int score = 0;
    score = [currentAnagram.maxScore intValue] +
        ((1.0 - (currentAnagram.hintsProvided / currentAnagram.maxHintCount)) * [currentAnagram.maxScore intValue]);
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
    
    // identify a random character which is not selected correctly by user
    for (indexButton=0; indexButton<currentAnagram.answerText.length; indexButton++)
    {
        buttonResult = (UIButton *)[buttonResults objectAtIndex:indexButton];
        if (![buttonResult.titleLabel.text  isEqual: @""] && buttonResult.titleLabel.text != nil) {
            currentChar = [NSString stringWithFormat:@"%c", [currentAnagram.answerText characterAtIndex:indexButton]];
            if (![buttonResult.titleLabel.text isEqualToString:currentChar]) {
                [indexArray addObject:[NSNumber numberWithInt:indexButton]];
            }
        }
    }

    // only if there is pending invalid result character, suggest answer
    if (indexArray.count > 0)
    {
        BOOL foundInQuestion = NO;
        NSNumber *tempValue = (NSNumber *)[indexArray objectAtIndex:(arc4random() % (indexArray.count + 0))];
        hintButtonChar = [tempValue intValue];
        
        // remove the random selection from the Question/Result from incorrect position
        NSString *newResult = [NSString stringWithFormat:@"%c", [currentAnagram.answerText characterAtIndex:hintButtonChar]];
        for (indexButton=0; indexButton<buttonQuestions.count; indexButton++)
        {
            buttonQuestion = (UIButton *)[buttonQuestions objectAtIndex:indexButton];
            if (![buttonQuestion.titleLabel.text  isEqual: @""] && buttonQuestion.titleLabel.text != nil) {
                if ([buttonQuestion.titleLabel.text isEqualToString:newResult]) {   // set the question as the current content of result button
                    [buttonQuestion setTitle:((UIButton *)[buttonResults objectAtIndex:hintButtonChar]).titleLabel.text forState:UIControlStateNormal];
                    foundInQuestion = YES;
                    break;
                }
            }
        }

        // check if the character required for hint is found in question
        if (!foundInQuestion) {
            for (indexButton=0; indexButton<buttonResults.count; indexButton++) {
                buttonResult = (UIButton *)[buttonResults objectAtIndex:indexButton];
                if (![buttonResult.titleLabel.text  isEqual: @""] && buttonResult.titleLabel.text != nil) {
                    if ([buttonResult.titleLabel.text isEqualToString:newResult]) {   // set the question as the current content of result button
                        [buttonResult setTitle:((UIButton *)[buttonResults objectAtIndex:hintButtonChar]).titleLabel.text forState:UIControlStateNormal];
                        break;
                    }
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
        
        [self verifyResult];
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

- (void)playAgainCurrentLevel
{
    NSLog(@"Play again button was selected.");
    
    for (int indexCount=0; indexCount<imageHolderQuestions.count; indexCount++) {
        UIImageView *thisHolderImage = [imageHolderQuestions objectAtIndex:indexCount];
        [thisHolderImage removeFromSuperview];
    }
    for (int indexCount=0; indexCount<imageHolderResults.count; indexCount++) {
        UIImageView *thisHolderImage = [imageHolderResults objectAtIndex:indexCount];
        [thisHolderImage removeFromSuperview];
    }
    for (int indexCount=0; indexCount<tiles.count; indexCount++) {
        Tile *thisTile = [tiles objectAtIndex:indexCount];
        [thisTile.image removeFromSuperview];
    }
    labelScore.text = @"0";
    buttonHint.enabled = TRUE;
    buttonQuestions = nil;
    buttonResults = nil;
    currentAnagram.questionRemaining = [currentAnagram.questionText copy];
    currentAnagram.userResult = [NSString stringWithFormat:@"%*s", currentAnagram.answerText.length, ""];
    currentAnagram.hintsProvided = 0;
    currentAnagram.maxHintCount = currentAnagram.questionText.length * [currentAnagram.hintsPercentile floatValue];
    [self loadQuestionResultHolderImages];
    [self loadAnagram];
}

- (void)playNextLevel
{
    NSLog(@"Next Level button was selected.");
    
    [self getAnagramForModeAndLevel:[NSNumber numberWithInt:currentGameMode] levelId:[NSNumber numberWithInt:[currentAnagram.levelId intValue]+1]];
    
    for (int indexCount=0; indexCount<imageHolderQuestions.count; indexCount++) {
        UIImageView *thisHolderImage = [imageHolderQuestions objectAtIndex:indexCount];
        [thisHolderImage removeFromSuperview];
    }
    for (int indexCount=0; indexCount<imageHolderResults.count; indexCount++) {
        UIImageView *thisHolderImage = [imageHolderResults objectAtIndex:indexCount];
        [thisHolderImage removeFromSuperview];
    }
    for (int indexCount=0; indexCount<tiles.count; indexCount++) {
        Tile *thisTile = [tiles objectAtIndex:indexCount];
        [thisTile.image removeFromSuperview];
    }
    labelScore.text = @"0";
    buttonHint.enabled = TRUE;
    buttonQuestions = nil;
    buttonResults = nil;
    [self loadQuestionResultHolderImages];
    [self loadAnagram];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    currentAnagram.hintsProvided = 0;
    currentAnagram.questionRemaining = [currentAnagram.questionText copy];
    currentAnagram.userResult = [NSString stringWithFormat:@"%*s", currentAnagram.answerText.length, ""];
    
    if([title isEqualToString:NSLocalizedString(@"GameOverNextButtonTitle", nil)])
    {
        [self playNextLevel];
    }
    else if([title isEqualToString:NSLocalizedString(@"GameOverCancelButtonTitle", nil)])
    {
        [self playAgainCurrentLevel];
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

#pragma mark Button Drag

#define GROW_ANIMATION_DURATION_SECONDS 0.15    // Determines how fast a piece size grows when it is moved.
#define SHRINK_ANIMATION_DURATION_SECONDS 0.15  // Determines how fast a piece size shrinks when a piece stops moving.

#pragma mark - Touch handling

/**
 Handles the start of a touch.
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSUInteger numTaps = [[touches anyObject] tapCount];
    
    NSLog(NSLocalizedString(@"Phase: Touches began", @"Phase label text for touches began"));
    // Enumerate through all the touch objects.
    NSUInteger touchCount = 0;
    for (UITouch *touch in touches) {
        // Send to the dispatch method, which will make sure the appropriate subview is acted upon.
        [self dispatchFirstTouchAtPoint:[touch locationInView:self.view] forEvent:nil];
        touchCount++;
    }
}

/**
 Checks to see which view, or views, the point is in and then calls a method to perform the opening animation, which  makes the piece slightly larger, as if it is being picked up by the user.
 */
-(void)dispatchFirstTouchAtPoint:(CGPoint)touchPoint forEvent:(UIEvent *)event
{
    for (int indexCount=0; indexCount<tiles.count; indexCount++) {
        Tile *tileIndex = [tiles objectAtIndex:indexCount];
        UIImageView *imageIndex = tileIndex.image;
        if (CGRectContainsPoint(imageIndex.frame, touchPoint)) {
            [self.view bringSubviewToFront:imageIndex];
            selectedQuestionImageIndex = indexCount;
            selectedQuestionImageOriginalPosition = CGPointMake(imageIndex.frame.origin.x, imageIndex.frame.origin.y);
            [self animateFirstTouchAtPoint:touchPoint forView:imageIndex];
            NSLog([NSString stringWithFormat:@"Selected Image index: %d", selectedQuestionImageIndex]);
            AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            [appDelegate playSoundFile:NSLocalizedString(@"SoundPickTileFileName", nil)];
            break;
        }
    }
}

/**
 Handles the continuation of a touch.
 */
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSUInteger touchCount = 0;
    NSLog(NSLocalizedString(@"Phase: Touches moved", @"Phase label text for touches moved"));
    // Enumerates through all touch objects
    for (UITouch *touch in touches) {
        // Send to the dispatch method, which will make sure the appropriate subview is acted upon
        [self dispatchTouchEvent:[touch view] toPosition:[touch locationInView:self.view]];
        touchCount++;
    }
}

/**
 Checks to see which view, or views, the point is in and then sets the center of each moved view to the new postion.
 If views are directly on top of each other, they move together.
 */
-(void)dispatchTouchEvent:(UIView *)theView toPosition:(CGPoint)position
{
    // Check to see which view, or views,  the point is in and then move to that position.
    if (selectedQuestionImageIndex != -1)
    {
        Tile *tileIndex = [tiles objectAtIndex:selectedQuestionImageIndex];
        UIImageView *imageIndex = tileIndex.image;
        imageIndex.center = position;
        NSLog([NSString stringWithFormat:@"Current index %d pos: %f, %f", selectedQuestionImageIndex, position.x, position.y]);
    }
}

/**
 Handles the end of a touch event.
 */
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(NSLocalizedString(@"Phase: Touches ended", @"Phase label text for touches ended"));
    // Enumerates through all touch object
    for (UITouch *touch in touches) {
        // Sends to the dispatch method, which will make sure the appropriate subview is acted upon
        [self dispatchTouchEndEvent:[touch view] toPosition:[touch locationInView:self.view]];
   }
}

/**
 Checks to see which view, or views,  the point is in and then calls a method to perform the closing animation, which is to return the piece to its original size, as if it is being put down by the user.
 */
-(void)dispatchTouchEndEvent:(UIView *)theView toPosition:(CGPoint)position
{
    // Check to see which view, or views, the point is in and then animate to that position.
    if (selectedQuestionImageIndex == -1)
    {
        return;
    }
    
    // check for Result holder images
    for (int indexCount=0; indexCount<imageHolderResults.count; indexCount++) {
        UIImageView *imageResult = [imageHolderResults objectAtIndex:indexCount];
        if (CGRectContainsPoint(imageResult.frame, position)) {
            if (![self isTileOnTopOfAnother:position]) {
                Tile *tileIndex = [tiles objectAtIndex:selectedQuestionImageIndex];
                [self tileMovedToIndexIn:indexCount inQuestion:NO fromIndex:tileIndex.index fromQuestion:tileIndex.isQuestion fromTileIndex:selectedQuestionImageIndex];
                UIImageView *imageIndex = tileIndex.image;
                selectedQuestionImageIndex = -1;
                selectedQuestionImageOriginalPosition = CGPointMake(0, 0);
                [self animateView:imageIndex toPosition: position];
                imageIndex.center = imageResult.center;
                NSLog([NSString stringWithFormat:@"End index %d pos in result %d", selectedQuestionImageIndex, indexCount]);
                
                AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                [appDelegate playSoundFile:NSLocalizedString(@"SoundPlaceTileFileName", nil)];
                
                BOOL result;
                result = [self verifyResult];
            }
            break;
        }
    }
    
    if (selectedQuestionImageIndex != -1) {
        // check for Question holder images
        for (int indexCount=0; indexCount<imageHolderQuestions.count; indexCount++) {
            UIImageView *imageResult = [imageHolderQuestions objectAtIndex:indexCount];
            if (CGRectContainsPoint(imageResult.frame, position)) {
                if (![self isTileOnTopOfAnother:position]) {
                    Tile *tileIndex = [tiles objectAtIndex:selectedQuestionImageIndex];
                    [self tileMovedToIndexIn:indexCount inQuestion:YES fromIndex:tileIndex.index fromQuestion:tileIndex.isQuestion fromTileIndex:selectedQuestionImageIndex];
                    UIImageView *imageIndex = tileIndex.image;
                    selectedQuestionImageIndex = -1;
                    selectedQuestionImageOriginalPosition = CGPointMake(0, 0);
                    [self animateView:imageIndex toPosition: position];
                    imageIndex.center = imageResult.center;
                    NSLog([NSString stringWithFormat:@"End index %d pos in result %d", selectedQuestionImageIndex, indexCount]);
                    
                    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                    [appDelegate playSoundFile:NSLocalizedString(@"SoundPlaceTileFileName", nil)];
                    
                    BOOL result;
                    result = [self verifyResult];
                }
                break;
            }
        }
    }
    
    if (selectedQuestionImageIndex != -1) {
        Tile *tileIndex = [tiles objectAtIndex:selectedQuestionImageIndex];
        UIImageView *imageIndex = tileIndex.image;
        selectedQuestionImageIndex = -1;
        [self animateView:imageIndex toPosition: position];
        [imageIndex setFrame:CGRectMake(selectedQuestionImageOriginalPosition.x, selectedQuestionImageOriginalPosition.y, imageIndex.frame.size.width, imageIndex.frame.size.height)];
        selectedQuestionImageOriginalPosition = CGPointMake(0, 0);
        NSLog([NSString stringWithFormat:@"End index %d pos, back to original", selectedQuestionImageIndex]);
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate playSoundFile:NSLocalizedString(@"SoundPlaceTileFileName", nil)];
        
        BOOL result;
        result = [self verifyResult];
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    //self.touchPhaseText.text = NSLocalizedString(@"Phase: Touches cancelled", @"Phase label text for touches cancelled");
    NSLog(NSLocalizedString(@"Phase: Touches cancelled", @"Phase label text for touches cancelled"));
    // Enumerates through all touch objects.
    for (UITouch *touch in touches) {
        // Sends to the dispatch method, which will make sure the appropriate subview is acted upon.
        [self dispatchTouchEndEvent:[touch view] toPosition:[touch locationInView:self.view]];
    }
}

-(BOOL)isTileOnTopOfAnother:(CGPoint)position
{
    BOOL isOnTop = NO;
    
    for (int indexCount=0; indexCount<tiles.count; indexCount++) {
        Tile *tileIndex = [tiles objectAtIndex:indexCount];
        UIImageView *imageIndex = tileIndex.image;
        if (CGRectContainsPoint(imageIndex.frame, position) && selectedQuestionImageIndex != indexCount) {
            isOnTop = YES;
            break;
        }
    }
    return isOnTop;
}

#pragma mark - Animating subviews
/**
 Scales up a view slightly which makes the piece slightly larger, as if it is being picked up by the user.
 */
-(void)animateFirstTouchAtPoint:(CGPoint)touchPoint forView:(UIImageView *)theView
{
    // Pulse the view by scaling up, then move the view to under the finger.
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:GROW_ANIMATION_DURATION_SECONDS];
    theView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    [UIView commitAnimations];
}

/**
 Scales down the view and moves it to the new position.
 */
-(void)animateView:(UIView *)theView toPosition:(CGPoint)thePosition
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:SHRINK_ANIMATION_DURATION_SECONDS];
    // Set the center to the final postion.
    theView.center = thePosition;
    // Set the transform back to the identity, thus undoing the previous scaling effect.
    theView.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
    NSLog([NSString stringWithFormat:@"End Position4: %f, %f", theView.center.x, theView.center.y]);
}

@end
