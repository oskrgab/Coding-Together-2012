//
//  CalculatorBrain.h
//  Calculator2
//
//  Created by Oscar Cortez Gómez on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

-(void) pushVariable: (NSString *) variable;
-(void) pushOperand: (double) operand;
-(double) performOperation: (NSString *) operation;
-(void) eraseStack;
-(void) removeLastObjectOfStack;

@property (readonly) id program; // I don't want to introduce another class so we use a property with id

+ (double) runProgram: (id) program;
+ (NSString *) descriptionOfProgram: (id) program;
+ (double) runProgram:(id)program usingVariables: (NSDictionary *) variableValues;
+ (NSSet *) variablesUsedInProgram: (id) program; 

@end
