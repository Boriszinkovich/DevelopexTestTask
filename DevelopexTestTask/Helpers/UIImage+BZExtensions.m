//
//  UIImage+BZExtensions.m
//  ScrollViewTask
//
//  Created by BZ on 2/16/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "UIImage+BZExtensions.h"

@implementation UIImage (BZExtensions)

#pragma mark - Class Methods (Public)

+ (UIImage *)getImageFromColor:(UIColor * _Nonnull)theColor
{
    if (!theColor)
    {
        return  nil;
    }
    CGRect theRect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(theRect.size);
    CGContextRef theContext = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(theContext, [theColor CGColor]);
    CGContextFillRect(theContext, theRect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

#pragma mark - Class Methods (Private)

#pragma mark - Init & Dealloc

#pragma mark - Setters (Public)

#pragma mark - Getters (Public)

#pragma mark - Setters (Private)

#pragma mark - Getters (Private)

#pragma mark - Lifecycle

#pragma mark - Create Views & Variables

#pragma mark - Actions

#pragma mark - Gestures

#pragma mark - Delegates ()

#pragma mark - Methods (Public)

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage * __nonnull)getImageWithSize:(CGSize)theSize;
{
    size_t theWidth = theSize.width * [UIScreen mainScreen].scale;
    size_t theHeight = theSize.height * [UIScreen mainScreen].scale;
    
    CGColorSpaceRef theColorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef theContextRef = CGBitmapContextCreate(NULL, theWidth, theHeight, 8, theWidth*4, theColorSpaceRef, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    CGColorSpaceRelease(theColorSpaceRef);
    
    CGContextDrawImage(theContextRef, CGRectMake(0, 0, theWidth, theHeight), self.CGImage);
    CGImageRef theOutputImageRef = CGBitmapContextCreateImage(theContextRef);
    UIImage *theImage = [UIImage imageWithCGImage:theOutputImageRef];
    
    CGImageRelease(theOutputImageRef);
    CGContextRelease(theContextRef);
    return theImage;
}

#pragma mark - Methods (Private)

#pragma mark - Standard Methods

@end






























