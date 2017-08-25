//
//  MainVC.m
//  DevelopexTestTask
//
//  Created by User on 25.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

#import "MainVC.h"

#import "ActionSheetPicker.h"
#import "UrlSearchTask.h"
#import "UIView+BZExtensions.h"

typedef enum : NSInteger
{
    MainVCStateInitial = 1,
    MainVCStatePlaying = 2,
    MainVCStatePaused = 3
} MainVCState;

@interface MainVC () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UrlSearchTaskDelegate>

@property (nonatomic, assign) NSInteger threadsCount;
@property (nonatomic, assign) MainVCState currentState;
@property (nonatomic, strong, nonnull) UIBarButtonItem *playItem;
@property (nonatomic, strong, nonnull) UIBarButtonItem *pauseItem;
@property (nonatomic, strong, nonnull) UIBarButtonItem *stopItem;
@property (nonatomic, strong, nonnull) NSMutableArray<NSURL *> *urlsArray;
@property (nonatomic, strong) UrlSearchTask *theSearchTask;
@property (nonatomic, strong) NSMutableDictionary<NSURL *, NSString *> *recordsDictionary;
@property (nonatomic, assign) double currentProgress;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *progressLabel;

@end

@implementation MainVC

#pragma mark - Class Methods (Public)

#pragma mark - Class Methods (Private)

#pragma mark - Init & Dealloc

#pragma mark - Setters (Public)

#pragma mark - Getters (Public)

#pragma mark - Setters (Private)

- (void)setCurrentProgress:(double)currentProgress
{
    if (currentProgress == _currentProgress)
    {
        return;
    }
    _currentProgress = currentProgress;
    if (!currentProgress)
    {
        [self.mainTableView reloadData];
        self.progressView.alpha = 0;
        self.progressLabel.alpha = 0;
    }
    else
    {
        self.progressView.alpha = 1;
        self.progressLabel.alpha = 1;
        self.progressView.progress = _currentProgress;
        self.progressLabel.text = [NSString stringWithFormat:@"%.1f%@", self.currentProgress * 100, @"%"];
    }
}

#pragma mark - Getters (Private)

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createBarButtons];
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
//    self.mainTableView.tableHeaderView = self.headerView;
    self.mainTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) ];
    self.urlCountTextField.delegate = self;
    self.urlCountTextField.keyboardType = UIKeyboardTypeNumberPad;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleThreadsViewWasTapped:)];
    [self.threadsView addGestureRecognizer:gesture];
    self.threadsCount = 5;
    self.currentState = MainVCStateInitial;
    self.urlsArray = [NSMutableArray new];
    self.recordsDictionary = [NSMutableDictionary new];
    
    [self adjustThreadsLabel];
    [self adjustBarToCurrentState];
    
    self.startUrlTextField.text = @"http://www.sanmarinocard.sm";
    self.urlCountTextField.text = @"100";
    self.searchTextField.text = @"you";
    [self.mainTableView reloadData];
}

#pragma mark - Create Views & Variables

