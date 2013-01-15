//
//  PeriodicFunction.m
//  MathGraphics
//
//  Created by Ryan Hoegg on 5/29/12.
//  Copyright 2012 Brightdome. All rights reserved.
//

#import "PeriodicFunction.h"

float randBetween(float min, float max) {
    return (float) random() / RAND_MAX * (max - min) + min;
}

float randPositiveSkew(int scale) {
    float x = 0;
    for (int i = 0; i < scale; i++) {
        x += powf((float) random() / RAND_MAX, 2);
    }
    return x;
}

@interface ZeroFunction : PeriodicFunction
+(ZeroFunction *) zero;
@end

@implementation ZeroFunction

-(float) evaluateFor:(float)x atTime: (float) t {
    return 0.0;
}

-(float) peak {
    return 0.0;
}

+(ZeroFunction *) zero {
    return [[[ZeroFunction alloc] init] autorelease];
}

@end

@implementation PeriodicFunction

@synthesize amplitude, scale, xshift, yshift, velocity, addend;

+(PeriodicFunction *) initRandomWithProbabilityToContinue: (float) p complexity: (int) c {
    PeriodicFunction *f = [[PeriodicFunction alloc] init];
    f.amplitude = randBetween(0.25, 1.0);
    f.scale = floorf(randPositiveSkew(c)) + 1;
    f.xshift = randBetween(-1 * M_2_PI, M_2_PI);
    f.yshift = randBetween(-1 * (1 - f.amplitude), 1 - f.amplitude);
    f.velocity = randBetween(0.0, 2.0);
    NSLog(@"f: n=%.3f, a=%.3f, b=%.3f, c=%.3f", f.amplitude, f.scale, f.xshift, f.yshift); 
    
    if (randBetween(0.0, 1.0) < p) {
        f.addend = [[PeriodicFunction initRandomWithProbabilityToContinue: p / 2 complexity: c] retain];
    } else {
        f.addend = [[ZeroFunction zero] retain];
    }
    return f;
}

// n sin(ax + b) + c
-(float) evaluateFor:(float)x atTime:(float)t {
    return amplitude * sinf(scale * x + xshift + t * velocity) + yshift + [addend evaluateFor:x atTime:t];
}

-(float) peak {
    return amplitude + ABS(yshift) + [addend peak];
}

- (void) dealloc {
    [addend release];
    [super dealloc];
}

@end
