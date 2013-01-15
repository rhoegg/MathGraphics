//
//  AnimatedPolarGraphView.h
//  MathGraphics
//
//  Created by Ryan Hoegg on 5/28/12.
//  Copyright 2012 Brightdome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class PeriodicFunction, CATemporalLayer;


@interface AnimatedPolarGraphLayerDelegate : NSObject {
    PeriodicFunction *originFunction;
    PeriodicFunction *radiusFunction;
    PeriodicFunction *thetaFunction;
    float renderTime;
    int steps;
}
@property (nonatomic, retain) PeriodicFunction *originFunction;
@property (nonatomic, retain) PeriodicFunction *radiusFunction;
@property (nonatomic, retain) PeriodicFunction *thetaFunction;

- (void)drawLayer:(CALayer*)layer inContext:(CGContextRef) context;
@end

// Plan:
// 1. Animate the xshifts (learn Core Animation) - DONE
// 2. Stroke with a pretty brush (maybe monochrome radial alpha gradient) - POSTPONED
// 3. Go parametric (use another function for theta) 
// 4. Go 3D?  (two thetas) - r = cos(theta2), z = sin(theta2), x = r * cos(theta), y = r * sin(theta)
// 5. Animate a traveler?  position is linear along theta for now.
@interface AnimatedPolarGraphView : UIView {
    float t;
    PeriodicFunction *radiusFunction;
    CATemporalLayer *graphLayer;
    AnimatedPolarGraphLayerDelegate *layerDelegate;
}

@property float t;

@end
