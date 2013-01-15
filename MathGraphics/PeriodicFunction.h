//
//  PeriodicFunction.h
//  MathGraphics
//
//  Created by Ryan Hoegg on 5/29/12.
//  Copyright 2012 Brightdome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Function.h"

// Function of the form n sin(ax + b) + c + (n2 sin(a2x + b2) + c2) + ... 
@interface PeriodicFunction : Function {
    float amplitude; // n
    float scale; // a
    float xshift; // b
    float yshift; // c
    
    float velocity; // for animation
    
    PeriodicFunction *addend; // one or more periodic functions to be added to this one, recursively defined
}

@property float amplitude;
@property float scale;
@property float xshift;
@property float yshift;
@property float velocity;
@property (nonatomic, retain) PeriodicFunction *addend;

+(PeriodicFunction *) initRandomWithProbabilityToContinue: (float) p complexity: (int) c;
-(float) peak;

@end