- (void)createBarButtons
{
    UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [playButton setShowsTouchWhenHighlighted:YES];
    playButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [playButton addTarget:self action:@selector(actionPlayButtonPressed:)
         forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *thePlayItem = [[UIBarButtonItem alloc] initWithCustomView:playButton];
    self.playItem = thePlayItem;
    
    UIButton *stopButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [stopButton setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    [stopButton setShowsTouchWhenHighlighted:YES];
    stopButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [stopButton addTarget:self action:@selector(actionStopButtonPressed:)
         forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *theStopItem = [[UIBarButtonItem alloc] initWithCustomView:stopButton];
    self.stopItem = theStopItem;
    
    UIButton *pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [pauseButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    [pauseButton setShowsTouchWhenHighlighted:YES];
    pauseButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [pauseButton addTarget:self action:@selector(actionPauseButtonPressed:)
          forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *pauseItem = [[UIBarButtonItem alloc] initWithCustomView:pauseButton];
    self.pauseItem = pauseItem;
}

#pragma mark - Actions

- (void)actionPlayButtonPressed:(UIButton *)button
{
    if (self.currentState == MainVCStateInitial)
    {
        [self.urlCountTextField resignFirstResponder];
        [self.searchTextField resignFirstResponder];
        [self.startUrlTextField resignFirstResponder];
        NSString *string = [self validateFields];
        if (string)
        {
            [self showErrorAlert:string];
        }
        else
        {
            self.urlsArray = [NSMutableArray new];
            self.recordsDictionary = [NSMutableDictionary new];
            [self.mainTableView reloadData];
            self.currentState = MainVCStatePlaying;
            [self adjustBarToCurrentState];
            self.theSearchTask = [[UrlSearchTask alloc] initWithStartUrl:[NSURL URLWithString: self.startUrlTextField.text] maxThreadsCount:self.threadsCount searchString:self.searchTextField.text maxUrlCount:[self.urlCountTextField.text integerValue]];
            self.theSearchTask.delegate = self;
        }
    }
    else if (self.currentState == MainVCStatePaused)
    {
        self.currentState = MainVCStatePlaying;
        [self adjustBarToCurrentState];
        [self.theSearchTask methodPlay];
    }
}

- (void)actionStopButtonPressed:(UIButton *)button
{
    [self.theSearchTask methodCancel];
    self.currentProgress = 0;
    self.currentState = MainVCStateInitial;
    [self adjustBarToCurrentState];
    self.urlsArray = [NSMutableArray new];
    self.recordsDictionary = [NSMutableDictionary new];
    [self.mainTableView reloadData];
}

- (void)actionPauseButtonPressed:(UIButton *)button
{
    [self.theSearchTask methodPause];
    self.currentState = MainVCStatePaused;
    [self adjustBarToCurrentState];
}

#pragma mark - Gestures

- (void)handleThreadsViewWasTapped:(UITapGestureRecognizer *)gesture
{
    if (self.currentState == MainVCStateInitial)
    {
        [self showThreadsPicker];
    }
}

#pragma mark - Delegates (UITableViewDelegate)

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.urlsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    NSURL *currentUrl = self.urlsArray[indexPath.row];
    cell.textLabel.text = [currentUrl absoluteString];
    cell.detailTextLabel.text = self.recordsDictionary[currentUrl];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, 120, 20)];
    self.progressView = progressView;
    [view addSubview:progressView];
    progressView.theWidth = 120;
    progressView.theHeight = 30;
    progressView.theCenterX = (progressView.superview.theWidth - 10) / 2;
    progressView.theCenterY = progressView.superview.theHeight / 2;
    progressView.progress = self.currentProgress;
    
    UILabel *label = [UILabel new];
    self.progressLabel = label;
    [view addSubview:label];
    label.text = [NSString stringWithFormat:@"%.1f%@", self.currentProgress * 100, @"%"];
    [label sizeToFit];
    label.theWidth = 50;
    label.theCenterY = label.superview.theHeight / 2;
    label.theMinX = progressView.theMaxX + 15;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.currentState == MainVCStateInitial ? 0 : 40;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.urlCountTextField)
    {
        NSCharacterSet *numbersOnly = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        NSCharacterSet *characterSetFromTextField = [NSCharacterSet characterSetWithCharactersInString:textField.text];
        
        BOOL stringIsValid = [numbersOnly isSupersetOfSet:characterSetFromTextField];
        if (!stringIsValid)
        {
            return NO;
        }
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (newString.length > 0 && [[newString substringToIndex:1] isEqualToString:@"0"])
        {
            return NO;
        }
        if (newString.length > 5)
        {
            textField.text = [newString substringToIndex:5];
        }
        else
        {
            textField.text = newString;
        }
        return NO;
    }
    return YES;
}

#pragma mark - UrlSearchTaskDelegate

- (void)urlSearchTaskHasFinished:(UrlSearchTask * _Nonnull)searchTask
{
    self.currentState = MainVCStateInitial;
    [self adjustBarToCurrentState];
}

- (void)urlWasFinishedProcessing:(NSURL * _Nonnull)url foundCount:(NSUInteger)foundCount newProgress:(double)progress
{
    self.currentProgress = progress;
    NSString *description;
    if (!foundCount)
    {
        description = @"No matches";
    }
    else
    {
        description = [NSString stringWithFormat:@"Found: %zd", foundCount];
    }
    self.recordsDictionary[url] = description;
    [self.mainTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.urlsArray indexOfObject:url] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)urlProcessingFault:(NSURL * _Nonnull)url error:(NSError * _Nonnull)error newProgress:(double)progress
{
    self.currentProgress = progress;
    self.recordsDictionary[url] = [NSString stringWithFormat:@"Error:%@", error.localizedDescription];
    [self.mainTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.urlsArray indexOfObject:url] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)newUrlsFound:(NSSet<NSURL *> * _Nonnull)set
{
    for (NSURL *url in set)
    {
        [self.urlsArray addObject:url];
        self.recordsDictionary[url] = @"Processing..";
    }
    [self.mainTableView reloadData];
}

#pragma mark - Methods (Public)

#pragma mark - Methods (Private)

- (NSString * _Nullable)validateFields
{
    NSString *urlRegEx =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    if (![urlTest evaluateWithObject:self.startUrlTextField.text])
    {
        return @"Invalid url";
    }
    if ([self.searchTextField.text isEqualToString:@""])
    {
        return @"Search text is empty";
    }
    if ([self.urlCountTextField.text isEqualToString:@""])
    {
        return @"Need specify url count";
    }
    return nil;
}

- (void)showThreadsPicker
{
    NSMutableArray<NSString *> *threadsArray = [NSMutableArray new];
    for (int i = 1; i <= 100; i++)
    {
        [threadsArray addObject:[NSString stringWithFormat:@"%zd", i]];
    }
    [ActionSheetStringPicker showPickerWithTitle:@"Threads number"
                                            rows:threadsArray
                                initialSelection:self.threadsCount - 1
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
     {
         self.threadsCount = selectedIndex + 1;
         [self adjustThreadsLabel];
     }
                                     cancelBlock:^(ActionSheetStringPicker *picker)
     {
     }origin:self.view];
}

- (void)adjustBarToCurrentState
{
    switch (self.currentState)
    {
        case MainVCStateInitial:
        {
            [self.navigationItem setRightBarButtonItems:@[self.playItem]];
        }
            break;
        case MainVCStatePlaying:
        {
            [self.navigationItem setRightBarButtonItems:@[self.stopItem, self.pauseItem]];
        }
            break;
        case MainVCStatePaused:
        {
            [self.navigationItem setRightBarButtonItems:@[self.playItem, self.stopItem]];
        }
            break;
    }
}

- (void)adjustThreadsLabel
{
    self.threadsLabel.text = [NSString stringWithFormat:@"Threads count:%zd", self.threadsCount];
}

- (void)showErrorAlert:(NSString * _Nonnull)alertMessage
{
    UIAlertController *theAlert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                      message:alertMessage
                                                               preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *theOkAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:nil];
    [theAlert addAction:theOkAction];
    [self presentViewController:theAlert animated:YES completion:nil];

}

#pragma mark - Standard Methods

@end































