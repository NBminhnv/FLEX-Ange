//
//  UIApplication+Swizzling.m
//  FLEX
//
//  Created by minhnv1 on 25/9/25.
//  Copyright © 2025 Flipboard. All rights reserved.
//

#import "UIApplication+Swizzling.h"
#import <objc/runtime.h>
#import "FLEXManager.h"

static BOOL isShakeSwizzlingEnabled = NO;

@implementation UIApplication (Swizzling)

+ (void)flex_enableShakeSwizzling {
    if (isShakeSwizzlingEnabled) {
        return; // Already enabled
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(motionEnded:withEvent:);
        SEL swizzledSelector = @selector(flex_motionEnded:withEvent:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        // If the original method doesn't exist, add it first
        if (!originalMethod) {
            // Add a default implementation if motionEnded:withEvent: doesn't exist
            IMP defaultImplementation = imp_implementationWithBlock(^(id self, UIEventSubtype motion, UIEvent *event) {
                // Default empty implementation
            });
            class_addMethod(class, originalSelector, defaultImplementation, "v@:i@");
            originalMethod = class_getInstanceMethod(class, originalSelector);
        }
        
        BOOL didAddMethod = class_addMethod(class,
                                          originalSelector,
                                          method_getImplementation(swizzledMethod),
                                          method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                              swizzledSelector,
                              method_getImplementation(originalMethod),
                              method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
        isShakeSwizzlingEnabled = YES;
    });
}

+ (void)flex_disableShakeSwizzling {
    if (!isShakeSwizzlingEnabled) {
        return; // Already disabled
    }
    
    // Re-swizzle to restore original behavior
    Class class = [self class];
    
    SEL originalSelector = @selector(motionEnded:withEvent:);
    SEL swizzledSelector = @selector(flex_motionEnded:withEvent:);
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    if (originalMethod && swizzledMethod) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
    isShakeSwizzlingEnabled = NO;
}

- (void)flex_motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    // Handle shake gesture
    if (motion == UIEventSubtypeMotionShake) {
        [FLEXManager.sharedManager toggleExplorer];
    } else {
        // For non-shake motions, call the original implementation
        [self flex_motionEnded:motion withEvent:event];
    }
}

+ (BOOL)isShakeSwizzlingEnabled {
    return isShakeSwizzlingEnabled;
}

@end
