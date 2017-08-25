//
//  UrlSearchTask.h
//  DevelopexTestTask
//
//  Created by User on 24.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

#import <Foundation/Foundation.h>

#define weakify(var) __weak typeof(var) AHKWeak_##var = var;

#define strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = AHKWeak_##var; \
_Pragma("clang diagnostic pop")


@protocol UrlSearchTaskDelegate;

@interface UrlSearchTask : NSObject

@property (nonatomic, weak, nullable) id<UrlSearchTaskDelegate> delegate;
- (instancetype _Nonnull)initWithStartUrl:(NSURL * _Nonnull)startUrl maxThreadsCount:(NSUInteger)threadsCount searchString:(NSString * _Nonnull)searchString maxUrlCount:(NSUInteger)urlCount;
- (void)methodCancel;
- (void)methodPause;
- (void)methodPlay;

@end

@protocol UrlSearchTaskDelegate <NSObject>

- (void)urlSearchTaskHasFinished:(UrlSearchTask * _Nonnull)searchTask;
- (void)urlWasFinishedProcessing:(NSURL * _Nonnull)url foundCount:(NSUInteger)foundCount newProgress:(double)progress;
- (void)urlProcessingFault:(NSURL * _Nonnull)url error:(NSError * _Nonnull)error newProgress:(double)progress;
- (void)newUrlsFound:(NSSet<NSURL *> * _Nonnull)set;
//- (void)urlSearchTask:(UrlSearchTask * _Nonnull)searchTask changed

@end





























