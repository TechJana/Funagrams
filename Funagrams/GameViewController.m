//
//  GameViewController.m
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 1/24/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController ()

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
//@synthesize gameCenterManager;

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

    // Identify the mainMenu ViewController to get the ScoreBoard object
    NSArray* controllers = self.navigationController.viewControllers;
    ViewController* firstViewController = [controllers objectAtIndex:0];
    scoreBoard = firstViewController.gameScoreBoard;
    currentAnagram = [[Anagram alloc] init];
    questionMaxLength = 0;

    [self loadQuestionResultButtons];
    [self getAnagram];
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
    [self loadHint];
    
    if (labelHint.hidden == true) {
        labelHint.hidden = false;
        labelHintValue.hidden = false;
    }
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
    
    result = [NSString stringWithFormat:@"%@%*s", result, currentAnagram.question.length-result.length, ""];;
    
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
#endif

    // get Anagram which doesn't exceed questionMaxLength
    //questionMaxLength;
}

- (void)loadQuestionResultButtons
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
    [buttonThis.titleLabel setFont:[UIFont systemFontOfSize:25]];
}

- (void)loadHint
{
    
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
        NSLog(@"Error 10001: Anagram's length is more than '%d' for this device", questionMaxLength);
    }
    
    // load hint
    labelHintValue.text = currentAnagram.hint;
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
    int indexButton;
    NSString *resultValue=@"", *resultAnswer=@"";
    UIButton *buttonThis;
    
    // concatenate the values in result button
    for (indexButton=0; indexButton<buttonResults.count; indexButton++) {
        buttonThis = (UIButton *)[buttonResults objectAtIndex:indexButton];
        if (![buttonThis.titleLabel.text  isEqual: @""] && buttonThis.titleLabel.text != nil) {
            resultValue = [resultValue stringByAppendingString:buttonThis.titleLabel.text];
        }
    }
    
    // clean-up to compare
    resultValue = [resultValue stringByReplacingOccurrencesOfString:@" " withString:@""];
    resultValue = [resultValue uppercaseString];
    
    // clean-up to compare
    resultAnswer = currentAnagram.result;
    resultAnswer = [resultAnswer stringByReplacingOccurrencesOfString:@" " withString:@""];
    resultAnswer = [resultAnswer uppercaseString];
    
    if ([resultAnswer isEqualToString:resultValue])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"you must be smart"
                                                        message:@"You cracked it!!!"
                                                       delegate:nil
                                              cancelButtonTitle:@"hi5"
                                              otherButtonTitles:nil];
        [alert show];
        
        return TRUE;
    }
    else
    {
        return FALSE;
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
