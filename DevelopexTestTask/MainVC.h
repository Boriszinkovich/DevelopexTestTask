//
//  MainVC.h
//  DevelopexTestTask
//
//  Created by User on 25.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainVC : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *startUrlTextField;
@property (weak, nonatomic) IBOutlet UILabel *threadsLabel;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITextField *urlCountTextField;
@property (weak, nonatomic) IBOutlet UIView *threadsView;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@end
