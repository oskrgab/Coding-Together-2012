//
//  CalculatorBrain.m
//  Calculator2
//
//  Created by Oscar Cortez Gómez on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

#define OPERATIONS [NSSet setWithObjects: @"+", @"*", @"-", @"/", @"sin", @"cos", @"sqrt", @"π", @"+ / -",nil]
#define TWOOPERANDOPS [NSSet setWithObjects: @"+", @"*", @"-", @"/", nil]
#define ONEOPERANDOPS [NSSet setWithObjects: @"sin", @"cos", @"sqrt", @"+ / -",nil]
#define NOOPERANDOPPS [NSSet setWithObjects: @"π",nil]



@interface CalculatorBrain ()

@property (nonatomic, strong) NSMutableArray *programStack; 

@end

@implementation CalculatorBrain
@synthesize programStack = _programStack;

-(NSMutableArray *) programStack
{
    if (_programStack == nil) {
        _programStack = [[NSMutableArray alloc] init];
    }
    
    return _programStack;
}


-(void) pushOperand: (double) operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

-(void) pushVariable:(NSString *)variable
{
    [self.programStack addObject:variable];
}

-(double) performOperation: (NSString *) operation
{
    [self.programStack addObject:operation]; // I have the operations in the stack
    return [CalculatorBrain runProgram:self.programStack];
}

- (id) program // in readonly properties I Don't have to implement the setter just the getter
{
    return [self.programStack copy]; // Here we don't want to give our internal programStack to someone else so we make a copy of it in the instant it is called
}

+ (NSString *) descriptionOfProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    NSString *description = @"";
    
    while ([stack count]) {
        description = [description stringByAppendingString:[self descriptionOfTopOfStack:stack]];
        if ([stack count])
            description = [description stringByAppendingString:@","];
    }
    
    return description;
}

+ (NSString *) descriptionOfTopOfStack: (NSMutableArray *) stack 
{
    NSString *description = @"";
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        description = [NSString stringWithString: [topOfStack stringValue]];
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        if ([self isOperation:topOfStack]) {
            
            if ([self isTwoOperandOperation:topOfStack]) {
                
                NSString *firstOperand, *secondOperand;
                
                id nextOperation1 = [stack lastObject];                 // Here I take the next operation (if it is an operation) to know what operation will perform next so that I can add parentheses if it is a "+" or "-" 
                secondOperand = [self descriptionOfTopOfStack:stack];
                id nextOperation2 = [stack lastObject];                 // Same here
                firstOperand = [self descriptionOfTopOfStack:stack];
                
                if ([nextOperation1 isKindOfClass:[NSString class]])
                    if ([nextOperation1 isEqualToString:@"+"] || [nextOperation1 isEqualToString:@"-"])
                        secondOperand = [NSString stringWithFormat:@"(%@)",secondOperand];
                
                if ([nextOperation2 isKindOfClass:[NSString class]])
                    if ([nextOperation2 isEqualToString:@"+"] || [nextOperation2 isEqualToString:@"-"])
                        firstOperand = [NSString stringWithFormat:@"(%@)",firstOperand];
                
                description = [NSString stringWithFormat:@"%@ %@ %@", firstOperand, topOfStack, secondOperand];
            }
            else if ([self isOneOperandOperation:topOfStack]) {
                description = [NSString stringWithFormat:@"%@(%@)", topOfStack, [self descriptionOfTopOfStack:stack]];
            }
            else if ([self isNoOperandOperation:topOfStack]) {
                description = [NSString stringWithString:topOfStack];
            }
            
            [description stringByReplacingOccurrencesOfString:@"," withString:@""];
            
        }
        
        
        else {
            description = [NSString stringWithString:topOfStack]; // is a variable
        }
    }
    
    
    return description;
}

+ (BOOL) isNoOperandOperation: (NSString *) operation 
{
    NSSet *allOperations = NOOPERANDOPPS;
    return [allOperations containsObject:operation];
}

+ (BOOL) isOneOperandOperation: (NSString *) operation
{
    NSSet *allOperations = ONEOPERANDOPS;
    return [allOperations containsObject:operation];
}

+ (BOOL) isTwoOperandOperation: (NSString *) operation
{
    NSSet *allOperations = TWOOPERANDOPS;
    return [allOperations containsObject:operation];
}
+ (BOOL) isOperation: (NSString *) operation
{
    NSSet *allOperations = OPERATIONS;
    return [allOperations containsObject:operation];
}

+ (double) popOperandOffStack:(NSMutableArray *) stack
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack doubleValue];
    }
    
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operation = topOfStack;
        
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffStack:stack] + [self popOperandOffStack:stack];
        }
        else if ([@"*" isEqualToString:operation]){
            result = [self popOperandOffStack:stack] * [self popOperandOffStack:stack];
        }
        else if ([@"-" isEqualToString:operation]) {
            double subtrahend = [self popOperandOffStack:stack];
            result = [self popOperandOffStack:stack] - subtrahend;
        }
        else if ([@"/" isEqualToString:operation]) {
            double divisor = [self popOperandOffStack:stack];
            if (divisor) {
                result = [self popOperandOffStack:stack] / divisor;
            }
        }
        else if ([@"sin" isEqualToString:operation]) {
            result = sin([self popOperandOffStack:stack]);
        }
        else if ([@"cos" isEqualToString:operation]) {
            result = cos([self popOperandOffStack:stack]);
        }
        else if ([@"sqrt" isEqualToString:operation]) {
            double operand;
            operand = [self popOperandOffStack:stack];
            result = sqrt(operand);
        }
        else if ([@"π" isEqualToString:operation]) {
            result = M_PI;
        }
        else if ([@"+ / -" isEqualToString:operation]) {
            result = - [self popOperandOffStack:stack];
        }
        
        
    }
    
    return result;
}

+ (double) runProgram:(id)program
{
    return [self runProgram:program usingVariables:nil];
    
}

+ (double) runProgram:(id)program usingVariables:(NSDictionary *)variableValues
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    NSSet *usedVariables = [self variablesUsedInProgram:program];
    
    for (NSUInteger i = 0; i < [stack count] ; ++i) {
        
        id currentObject = [stack objectAtIndex:i];
        
        if ([currentObject isKindOfClass:[NSString class]])
            for (NSString *key in usedVariables) {
                
                if ([currentObject isEqualToString:key]) {
                    
                    if ([variableValues objectForKey:key]) {
                        [stack replaceObjectAtIndex:i withObject:[variableValues objectForKey:key]];
                        break;
                    }
                    else {
                        [stack replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:0]]; 
                        break;
                    }
                }
                
            }
    }
    
    return [self popOperandOffStack:stack];
}

+ (NSSet *) variablesUsedInProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }

    NSMutableSet *variables = [[NSMutableSet alloc] init];
    
    if ([program isKindOfClass:[NSArray class]])
        for (id obj in program) 
            if ([obj isKindOfClass:[NSString class]])
                if (![self isOperation:obj])
                      [variables addObject:obj];
    
    
    if ([variables count])
        return variables;
    else 
        return nil;
    
}

-(void) eraseStack
{
    [self.programStack removeAllObjects];
}

-(void) removeLastObjectOfStack
{
    if ([self.programStack count]) [self.programStack removeLastObject];
}
@end