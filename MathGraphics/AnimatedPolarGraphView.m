//
//  AnimatedPolarGraphView.m
//  MathGraphics
//
//  Created by Ryan Hoegg on 5/28/12.
//  Copyright 2012 Brightdome. All rights reserved.
//

#import "AnimatedPolarGraphView.h"
#import "PeriodicFunction.h"
#import "CATemporalLayer.h"

@implementation AnimatedPolarGraphLayerDelegate {
}

-(id) init {
    self = [super init];
    if (self != nil) {
        renderTime = 0.0;
        steps = 750;
    }
    return self;
}

@synthesize originFunction, radiusFunction, thetaFunction;

- (CGPoint) convertPolarPoint: (CGPoint) polarPoint {
    float x = cosf(polarPoint.x) * polarPoint.y;
    float y = sinf(polarPoint.x) * polarPoint.y;
    return CGPointMake(x, y);
}

-(NSArray *) polarToCartesian: (NSArray *) polarPoints {
    NSMutableArray *cartesianPoints = [[[NSMutableArray alloc] init] autorelease];
    for (NSValue *val in polarPoints) {
        CGPoint polarPoint = [val CGPointValue];
        [cartesianPoints addObject: [NSValue valueWithCGPoint: [self convertPolarPoint:polarPoint]]];
    }
    return cartesianPoints;
}

-(NSArray *) plotPolarFunction: (PeriodicFunction *) function atTime: (float) t overSteps: (int) steps {
    NSMutableArray *polarPoints = [[[NSMutableArray alloc] init] autorelease];
    
    for (int i = 0; i < steps; i++) {
        float theta = (2.0 * M_PI / steps) * i;
        float radius = [function evaluateFor: theta atTime: t] * (1 / [function peak]); // normalize using the estimated peak
        [polarPoints addObject: [NSValue valueWithCGPoint: CGPointMake(theta, radius)]];
    }
    
    return polarPoints;
}

-(NSArray *) applyThetaFunction: (NSArray *) polarPoints atTime: (float) t {
    NSMutableArray *points = [[[NSMutableArray alloc] init] autorelease];
    for (NSValue *value in polarPoints) {
        CGPoint originalPoint = [value CGPointValue];
        originalPoint.x = [thetaFunction evaluateFor:originalPoint.x atTime:t];
        [points addObject:[NSValue valueWithCGPoint:originalPoint]];        
    }
    return points;
}

