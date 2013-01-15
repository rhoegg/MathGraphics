//
//  CATemporalLayer.h
//  MathGraphics
//
//  Created by Ryan Hoegg on 5/29/12.
//  Copyright 2012 Brightdome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface CATemporalLayer : CALayer {
    CGFloat time;
}

@property (nonatomic) CGFloat time;

@end
