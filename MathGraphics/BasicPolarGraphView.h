//
//  BasicPolarGraphView.h
//  MathGraphics
//
//  Created by Ryan Hoegg on 5/27/12.
//  Copyright 2012 Brightdome. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PeriodicFunction;

@interface BasicPolarGraphView : UIView {
    PeriodicFunction *radiusFunction;
}

-(NSArray *) polarToCartesian: (NSArray *) polarPoints;
@end
