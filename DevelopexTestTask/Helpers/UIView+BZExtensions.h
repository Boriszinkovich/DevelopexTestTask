//
//  UIView+BZExtensions.h
//  ScrollViewTask
//
//  Created by BZ on 2/15/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef DEBUG
#define BZAssert(var) \
if (!(BOOL)var) \
{ \
abort(); \
}
#else
#define BZAssert(var)
#endif


@interface UIView (BZExtensions)

@property (nonatomic, assign) double theMinX;
@property (nonatomic, assign) double theMinY;
@property (nonatomic, assign) double theCenterX;
@property (nonatomic, assign) double theCenterY;
@property (nonatomic, assign) double theMaxX;
@property (nonatomic, assign) double theMaxY;
@property (nonatomic, assign) double theWidth;
@property (nonatomic, assign) double theHeight;

@property (nonatomic, assign) double theLandscapeMinX;
@property (nonatomic, assign) double theLandscapeMinY;
@property (nonatomic, assign) double theLandscapeCenterX;
@property (nonatomic, assign) double theLandscapeCenterY;
@property (nonatomic, assign) double theLandscapeMaxX;
@property (nonatomic, assign) double theLandscapeMaxY;
@property (nonatomic, assign) double theLandscapeWidth;
@property (nonatomic, assign) double theLandscapeHeight;

@property (nonatomic, strong, nonnull, readonly) UIView *theRightSeparatorView;
@property (nonatomic, strong, nonnull, readonly) UIView *theLeftSeparatorView;
@property (nonatomic, strong, nonnull, readonly) UIView *theTopSeparatorView;
@property (nonatomic, strong, nonnull, readonly) UIView *theBottomSeparatorView;
@property (nonatomic, strong, nonnull, readonly) NSArray *theSeparatorsArray;

@end






























