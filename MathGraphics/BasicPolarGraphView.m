//
//  BasicPolarGraphView.m
//  MathGraphics
//
//  Created by Ryan Hoegg on 5/27/12.
//  Copyright 2012 Brightdome. All rights reserved.
//

#import "BasicPolarGraphView.h"
#import "PeriodicFunction.h"

@implementation BasicPolarGraphView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self != nil)
    {
        self.backgroundColor = [UIColor blackColor];
        self.opaque = YES;
        self.clearsContextBeforeDrawing = YES;
        
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    radiusFunction = [PeriodicFunction initRandomWithProbabilityToContinue:1.0 complexity: 11];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, rect.size.width / 2, -1 * rect.size.width / 2);
    CGContextTranslateCTM( context, 1.0, -1.0 * rect.size.height / rect.size.width);
    
    CGContextSetLineWidth(context, 2 / rect.size.width);
    CGContextSetGrayStrokeColor( context, 0.3, 1.0 );
    CGContextBeginPath( context );
    CGContextMoveToPoint( context, -1.0, 1.0 );
    CGContextAddLineToPoint( context, 1.0, 1.0 );
    CGContextAddLineToPoint( context, 1.0, -1.0 );
    CGContextAddLineToPoint( context, -1.0, -1.0 );
    CGContextAddLineToPoint( context, -1.0, 1.0 );
    CGContextStrokePath( context );

    int steps = 300;
    NSMutableArray *polarPoints = [[[NSMutableArray alloc] init] autorelease];
    
    for (int i = 0; i < steps; i++) {
        float theta = (2.0 * M_PI / steps) * i;
        float radius = [radiusFunction evaluateFor: theta atTime: 0.0] * (1 / [radiusFunction peak]); // normalize using the estimated peak
        [polarPoints addObject: [NSValue valueWithCGPoint: CGPointMake(theta, radius)]];
    }
    
    CGContextSetLineWidth(context, 6 / rect.size.width);
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 0.8);

    NSArray *points = [self polarToCartesian: polarPoints];
    
    for (int i = 0; i < steps; i++) {
        CGPoint point = [[points objectAtIndex: i] CGPointValue];
        //NSLog( @"Plotting %f, %f", point.x, point.y);
        
        if(i == 0) {
            CGContextMoveToPoint(context, point.x, point.y);
        } else {
            CGContextAddLineToPoint(context, point.x, point.y);
        }
    }
    CGPoint origin = [[points objectAtIndex: 0] CGPointValue];
    CGContextAddLineToPoint( context, origin.x, origin.y);
    CGContextStrokePath( context );
}

-(NSArray *) polarToCartesian: (NSArray *) polarPoints {
    NSMutableArray *cartesianPoints = [[[NSMutableArray alloc] init] autorelease];
    for (NSValue *val in polarPoints) {
        CGPoint polarPoint = [val CGPointValue];
        float x = cosf(polarPoint.x) * polarPoint.y;
        float y = sinf(polarPoint.x) * polarPoint.y;
        [cartesianPoints addObject: [NSValue valueWithCGPoint: CGPointMake(x, y)]];
    }
    return cartesianPoints;
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setNeedsDisplay];
}

- (void)dealloc
{
    [super dealloc];
}

@end
