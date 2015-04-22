//
//  MatchListTableViewController.m
//  tournamentor
//
//  Created by Zachary Mallicoat on 4/21/15.
//  Copyright (c) 2015 Zachary Mallicoat. All rights reserved.
//

#import "MatchListTableViewController.h"

@interface MatchListTableViewController ()

@property (nonatomic) NSArray *matches;


@end

@implementation MatchListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

-(void)viewWillAppear:(BOOL)animated {
    [self setTitle:self.selectedTournament.tournamentName];
    
    ChallongeCommunicator *communicator = [[ChallongeCommunicator alloc]init];
    
    [communicator getMatchesForTournament:self.selectedTournament.tournamentURL withUsername:self.currentUser.name andAPIKey:self.currentUser.apiKey block:^(NSArray *matchArray, NSError *error) {
        NSLog(@"%@", matchArray);
        
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^() {
                self.matches = matchArray;
                [self.tableView reloadData];
            });
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.matches.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MatchListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"matchCell" forIndexPath:indexPath];
    
    Match *cellMatch = _matches[indexPath.row];
    
    cell.roundLabel.text = [NSString stringWithFormat:@"%@ vs %@ - %@", cellMatch.player1_name, cellMatch.player2_name, cellMatch.state];
    
    return cell;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showPickedMatch"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        MatchEditTableViewController *dVC = (MatchEditTableViewController *)segue.destinationViewController;
        
        dVC.selectedMatch = self.matches[indexPath.row];
        dVC.currentUser = self.currentUser;
        dVC.currentTournament = self.selectedTournament;
        
        
    }
    


}


@end
