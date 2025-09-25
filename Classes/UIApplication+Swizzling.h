//
//  UIApplication+Swizzling.h
//  FLEX
//
//  Created by minhnv1 on 25/9/25.
//  Copyright © 2025 Flipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (Swizzling)

/// Enables shake gesture swizzling to intercept shake events
+ (void)flex_enableShakeSwizzling;

/// Disables shake gesture swizzling
+ (void)flex_disableShakeSwizzling;

/// Override this method to customize shake behavior
- (void)flex_motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event;

/// Returns whether shake swizzling is currently enabled
+ (BOOL)isShakeSwizzlingEnabled;

@end
