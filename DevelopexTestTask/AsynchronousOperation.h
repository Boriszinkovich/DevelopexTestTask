//
//  AsynchronousOperation.h
//  DevelopexTestTask
//
//  Created by User on 25.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

@import Foundation;

@interface AsynchronousOperation : NSOperation

/// Complete the asynchronous operation.
///
/// This also triggers the necessary KVO to support asynchronous operations.

- (void)completeOperation;

@end
