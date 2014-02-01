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
    
#if TEST_MODE_DEF
    currentAnagram.question = @"DEULLIFLUARP";
    currentAnagram.result = @"Pleural fluid";
    currentAnagram.hint = @"Liquid in Anatomy";
    currentAnagram.level = 5;
    currentAnagram.levelDescription = @"Level 5";
#endif
    
    [self loadQuestionResultButtons];
    [self loadAnagram];
    [self verifyResult];
    
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
            selectedQuestion = [buttonQuestions indexOfObject:buttonThis];
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
            selectedResult = [buttonResults indexOfObject:buttonThis];
        }
    }
}

- (void)loadQuestionResultButtons
{
    UIButton *buttonIndex;
    int indexButton=0, buttonCount=0, buttonSpacingWidth=-3;
    CGRect screenRect = [[UIScreen mainScreen] bounds];

    buttonQuestions = [[NSMutableArray alloc] init];
    buttonResults = [[NSMutableArray alloc] init];

    buttonCount=( screenRect.size.height - (2 * buttonSampleQuestion.frame.origin.x) ) / (buttonSampleQuestion.frame.size.width + buttonSpacingWidth);
    
    // CREATE QUESTION BUTTONS
    // Archive the button to unarchive a copy every time
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject: buttonSampleQuestion];
    
    for (indexButton=0; indexButton<buttonCount; indexButton++) {
        // Unarchive a copy of the Archived button
        buttonIndex = [NSKeyedUnarchiver unarchiveObjectWithData: archivedData];
        
        // Moving X position with the required spacing
        buttonIndex.frame = CGRectMake(buttonIndex.frame.origin.x + ( indexButton * (buttonIndex.frame.size.width + buttonSpacingWidth) ), buttonIndex.frame.origin.y, buttonIndex.frame.size.width, buttonIndex.frame.size.height);
        
        // Reset the value of the button to empty string to load the required question
        [buttonIndex setTitle:@"" forState:UIControlStateNormal];
        [buttonIndex addTarget:self action:@selector(buttonQuestions_click:) forControlEvents:UIControlEventTouchUpInside];
        
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
        [buttonIndex setTitle:@"▢" forState:UIControlStateNormal];
        [buttonIndex addTarget:self action:@selector(buttonResults_click:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:buttonIndex];
        
        // Add the new button to the array for future use
        [buttonResults insertObject:buttonIndex atIndex:buttonResults.count];
    }
    
    buttonSampleQuestion.hidden = true;
    buttonSampleResult.hidden = true;
}

- (void)loadHint
{
    
}

- (void)loadAnagram
{
    //@"▢"
    int indexButton;
    
    // load question
    for (indexButton=0; (indexButton<buttonQuestions.count && indexButton<currentAnagram.question.length); indexButton++) {
        UIButton *buttonIndex = [buttonQuestions objectAtIndex:indexButton];
        [buttonIndex setTitle:[currentAnagram.question substringWithRange:NSMakeRange(indexButton, 1)] forState:UIControlStateNormal];
    }
    
    // load answer positioning
    for (indexButton=0; (indexButton<buttonResults.count && indexButton<currentAnagram.result.length); indexButton++) {
        if ([currentAnagram.result characterAtIndex:indexButton] == ' ')
        {
            UIButton *buttonIndex = [buttonResults objectAtIndex:indexButton];
            [buttonIndex setTitle:@" " forState:UIControlStateNormal];
            buttonIndex.enabled = false;
        }
    }
    
    // load hint
    labelHintValue.text = currentAnagram.hint;
}

- (void)verifyResult
{
    
}

@end
