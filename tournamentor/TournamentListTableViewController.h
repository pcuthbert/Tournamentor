//
//  TournamentListTableViewController.h
//  tournamentor
//
//  Created by Zachary Mallicoat on 4/18/15.
//  Copyright (c) 2015 Zachary Mallicoat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "ChallongeCommunicator.h"
#import "TournamentListTableViewCell.h"
#import "DataHolder.h"
#import "ResultsTableViewController.h"
#import "MatchListTableViewController.h"
#import "NewTournamentViewController.h"
#import <MBProgressHUD.h>

@interface TournamentListTableViewController : UITableViewController

@property (nonatomic) User *user;

- (UIViewController *)backViewController;

@end
