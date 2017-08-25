//
//  UIView+BZExtensions.m
//  ScrollViewTask
//
//  Created by BZ on 2/15/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "UIView+BZExtensions.h"

#import <objc/runtime.h>

typedef enum : NSUInteger
{
    BZViewSeparatorTypeNone = 1,
    BZViewSeparatorTypeTop = 2,
    BZViewSeparatorTypeBottom = 3,
    BZViewSeparatorTypeLeft = 4,
    BZViewSeparatorTypeRight = 5,
    BZViewSeparatorTypeEnumCount = BZViewSeparatorTypeRight
} BZViewSeparatorType;

@interface UIView (BZExtensions_private)

@property (nonatomic, assign) BZViewSeparatorType theBZViewSeparatorType;
@property (nonatomic, strong, nonnull) NSValue *thePortraitFrameValue;
@property (nonatomic, strong, nonnull) NSValue *theLandscapeFrameValue;
@property (nonatomic, assign) BOOL isCalledInside;

@end

@implementation UIView (BZExtensions_private)

#pragma mark - Class Methods (Public)

#pragma mark - Class Methods (Private)

#pragma mark - Init & Dealloc

#pragma mark - Setters (Public)

- (void)setTheBZViewSeparatorType:(BZViewSeparatorType)theBZViewSeparatorType
{
    BZAssert((BOOL)(theBZViewSeparatorType <= BZViewSeparatorTypeEnumCount));
    if (self.theBZViewSeparatorType == theBZViewSeparatorType)
    {
        return;
    }
    objc_setAssociatedObject(self, @selector(theBZViewSeparatorType), @(theBZViewSeparatorType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setThePortraitFrameValue:(NSValue * _Nonnull)thePortraitFrameValue
{
    BZAssert(thePortraitFrameValue);
    objc_setAssociatedObject(self, @selector(thePortraitFrameValue), thePortraitFrameValue, OBJC_ASSOCIATION_RETAIN);
}

- (void)setTheLandscapeFrameValue:(NSValue * _Nonnull)theLandscapeFrameValue
{
    BZAssert(theLandscapeFrameValue);
    objc_setAssociatedObject(self, @selector(theLandscapeFrameValue), theLandscapeFrameValue, OBJC_ASSOCIATION_RETAIN);
}

- (void)setIsCalledInside:(BOOL)isCalledInside
{
    objc_setAssociatedObject(self, @selector(isCalledInside), @(isCalledInside), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Getters (Public)

- (BOOL)isCalledInside
{
    NSNumber *theNumber = objc_getAssociatedObject(self, @selector(isCalledInside));
    if (!theNumber)
    {
        objc_setAssociatedObject(self, @selector(isCalledInside), @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        theNumber = @(NO);
    }
    return theNumber.boolValue;
}

- (BZViewSeparatorType)theBZViewSeparatorType
{
    NSNumber *theNumber = objc_getAssociatedObject(self, @selector(theBZViewSeparatorType));
    if (!theNumber)
    {
        objc_setAssociatedObject(self, @selector(theBZViewSeparatorType), @(BZViewSeparatorTypeNone), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        theNumber = @(BZViewSeparatorTypeNone);
    }
    return theNumber.unsignedIntegerValue;
}

- (NSValue *)theLandscapeFrameValue
{
    NSValue *theValue = objc_getAssociatedObject(self, @selector(theLandscapeFrameValue));
    //    if (!theValue)
    //    {
    //        theValue = self.thePortraitFrameValue;
    //    }
    return theValue;
}

- (NSValue *)thePortraitFrameValue
{
    NSValue *theValue = objc_getAssociatedObject(self, @selector(thePortraitFrameValue));
    if (!theValue)
    {
        theValue = [NSValue valueWithCGRect:self.frame];
    }
    return theValue;
}

#pragma mark - Setters (Private)

#pragma mark - Getters (Private)

#pragma mark - Lifecycle

#pragma mark - Create Views & Variables

#pragma mark - Actions

#pragma mark - Gestures

#pragma mark - Delegates ()

#pragma mark - Methods (Public)

#pragma mark - Methods (Private)

#pragma mark - Standard Methods

@end

@implementation UIView (BZExtensions)

#pragma mark - Class Methods (Public)

#pragma mark - Class Methods (Private)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      Class class = [self class];
                      SEL originalSelector = nil;
                      SEL swizzledSelector = nil;
                      Method originalMethod = nil;
                      Method swizzledMethod = nil;
                      //        BOOL didAddMethod;
                      for (int i = 0; i < 2; i++)
                      {
                          if (i == 0)
                          {
                              originalSelector = @selector(setFrame:);
                              swizzledSelector = @selector(swizzledBZ_setFrame:);
                              originalMethod = class_getInstanceMethod(class, originalSelector);
                              swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
                              
                          }
                          
                          if (i == 1)
                          {
                              originalSelector = NSSelectorFromString(@"dealloc");
                              swizzledSelector = @selector(swizzledBZ_dealloc);
                              originalMethod = class_getInstanceMethod(class, originalSelector);
                              swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
                          }
                          BZAssert((BOOL)(originalMethod && swizzledMethod && originalSelector && swizzledSelector));
                          
                          BOOL didAddMethod =  class_addMethod(class,
                                                               originalSelector,
                                                               method_getImplementation(swizzledMethod),
                                                               method_getTypeEncoding(swizzledMethod));
                          if (didAddMethod)
                          {
                              class_replaceMethod(class,
                                                  swizzledSelector,
                                                  method_getImplementation(originalMethod),
                                                  method_getTypeEncoding(originalMethod));
                          }
                          else
                          {
                              method_exchangeImplementations(originalMethod, swizzledMethod);
                          }
                      }
                  });
}

#pragma mark - Init & Dealloc

- (void)swizzledBZ_dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self swizzledBZ_dealloc];
}

#pragma mark - Setters (Public)

- (void)setTheMinX:(double)theMinX
{
    CGRect theFrameRect = self.thePortraitFrameValue.CGRectValue;
    theFrameRect.origin.x = theMinX;
    self.thePortraitFrameValue = [NSValue valueWithCGRect:theFrameRect];
    [self methodAdjustToOrientation];
}

- (void)setTheMinY:(double)theMinY
{
    CGRect theFrameRect = self.thePortraitFrameValue.CGRectValue;
    theFrameRect.origin.y = theMinY;
    self.thePortraitFrameValue = [NSValue valueWithCGRect:theFrameRect];
    [self methodAdjustToOrientation];
}

- (void)setTheCenterX:(double)theCenterX
{
    CGRect theFrameRect = self.thePortraitFrameValue.CGRectValue;
    theFrameRect.origin.x = theCenterX - theFrameRect.size.width / 2;
    self.thePortraitFrameValue = [NSValue valueWithCGRect:theFrameRect];
    [self methodAdjustToOrientation];
}

- (void)setTheCenterY:(double)theCenterY
{
    CGRect theFrameRect = self.thePortraitFrameValue.CGRectValue;
    theFrameRect.origin.y = theCenterY - theFrameRect.size.height / 2;
    self.thePortraitFrameValue = [NSValue valueWithCGRect:theFrameRect];
    [self methodAdjustToOrientation];
}

- (void)setTheMaxX:(double)theMaxX
{
    CGRect theFrameRect = self.thePortraitFrameValue.CGRectValue;
    theFrameRect.origin.x = theMaxX - theFrameRect.size.width;
    self.thePortraitFrameValue = [NSValue valueWithCGRect:theFrameRect];
    [self methodAdjustToOrientation];
}

- (void)setTheMaxY:(double)theMaxY
{
    CGRect theFrameRect = self.thePortraitFrameValue.CGRectValue;
    theFrameRect.origin.y = theMaxY - theFrameRect.size.height;
    self.thePortraitFrameValue = [NSValue valueWithCGRect:theFrameRect];
    [self methodAdjustToOrientation];
}

- (void)setTheWidth:(double)theWidth
{
//    BZAssert(theWidth >= 0)
    if (theWidth < 0)
    {
        BZAssert(nil);
    }
    CGRect theFrameRect = self.thePortraitFrameValue.CGRectValue;
    theFrameRect.size.width = theWidth;
    self.thePortraitFrameValue = [NSValue valueWithCGRect:theFrameRect];
    [self methodAdjustToOrientation];
}

- (void)setTheHeight:(double)theHeight
{
    BZAssert((BOOL)(theHeight >= 0));
    CGRect theFrameRect = self.thePortraitFrameValue.CGRectValue;
    theFrameRect.size.height = theHeight;
    self.thePortraitFrameValue = [NSValue valueWithCGRect:theFrameRect];
    [self methodAdjustToOrientation];
}

- (void)setTheLandscapeMinX:(double)theLandscapeMinX
{
    BZAssert((BOOL)(theLandscapeMinX >= 0));
    NSValue *theLandscapeFrameValue = self.theLandscapeFrameValue;
    CGRect theFrameRect;
    if (!theLandscapeFrameValue)
    {
        theFrameRect = self.thePortraitFrameValue.CGRectValue;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveOrientationChanged:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    else
    {
        theFrameRect = self.theLandscapeFrameValue.CGRectValue;
    }
    theFrameRect.origin.x = theLandscapeMinX;
    self.theLandscapeFrameValue = [NSValue valueWithCGRect:theFrameRect];
    [self methodAdjustToOrientation];
}

- (void)setTheLandscapeMinY:(double)theLandscapeMinY
{
    BZAssert((BOOL)(theLandscapeMinY >= 0));
    NSValue *theLandscapeFrameValue = self.theLandscapeFrameValue;
    CGRect theFrameRect;
    if (!theLandscapeFrameValue)
    {
        theFrameRect = self.thePortraitFrameValue.CGRectValue;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveOrientationChanged:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    else
    {
        theFrameRect = self.theLandscapeFrameValue.CGRectValue;
    }
    theFrameRect.origin.y = theLandscapeMinY;
    self.theLandscapeFrameValue = [NSValue valueWithCGRect:theFrameRect];
    [self methodAdjustToOrientation];
}

- (void)setTheLandscapeCenterX:(double)theLandscapeCenterX
{
    BZAssert((BOOL)(theLandscapeCenterX >= 0));
    NSValue *theLandscapeFrameValue = self.theLandscapeFrameValue;
    CGRect theFrameRect;
    if (!theLandscapeFrameValue)
    {
        theFrameRect = self.thePortraitFrameValue.CGRectValue;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveOrientationChanged:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    else
    {
        theFrameRect = self.theLandscapeFrameValue.CGRectValue;
    }
    theFrameRect.origin.x = theLandscapeCenterX - theFrameRect.size.width / 2;
    self.theLandscapeFrameValue = [NSValue valueWithCGRect:theFrameRect];
    [self methodAdjustToOrientation];
}

- (void)setTheLandscapeCenterY:(double)theLandscapeCenterY
{
    BZAssert((BOOL)(theLandscapeCenterY >= 0));
    NSValue *theLandscapeFrameValue = self.theLandscapeFrameValue;
    CGRect theFrameRect;
    if (!theLandscapeFrameValue)
    {
        theFrameRect = self.thePortraitFrameValue.CGRectValue;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveOrientationChanged:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    else
    {
        theFrameRect = self.theLandscapeFrameValue.CGRectValue;
    }
    theFrameRect.origin.y = theLandscapeCenterY - theFrameRect.size.height / 2;
    self.theLandscapeFrameValue = [NSValue valueWithCGRect:theFrameRect];
    [self methodAdjustToOrientation];
}

- (void)setTheLandscapeWidth:(double)theLandscapeWidth
{
    BZAssert((BOOL)(theLandscapeWidth >= 0));
    NSValue *theLandscapeFrameValue = self.theLandscapeFrameValue;
    CGRect theFrameRect;
    if (!theLandscapeFrameValue)
    {
        theFrameRect = self.thePortraitFrameValue.CGRectValue;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveOrientationChanged:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    else
    {
        theFrameRect = self.theLandscapeFrameValue.CGRectValue;
    }
    theFrameRect.size.width = theLandscapeWidth;
    self.theLandscapeFrameValue = [NSValue valueWithCGRect:theFrameRect];
    [self methodAdjustToOrientation];
}

- (void)setTheLandscapeHeight:(double)theLandscapeHeight
{
    BZAssert((BOOL)(theLandscapeHeight >= 0));
    NSValue *theLandscapeFrameValue = self.theLandscapeFrameValue;
    CGRect theFrameRect;
    if (!theLandscapeFrameValue)
    {
        theFrameRect = self.thePortraitFrameValue.CGRectValue;
    }
    else
    {
        theFrameRect = self.theLandscapeFrameValue.CGRectValue;
    }
    theFrameRect.size.height = theLandscapeHeight;
    self.theLandscapeFrameValue = [NSValue valueWithCGRect:theFrameRect];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveOrientationChanged:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    [self methodAdjustToOrientation];
}

- (void)setTheLandscapeMaxX:(double)theLandscapeMaxX
{
    BZAssert((BOOL)(theLandscapeMaxX >= 0));
    NSValue *theLandscapeFrameValue = self.theLandscapeFrameValue;
    CGRect theFrameRect;
    if (!theLandscapeFrameValue)
    {
        theFrameRect = self.frame;
    }
    else
    {
        theFrameRect = theLandscapeFrameValue.CGRectValue;
    }
    theFrameRect.origin.x = theLandscapeMaxX - theFrameRect.size.width;
    self.theLandscapeFrameValue = [NSValue valueWithCGRect:theFrameRect];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveOrientationChanged:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    [self methodAdjustToOrientation];
}

- (void)setTheLandscapeMaxY:(double)theLandscapeMaxY
{
    BZAssert((BOOL)(theLandscapeMaxY >= 0));
    NSValue *theLandscapeFrameValue = self.theLandscapeFrameValue;
    CGRect theFrameRect;
    if (!theLandscapeFrameValue)
    {
        theFrameRect = self.frame;
    }
    else
    {
        theFrameRect = theLandscapeFrameValue.CGRectValue;
    }
    theFrameRect.origin.y = theLandscapeMaxY - theFrameRect.size.height;
    self.theLandscapeFrameValue = [NSValue valueWithCGRect:theFrameRect];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveOrientationChanged:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    [self methodAdjustToOrientation];
}

#pragma mark - Getters (Public)

- (double)theLandscapeMaxY
{
    if (!self.theLandscapeFrameValue)
    {
        return self.theMaxY;
    }
    return self.theLandscapeFrameValue.CGRectValue.origin.y + self.theLandscapeFrameValue.CGRectValue.size.height;
}

- (double)theLandscapeMaxX
{
    if (!self.theLandscapeFrameValue)
    {
        return self.theMaxX;
    }
    return self.theLandscapeFrameValue.CGRectValue.origin.x + self.theLandscapeFrameValue.CGRectValue.size.width;
}

- (double)theLandscapeWidth
{
    if (!self.theLandscapeFrameValue)
    {
        return self.theWidth;
    }
    return self.theLandscapeFrameValue.CGRectValue.size.width;
}

- (double)theLandscapeHeight
{
    if (!self.theLandscapeFrameValue)
    {
        return self.theHeight;
    }
    return self.theLandscapeFrameValue.CGRectValue.size.height;
}

- (double)theLandscapeMinX
{
    if (!self.theLandscapeFrameValue)
    {
        return self.theMinX;
    }
    return self.theLandscapeFrameValue.CGRectValue.origin.x;
}

- (double)theLandscapeMinY
{
    if (!self.theLandscapeFrameValue)
    {
        return self.theMinY;
    }
    return self.theLandscapeFrameValue.CGRectValue.origin.y;
}

- (double)theLandscapeCenterX
{
    if (!self.theLandscapeFrameValue)
    {
        return self.theCenterX;
    }
    CGRect theFrameRect = self.theLandscapeFrameValue.CGRectValue;
    return theFrameRect.origin.x + theFrameRect.size.width / 2;
}

- (double)theLandscapeCenterY
{
    if (!self.theLandscapeFrameValue)
    {
        return self.theCenterY;
    }
    CGRect theFrameRect = self.theLandscapeFrameValue.CGRectValue;
    return theFrameRect.origin.y + theFrameRect.size.height / 2;
}

- (UIView * _Nonnull)theBottomSeparatorView
{
    UIView *theView = objc_getAssociatedObject(self, @selector(theBottomSeparatorView));
    if (!theView)
    {
        UIView *theBottomSeparatorView = [UIView new];
        theView = theBottomSeparatorView;
        [self addSubview:theView];
        objc_setAssociatedObject(self, @selector(theBottomSeparatorView), theView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        theView.theHeight = 1;
        theView.theWidth = theView.superview.theWidth;
        theView.theMaxY = theView.superview.theHeight;
        
        theView.theBZViewSeparatorType = BZViewSeparatorTypeBottom;
    }
    return theView;
}

- (UIView * _Nonnull)theTopSeparatorView
{
    UIView *theView = objc_getAssociatedObject(self, @selector(theTopSeparatorView));
    if (!theView)
    {
        UIView *theTopSeparatorView = [UIView new];
        theView = theTopSeparatorView;
        [self addSubview:theView];
        objc_setAssociatedObject(self, @selector(theTopSeparatorView), theView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        theView.theHeight = 1;
        theView.theWidth = theView.superview.theWidth;
        theView.theBZViewSeparatorType = BZViewSeparatorTypeTop;
    }
    return theView;
}

- (UIView * _Nonnull)theLeftSeparatorView
{
    UIView *theView = objc_getAssociatedObject(self, @selector(theLeftSeparatorView));
    if (!theView)
    {
        UIView *theLeftSeparatorView = [UIView new];
        theView = theLeftSeparatorView;
        [self addSubview:theView];
        objc_setAssociatedObject(self, @selector(theLeftSeparatorView), theView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        theView.theHeight = theView.superview.theHeight;
        theView.theWidth = 1;
        theView.theBZViewSeparatorType = BZViewSeparatorTypeLeft;
    }
    return theView;
}

- (UIView * _Nonnull)theRightSeparatorView
{
    UIView *theView = objc_getAssociatedObject(self, @selector(theRightSeparatorView));
    if (!theView)
    {
        UIView *theRightSeparatorView = [UIView new];
        theView = theRightSeparatorView;
        [self addSubview:theView];
        objc_setAssociatedObject(self, @selector(theRightSeparatorView), theView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        theView.theHeight = theView.superview.theHeight;
        theView.theWidth = 1;
        theView.theBZViewSeparatorType = BZViewSeparatorTypeRight;
        theView.theMaxY = theView.superview.theMaxY;
    }
    return theView;
}

- (double)theMinX
{
    BZAssert(self.thePortraitFrameValue);
    return self.thePortraitFrameValue.CGRectValue.origin.x;
}

- (double)theMinY
{
    BZAssert(self.thePortraitFrameValue);
    double theMinY = self.thePortraitFrameValue.CGRectValue.origin.y;
    return theMinY;
}

- (double)theCenterX
{
    BZAssert(self.thePortraitFrameValue);
    CGRect theFrameRect = self.thePortraitFrameValue.CGRectValue;
    return theFrameRect.origin.x + theFrameRect.size.width / 2;
}

- (double)theCenterY
{
    BZAssert(self.thePortraitFrameValue);
    CGRect theFrameRect = self.thePortraitFrameValue.CGRectValue;
    return theFrameRect.origin.y + theFrameRect.size.height / 2;
}

- (double)theMaxX
{
    BZAssert(self.thePortraitFrameValue);
    return self.thePortraitFrameValue.CGRectValue.origin.x + self.thePortraitFrameValue.CGRectValue.size.width;
}

- (double)theMaxY
{
    BZAssert(self.thePortraitFrameValue);
    return self.thePortraitFrameValue.CGRectValue.origin.y + self.thePortraitFrameValue.CGRectValue.size.height;
}

- (double)theHeight
{
    BZAssert(self.thePortraitFrameValue);
    return self.thePortraitFrameValue.CGRectValue.size.height;
}

- (double)theWidth
{
    BZAssert(self.thePortraitFrameValue);
    return self.thePortraitFrameValue.CGRectValue.size.width;
}

#pragma mark - Setters (Private)

- (void)swizzledBZ_setFrame:(CGRect)frame
{
    [self methodAdjustTheSeparatorsViewArraySizeWithNewHeight:frame.size.height];
    [self methodAdjustTheSeparatorsViewArraySizeWithNewWidth:frame.size.width];
    switch (self.theBZViewSeparatorType)
    {
        case BZViewSeparatorTypeNone:
        {
            
        }
            break;
        case BZViewSeparatorTypeTop:
        {
            frame.origin.y = 0;
            frame.origin.x = self.superview.frame.size.width / 2 - frame.size.width / 2;
        }
            break;
        case BZViewSeparatorTypeBottom:
        {
            frame.origin.y = self.superview.frame.size.height - frame.size.height;
            frame.origin.x = self.superview.frame.size.width / 2 - frame.size.width / 2;
        }
            break;
        case BZViewSeparatorTypeLeft:
        {
            frame.origin.y = self.superview.frame.size.height / 2 - frame.size.height / 2;
            frame.origin.x = 0;
        }
            break;
        case BZViewSeparatorTypeRight:
        {
            frame.origin.y = self.superview.frame.size.height / 2 - frame.size.height / 2;
            frame.origin.x = self.superview.frame.size.width - frame.size.width;
        }
            break;
    }
    //
    if (!self.thePortraitFrameValue)
    {
        self.thePortraitFrameValue = [NSValue valueWithCGRect:frame];
    }
    if (!self.theLandscapeFrameValue)
    {
        self.thePortraitFrameValue = [NSValue valueWithCGRect:frame];
    }
    if (!self.isCalledInside)
    {
        self.thePortraitFrameValue = [NSValue valueWithCGRect:frame];
    }
    UIInterfaceOrientation theDeviceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (theDeviceOrientation == UIInterfaceOrientationLandscapeLeft || theDeviceOrientation ==UIInterfaceOrientationLandscapeRight)
    {
        if (self.theLandscapeFrameValue)
        {
            frame = self.theLandscapeFrameValue.CGRectValue;
        }
    }
    else
    {
        frame = self.thePortraitFrameValue.CGRectValue;
    }
    self.isCalledInside = NO;
    //
    [self swizzledBZ_setFrame:frame];
    [self methodAdjustTheSeparatorsViewArrayOriginWithNewHeight:frame.size.height];
    [self methodAdjustTheSeparatorsViewArrayOriginWithNewWidth:frame.size.width];
}

#pragma mark - Getters (Private)

#pragma mark - Lifecycle

#pragma mark - Create Views & Variables

#pragma mark - Actions

#pragma mark - Gestures

#pragma mark - Notifications

- (void)receiveOrientationChanged:(NSNotification *)theNotification
{
    [self methodAdjustToOrientation];
}

#pragma mark - Delegates ()

#pragma mark - Methods (Public)

- (NSArray * _Nonnull)theSeparatorsArray
{
    NSMutableArray *theMutableArray = [NSMutableArray new];
    UIView *theBottomSeparatorView = objc_getAssociatedObject(self, @selector(theBottomSeparatorView));
    if (theBottomSeparatorView)
    {
        [theMutableArray addObject:theBottomSeparatorView];
    }
    
    UIView *theTopSeparatorView = objc_getAssociatedObject(self, @selector(theTopSeparatorView));
    if (theTopSeparatorView)
    {
        [theMutableArray addObject:theTopSeparatorView];
    }
    
    UIView *theLeftSeparatorView = objc_getAssociatedObject(self, @selector(theLeftSeparatorView));
    if (theLeftSeparatorView)
    {
        [theMutableArray addObject:theLeftSeparatorView];
    }
    
    UIView *theRightSeparatorView = objc_getAssociatedObject(self, @selector(theRightSeparatorView));
    if (theRightSeparatorView)
    {
        [theMutableArray addObject:theRightSeparatorView];
    }
    
    return theMutableArray.copy;
}

#pragma mark - Methods (Private)

- (void)methodAdjustTheSeparatorsViewArraySizeWithNewWidth:(double)theNewWidth
{
    NSArray *theSeparatorsViewArray = self.theSeparatorsArray;
    if (theSeparatorsViewArray.count == 0)
    {
        return;
    }
    
    for (UIView *theCurrentView in theSeparatorsViewArray)
    {
        
        switch (theCurrentView.theBZViewSeparatorType)
        {
            case BZViewSeparatorTypeNone:
            {
                
            }
                break;
            case BZViewSeparatorTypeBottom:
            {
                theCurrentView.theWidth = theCurrentView.frame.size.width * theNewWidth/theCurrentView.superview.frame.size.width;
            }
                break;
            case BZViewSeparatorTypeTop:
            {
                theCurrentView.theWidth = theCurrentView.frame.size.width * theNewWidth/theCurrentView.superview.frame.size.width;
            }
                break;
            case BZViewSeparatorTypeLeft:
            {
                
            }
                break;
            case BZViewSeparatorTypeRight:
            {
                
            }
                break;
        }
    }
}

- (void)methodAdjustTheSeparatorsViewArraySizeWithNewHeight:(double)theNewHeight
{
    NSArray *theSeparatorsViewArray = self.theSeparatorsArray;
    if (theSeparatorsViewArray.count == 0)
    {
        return;
    }
    
    for (UIView *theCurrentView in theSeparatorsViewArray)
    {
        switch (theCurrentView.theBZViewSeparatorType)
        {
            case BZViewSeparatorTypeNone:
            {
                
            }
                break;
            case BZViewSeparatorTypeBottom:
            {
                
            }
                break;
            case BZViewSeparatorTypeTop:
            {
                
            }
                break;
            case BZViewSeparatorTypeLeft:
            {
                theCurrentView.theHeight = theCurrentView.frame.size.height * theNewHeight/theCurrentView.superview.frame.size.height;
            }
                break;
            case BZViewSeparatorTypeRight:
            {
                theCurrentView.theHeight = theCurrentView.frame.size.height * theNewHeight/theCurrentView.superview.frame.size.height;
            }
                break;
        }
    }
}

- (void)methodAdjustTheSeparatorsViewArrayOriginWithNewHeight:(double)theNewHeight
{
    NSArray *theSeparatorsViewArray = self.theSeparatorsArray;
    if (theSeparatorsViewArray.count == 0)
    {
        return;
    }
    
    for (UIView *theCurrentView in theSeparatorsViewArray)
    {
        switch (theCurrentView.theBZViewSeparatorType)
        {
            case BZViewSeparatorTypeNone:
            {
                
            }
                break;
            case BZViewSeparatorTypeBottom:
            {
                theCurrentView.theMaxY = theNewHeight;
            }
                break;
            case BZViewSeparatorTypeTop:
            {
                
            }
                break;
            case BZViewSeparatorTypeLeft:
            {
                theCurrentView.theCenterY = theNewHeight/2;
            }
                break;
            case BZViewSeparatorTypeRight:
            {
                theCurrentView.theCenterY = theNewHeight/2;
            }
                break;
        }
    }
}

- (void)methodAdjustTheSeparatorsViewArrayOriginWithNewWidth:(double)theNewWidth
{
    NSArray *theSeparatorsViewArray = self.theSeparatorsArray;
    if (theSeparatorsViewArray.count == 0)
    {
        return;
    }
    
    for (UIView *theCurrentView in theSeparatorsViewArray)
    {
        
        switch (theCurrentView.theBZViewSeparatorType)
        {
            case BZViewSeparatorTypeNone:
            {
                
            }
                break;
            case BZViewSeparatorTypeBottom:
            {
                theCurrentView.theCenterX = theNewWidth/2;
            }
                break;
            case BZViewSeparatorTypeTop:
            {
                theCurrentView.theCenterX = theNewWidth/2;
            }
                break;
            case BZViewSeparatorTypeLeft:
            {
                
            }
                break;
            case BZViewSeparatorTypeRight:
            {
                theCurrentView.theMaxX = theNewWidth;
            }
                break;
        }
    }
}

- (void)methodAdjustToOrientation
{
    UIInterfaceOrientation theDeviceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (theDeviceOrientation == UIInterfaceOrientationLandscapeLeft || theDeviceOrientation ==UIInterfaceOrientationLandscapeRight)
    {
        if (self.theLandscapeFrameValue)
        {
            self.isCalledInside = YES;
            self.frame = self.theLandscapeFrameValue.CGRectValue;
        }
    }
    else
    {
        self.isCalledInside = YES;
        self.frame = self.thePortraitFrameValue.CGRectValue;
    }
}

#pragma mark - Standard Methods

@end






























