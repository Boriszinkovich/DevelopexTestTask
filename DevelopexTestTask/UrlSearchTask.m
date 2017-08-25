//
//  UrlSearchTask.m
//  DevelopexTestTask
//
//  Created by User on 24.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

#import "UrlSearchTask.h"

#import "SearchTaskOperation.h"

@interface UrlSearchTask()

@property (nonatomic, strong, nonnull) NSURL *startUrl;
@property (nonatomic, assign) NSUInteger threadsCount;
@property (nonatomic, strong, nonnull) NSString *searchString;
@property (nonatomic, assign) NSUInteger urlCount;
@property (nonatomic, strong, nonnull) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSHashTable<SearchTaskOperation *> *runningOperationsTable;
@property (nonatomic, strong) NSOperationQueue *mainTaskOperationQueue;
@property (nonatomic, strong) NSMutableSet<NSURL *> *urlsSet;
@property (nonatomic, assign) NSUInteger currentUrlCount;
@property (nonatomic, assign) NSUInteger currentProcessedCount;

@end

@implementation UrlSearchTask

- (instancetype _Nonnull)initWithStartUrl:(NSURL * _Nonnull)startUrl maxThreadsCount:(NSUInteger)threadsCount searchString:(NSString * _Nonnull)searchString maxUrlCount:(NSUInteger)urlCount
{
    self = [super init];
    if (self)
    {
        _startUrl = startUrl;
        _threadsCount = threadsCount;
        _searchString = searchString;
        _urlCount = urlCount;
        _operationQueue = [NSOperationQueue new];
        _operationQueue.maxConcurrentOperationCount = threadsCount;
        _mainTaskOperationQueue = [NSOperationQueue new];
        _mainTaskOperationQueue.maxConcurrentOperationCount = 1;
        [_mainTaskOperationQueue addOperationWithBlock:^
         {
             self.runningOperationsTable = [NSHashTable weakObjectsHashTable];
             
             self.urlsSet = [NSMutableSet new];
             [self.urlsSet addObject:startUrl];
             self.currentUrlCount = 1;
             [self respondNewUrlsFound:[NSSet setWithObject:startUrl]];
             [self startOperationWithUrl:startUrl];
         }];
    }
    return self;
}

- (void)startOperationWithUrl:(NSURL * _Nonnull)theUrl
{
    SearchTaskOperation *taskOperation = [[SearchTaskOperation alloc] initWithURL:theUrl withSearchString:self.searchString dataTaskCompletionHandler:^(NSSet<NSURL *> * _Nonnull urlSet, NSUInteger searchCount, NSError * _Nullable error, NSURL * _Nonnull parentUrl)
                                          {
                                              [self.mainTaskOperationQueue addOperationWithBlock:^
                                              {
                                                  self.currentProcessedCount += 1;
                                                  if (self.currentProcessedCount == self.urlCount)
                                                  {
                                                      [self respondTaskFinished];
                                                  }
                                                  if (error)
                                                  {
                                                      [self respondUrlFault:parentUrl error:error];
                                                  }
                                                  else
                                                  {
                                                      [self methodHandleUrls:urlSet withSearchCount:searchCount withParentUrl:parentUrl];
                                                  }
                                              }];
                                          }];
    [self.runningOperationsTable addObject:taskOperation];
    [_operationQueue addOperation:taskOperation];
}

- (void)methodHandleUrls:(NSSet<NSURL *> * _Nonnull)setOfUrls withSearchCount:(NSUInteger)searchCount
            withParentUrl:(NSURL *)theParentUrl
{
    [self respondUrlFinishedProcessing:theParentUrl foundCount:searchCount];
    if (self.currentUrlCount >= self.urlCount)
    {
        return;
    }
    NSMutableSet *mutableSet = setOfUrls.mutableCopy;
    [mutableSet minusSet:self.urlsSet];
    if (mutableSet.count)
    {
        for (NSURL *theUrl in mutableSet)
        {
            self.currentUrlCount++;
            [self startOperationWithUrl:theUrl];
            [self respondNewUrlsFound:[NSSet setWithObject:theUrl]];
            [self.urlsSet addObject:theUrl];
            if (self.currentUrlCount >= self.urlCount)
            {
                break;
            }
        }
    }
}

- (void)methodPause
{
    for (SearchTaskOperation *operation in self.runningOperationsTable)
    {
        [operation pause];
    }
}

- (void)methodPlay
{
    for (SearchTaskOperation *operation in self.runningOperationsTable)
    {
        [operation resume];
    }
}

- (void)methodCancel
{
    for (SearchTaskOperation *operation in self.runningOperationsTable)
    {
        [operation cancel];
    }
//    [self.operationQueue cancelAllOperations];
}

- (void)respondTaskFinished
{
    [NSOperationQueue.mainQueue addOperationWithBlock:^
     {
         [self.delegate urlSearchTaskHasFinished:self];
     }];
}

- (void)respondNewUrlsFound:(NSSet<NSURL *> * _Nonnull)set
{
    [NSOperationQueue.mainQueue addOperationWithBlock:^
    {
        [self.delegate newUrlsFound:set];
    }];
}

- (void)respondUrlFinishedProcessing:(NSURL * _Nonnull)url foundCount:(NSUInteger)foundCount
{
    double progress = ((double)self.currentProcessedCount) / self.urlCount;
    [NSOperationQueue.mainQueue addOperationWithBlock:^
     {
         [self.delegate urlWasFinishedProcessing:url foundCount:foundCount newProgress:progress];
     }];
}

- (void)respondUrlFault:(NSURL * _Nonnull)url error:(NSError * _Nonnull)error
{
    double progress = ((double)self.currentProcessedCount) / self.urlCount;
    [NSOperationQueue.mainQueue addOperationWithBlock:^
     {
         [self.delegate urlProcessingFault:url error:error newProgress:progress];
     }];
}

@end






























