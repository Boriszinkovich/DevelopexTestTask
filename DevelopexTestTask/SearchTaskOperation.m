//
//  DataTaskOperation.m
//  DevelopexTestTask
//
//  Created by User on 25.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

#import "SearchTaskOperation.h"

@interface SearchTaskOperation()

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURL *parentUrl;
@property (nonatomic, strong) NSString *searchString;
@property (atomic, weak) NSURLSessionTask *task;
@property (nonatomic, copy) void (^dataTaskCompletionHandler)(NSSet<NSURL *> * _Nullable urlSet, NSUInteger searchCount, NSError * _Nullable error, NSURL * parentUrl);
@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation SearchTaskOperation


- (instancetype)initWithURL:(NSURL *)url withSearchString:(NSString * _Nonnull)searchString  dataTaskCompletionHandler:(void (^)(NSSet<NSURL *> * _Nullable urlSet, NSUInteger searchCount, NSError * _Nullable error, NSURL * parentUrl))dataTaskCompletionHandler
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self = [super init];
    if (self) {
        self.request = request;
        self.searchString = searchString;
        self.dataTaskCompletionHandler = dataTaskCompletionHandler;
        self.semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)main
{
    NSURLSession *session =  [NSURLSession sharedSession];
    session.configuration.timeoutIntervalForRequest = 20;
    NSURLSessionTask *task = [session dataTaskWithRequest:self.request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error)
        {
            self.dataTaskCompletionHandler(nil, 0, error, self.request.URL);
        }
        else
        {
            NSString *result = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSLog(@"%@", result);
            NSSet *theUrls = [self methodFindUrls:result];
            NSUInteger searchCount = [self findSearchCount:self.searchString withOriginString:result];
            self.dataTaskCompletionHandler(theUrls, searchCount, error, self.request.URL);
            [self completeOperation];
        }
    }];
    [task resume];
    self.task = task;
}

- (void)completeOperation
{
    self.dataTaskCompletionHandler = nil;
    [super completeOperation];
}

- (void)cancel
{
    [self.task cancel];
    [super cancel];
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


- (void)pause
{
    [self.task suspend];
}

- (void)resume
{
    [self.task resume];
}

@end































