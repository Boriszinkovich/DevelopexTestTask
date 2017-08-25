//
//  DataTaskOperation.h
//  DevelopexTestTask
//
//  Created by User on 25.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

@import Foundation;
#import "AsynchronousOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface SearchTaskOperation : AsynchronousOperation

- (instancetype)initWithURL:(NSURL *)url withSearchString:(NSString * _Nonnull)searchString  dataTaskCompletionHandler:(void (^)(NSSet<NSURL *> * _Nullable urlSet, NSUInteger searchCount, NSError * _Nullable error, NSURL * parentUrl))dataTaskCompletionHandle;

- (void)pause;
- (void)resume;

@end

NS_ASSUME_NONNULL_END































