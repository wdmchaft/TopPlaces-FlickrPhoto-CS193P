//
//  FormViewController.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 19/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FormViewController.h"

@interface FormViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *vacationNameField;
@property (weak, nonatomic) IBOutlet UIButton *insertButton;
@property (strong,nonatomic) NSString *vacationName;

@end

@implementation FormViewController
@synthesize vacationNameField = _vacationNameField;
@synthesize insertButton = _insertButton;
@synthesize vacationName = _vacationName;
@synthesize delegate = _delegate;

-(void)setVacationName:(NSString *)vacationName
{
    if (_vacationName != vacationName) _vacationName = vacationName;
}


- (IBAction)didPressedCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![self.vacationNameField.text isEqualToString:@""])
    {
    [self.vacationNameField resignFirstResponder];
        return YES;
    }
    else return NO;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{   
    self.insertButton.hidden = NO;
    self.vacationName = self.vacationNameField.text;
}
- (IBAction)addNewVacationPressed:(id)sender {
    [self.delegate addNewVacation:self withName:self.vacationName];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.vacationNameField.delegate = self;
    self.insertButton.hidden = YES;
    
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setVacationNameField:nil];
    [self setInsertButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