- (void) drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
    if ([layer isKindOfClass:[CATemporalLayer class]]) {
        NSDate *started = [NSDate date];
        CATemporalLayer *tlayer = (CATemporalLayer *) layer;
        //NSLog(@"Drawing at time %.2f", tlayer.time);
        CGContextScaleCTM(context, layer.bounds.size.width / 2, -1 * layer.bounds.size.width / 2);
        CGContextTranslateCTM( context, 1.0, -1.0 * layer.bounds.size.height / layer.bounds.size.width);
        CGContextScaleCTM(context, 1 / (1 + [originFunction peak]), 1 / (1 + [originFunction peak]));
        
        CGContextSetLineWidth(context, 2 / layer.bounds.size.width);
        CGContextSetGrayStrokeColor( context, 0.3, 1.0 );
        CGContextBeginPath( context );
        CGContextMoveToPoint( context, -1.0, 1.0 );
        CGContextAddLineToPoint( context, 1.0, 1.0 );
        CGContextAddLineToPoint( context, 1.0, -1.0 );
        CGContextAddLineToPoint( context, -1.0, -1.0 );
        CGContextAddLineToPoint( context, -1.0, 1.0 );
        CGContextStrokePath( context );    
    
        if (renderTime > 0) {
            float max_adj = 0.05;
            float adjustment = (1.0/45.0) / renderTime;
            if (fabsf(adjustment - 1) > max_adj) {
                adjustment = max_adj * ((adjustment - 1) / fabsf(adjustment - 1)) + 1; // turns this into 1 +/- max_adj
            }
            steps = (int) steps * adjustment;
            NSLog(@"Adjusted steps by %f to %d", adjustment, steps);
        }
        const float timeScale = M_PI * 2 * 3;
        float time = sinf(tlayer.time * 2 * M_PI) * timeScale;
        NSArray *originPoints = [self polarToCartesian:[self plotPolarFunction: originFunction atTime: time overSteps: steps]];
        NSArray *polarPoints = [self plotPolarFunction:radiusFunction atTime:time overSteps:steps];
        
        NSArray *points = [self polarToCartesian: [self applyThetaFunction:polarPoints atTime:time]];

        CGMutablePathRef curvePath = CGPathCreateMutable();
        
        for (int i = 0; i < steps; i++) {
            CGPoint point = [[points objectAtIndex: i] CGPointValue];
            CGPoint origin = [[originPoints objectAtIndex: i] CGPointValue];
            
            if(i == 0) {
                CGPathMoveToPoint(curvePath, NULL, origin.x + point.x, origin.y + point.y);
            } else {
                CGPathAddLineToPoint(curvePath, NULL, origin.x + point.x, origin.y + point.y); // TODO: replace with CGPathAddLines() ?
            }
        }

        CGPathCloseSubpath(curvePath);
        
        CGContextAddPath(context, curvePath);

        CGContextSetLineWidth(context, 100 / layer.bounds.size.width);
        CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 0.25);
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        CGContextStrokePath( context );
        
        CGContextAddPath(context, curvePath);

        CGContextSetLineWidth(context, 65 / layer.bounds.size.width);
        CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 0.5);
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        CGContextStrokePath( context );
    
        CGContextAddPath(context, curvePath);
        
        CGContextSetLineWidth(context, 25 / layer.bounds.size.width);
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.5);
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        CGContextStrokePath( context );
        
        renderTime = [[NSDate date] timeIntervalSinceDate: started];
        NSLog(@"Frame rendered in %f", renderTime);
    }
}

- (void) dealloc {
    [radiusFunction release];
    [thetaFunction release];
    [super dealloc];
}
@end

@implementation AnimatedPolarGraphView {
}

@synthesize t;

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if (self != nil) {
        srandom(time(NULL));
        self.layer.backgroundColor = UIColor.blackColor.CGColor;
        graphLayer = [[CATemporalLayer layer] retain];
        graphLayer.frame = self.layer.frame;
        graphLayer.opaque = NO;
        [graphLayer setNeedsDisplay];
        layerDelegate = [[[AnimatedPolarGraphLayerDelegate alloc] init] retain];
        graphLayer.delegate = layerDelegate;
        [self.layer addSublayer:graphLayer];
        
        layerDelegate.originFunction = [PeriodicFunction initRandomWithProbabilityToContinue:0.5 complexity: 2];
        layerDelegate.radiusFunction = [PeriodicFunction initRandomWithProbabilityToContinue:1.0 complexity: 3];
        layerDelegate.thetaFunction = [PeriodicFunction initRandomWithProbabilityToContinue:0.6 complexity:2];

        CABasicAnimation *graphAnimation = [CABasicAnimation animationWithKeyPath:@"time"];
        graphAnimation.duration = 60.0;
        graphAnimation.repeatCount = 60.0; // an hour for now
        graphAnimation.byValue = [NSNumber numberWithFloat: 1.0];
        graphAnimation.fillMode = kCAFillModeForwards;
        graphAnimation.removedOnCompletion = NO;
        
        [graphLayer addAnimation:graphAnimation forKey:@"graphAnimation"];

        [NSTimer scheduledTimerWithTimeInterval:1.0/30 target:self selector:@selector(setNeedsDisplay) userInfo:nil repeats:TRUE];
    }
    return self;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [layerDelegate.radiusFunction release];
    layerDelegate.radiusFunction = [PeriodicFunction initRandomWithProbabilityToContinue:1.0 complexity: 11];
    [layerDelegate.thetaFunction release];
    layerDelegate.thetaFunction = [PeriodicFunction initRandomWithProbabilityToContinue:0.6 complexity:6];
}

- (void)dealloc
{
    [graphLayer release];
    [layerDelegate release];
    [radiusFunction release];
    [super dealloc];
}

@end
