//
//  NewTournamentViewController.h
//  
//
//  Created by Zachary Mallicoat on 4/22/15.
//
//

#import <UIKit/UIKit.h>
#import "Tournament.h"
#import "User.h"
#import "AddParticipantsTableViewController.h"

@interface NewTournamentViewController : UITableViewController <UIGestureRecognizerDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (strong) UINavigationBar* navigationBar;
@property (nonatomic) Tournament *tournament;
@property (nonatomic) User *currentUser;

@property (weak, nonatomic) IBOutlet UIPickerView *tournamentTypePicker;

@property (weak, nonatomic) IBOutlet UITextField *tournamentNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *tournamentURLTextField;
@property (weak, nonatomic) IBOutlet UITextField *gameTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

- (BOOL)textField:(UITextField *)field shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)characters;

@end
