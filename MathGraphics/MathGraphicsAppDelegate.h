//
//  MathGraphicsAppDelegate.h
//  MathGraphics
//
//  Created by Ryan Hoegg on 5/27/12.
//  Copyright 2012 Brightdome. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MathGraphicsViewController;

@interface MathGraphicsAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet MathGraphicsViewController *viewController;

@end
