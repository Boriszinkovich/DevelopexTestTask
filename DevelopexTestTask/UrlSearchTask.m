//
//  UrlSearchTask.m
//  DevelopexTestTask
//
//  Created by User on 24.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

#import "UrlSearchTask.h"

@interface UrlSearchTask()

@property (nonatomic, strong, nonnull) NSURL *startUrl;
@property (nonatomic, assign) NSUInteger threadsCount;
@property (nonatomic, strong, nonnull) NSString *searchString;
@property (nonatomic, assign) NSUInteger urlCount;
@property (nonatomic, strong, nonnull) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSOperationQueue *mainTaskOperationQueue;
//@property (nonatomic, strong) NSMutableArray<NSString *> *urlsQueue;
@property (nonatomic, assign) NSUInteger currentUrlCount;

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
        [_operationQueue addOperationWithBlock:^
        {
            [self methodStartWithUrl:startUrl];
        }];
    }
    return self;
}

- (void)methodStartWithUrl:(NSURL * _Nonnull)theUrl
{
    NSError *error = nil;
    NSData *responseData = [NSData dataWithContentsOfURL:theUrl options:NSDataReadingUncached error:&error];
    if (error)
    {
        NSLog(@"%@", [error localizedDescription]);
    }
    else
    {
        NSLog(@"Data has loaded successfully.");
    }
    NSString *result = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    NSLog(@"%@", result);
    NSSet *theUrls = [self methodFindUrls:result];
    __block NSUInteger searchCount = [self findSearchCount:_searchString withOriginString:result];
    [_mainTaskOperationQueue addOperationWithBlock:^
    {
        [self methodHandleUrls:theUrls withSearchCount:searchCount withParentUrl:theUrl];
    }];
}


- (void)methodHandleUrls:(NSSet<NSURL *> * _Nonnull)setOfUrls withSearchCount:(NSUInteger)searchCount
            withParentUrl:(NSURL *)theParentUrl
{
    if (setOfUrls.count)
    {
        for (NSURL *theUrl in setOfUrls)
        {
            if (self.currentUrlCount >= self.urlCount)
            {
                break;
            }
            self.currentUrlCount++;
            [self.operationQueue addOperationWithBlock:^
            {
                [self methodStartWithUrl:theUrl];
            }];
        }
    }
}

- (NSUInteger)findSearchCount:(NSString * _Nonnull)theSearchString withOriginString:(NSString * _Nonnull)originString
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:theSearchString options:NSRegularExpressionCaseInsensitive error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:originString options:0 range:NSMakeRange(0, [originString length])];
    return numberOfMatches;
}

- (NSSet<NSURL *> * _Nonnull)methodFindUrls:(NSString * _Nonnull)text
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"http?://([-\\w\\.]+)+(:\\d+)?(/([\\w/_\\.]*(\\?\\S+)?)?)?" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *arrayOfAllMatches = [regex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    
    NSMutableSet *setOfURLs = [[NSMutableSet alloc] init];
    
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        NSString* substringForMatch = [text substringWithRange:match.range];
        NSLog(@"Extracted URL: %@",substringForMatch);
        NSURL *url = [NSURL URLWithString:substringForMatch];
        if (url != nil)
        {
            [setOfURLs addObject:url];
        }
        
    }
    
    return setOfURLs;
}

- (void)methodCancel
{
    [self.operationQueue cancelAllOperations];
}

@end






























