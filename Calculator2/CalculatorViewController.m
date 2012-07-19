//
//  CalculatorViewController.m
//  Calculator2
//
//  Created by Oscar Cortez Gómez on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define MINIDISP_LENGTH 35
#define NUMBER(n) [NSNumber numberWithDouble:n]


#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController ()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL userEnteredADot;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSDictionary *testVariableValues;

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize miniDisplay = _miniDisplay;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize userEnteredADot = _userEnteredADot;
@synthesize brain = _brain;
@synthesize testVariableValues = _testVariableValues;

-(CalculatorBrain *) brain
{
    if (!_brain) {
        _brain = [[CalculatorBrain alloc] init];
    }
    
    return _brain;
}

- (IBAction)digitPressed:(UIButton *)sender 
{
    NSString *digit = sender.currentTitle;
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    }
    else {
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }

}

- (IBAction)enterPressed 
{
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userEnteredADot = NO;
    
    [self updateUI];
}

- (IBAction)dotPressed:(UIButton *)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber && !self.userEnteredADot) {
        self.display.text = [self.display.text stringByAppendingString: sender.currentTitle];
        self.userEnteredADot = YES; //We introduced a "userEnteredADot" property so that the program knows when the user has used the dot
        
        
    }
    else if (!self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = @"0.";
        self.userEnteredADot = YES;
        self.userIsInTheMiddleOfEnteringANumber = YES;
        
    }

}

- (IBAction)operationPressed:(UIButton *)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    
    double result = [self.brain performOperation:sender.currentTitle];
    NSString *resultString = [NSString stringWithFormat:@"%g", result];
    self.display.text = resultString;
    
    [self updateUI];
}

- (IBAction)erase 
{
    [self.brain eraseStack];
    self.display.text = @"0";
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userEnteredADot = NO;
    self.miniDisplay.text = @"";

}

- (IBAction)backspace 
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        if ([self.display.text length] > 1) { 
            // We use this condition to prevent a crash from the app when the length of the string reach 0 and the substringToIndex method gets executed
            if ([[self.display.text substringFromIndex:[self.display.text length] - 1] isEqualToString:@"."])
                self.userEnteredADot = NO;
            self.display.text = [self.display.text substringToIndex:[self.display.text length] - 1];
            
        }
        else { // I use a special case when the string's length is 1 (it will never be negative that's why I use just "else" ) just to display a 0 and not leaving the display in blank
            self.display.text = @"0";
            self.userIsInTheMiddleOfEnteringANumber = NO;
            self.userEnteredADot = NO;
            
        }
    }
    else {
        self.display.text = @"0";
        self.userIsInTheMiddleOfEnteringANumber = NO;
        
    }

}

- (IBAction)variablePressed:(UIButton *)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber) [self enterPressed];
    
    self.display.text = sender.currentTitle;
    
    [self.brain pushVariable:sender.currentTitle];
    
    self.userIsInTheMiddleOfEnteringANumber = NO;
    
    [self updateUI];
}


- (IBAction)undoPressed 
{
    [self backspace];
    if (!self.userIsInTheMiddleOfEnteringANumber) {
        [self.brain removeLastObjectOfStack];
        double result = [CalculatorBrain runProgram:self.brain.program];
        self.display.text = [NSString stringWithFormat:@"%g", result];
        [self updateUI];
    }
    
}

-(void) updateUI
{
    if ([self.miniDisplay.text length] < MINIDISP_LENGTH)  
        self.miniDisplay.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
}

@end
