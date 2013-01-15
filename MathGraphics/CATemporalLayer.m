//
//  CATemporalLayer.m
//  MathGraphics
//
//  Created by Ryan Hoegg on 5/29/12.
//  Copyright 2012 Brightdome. All rights reserved.
//

#import "CATemporalLayer.h"


@implementation CATemporalLayer

@synthesize time;

+ (BOOL) needsDisplayForKey:(NSString *)key {
    if ([key isEqualToString:@"time"]) {
        return YES;
    } else {
        return [super needsDisplayForKey:key];
    }
}

- (id) initWithLayer:(id)layer {
    self = [super initWithLayer:layer];
    if (self != nil) {
        if ([layer isKindOfClass:[CATemporalLayer class]]) {
            CATemporalLayer *other = (CATemporalLayer *) layer;
            self.time = other.time;
        }
    }
    return self;
}

@end
