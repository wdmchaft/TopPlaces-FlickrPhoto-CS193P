//
//  SingleVacationTableViewController.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 07/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SingleVacationTableViewController.h"
#import "TagsTableViewController.h"
#import "orderedItineraryTableViewController.h"

@interface SingleVacationTableViewController ()

@end

@implementation SingleVacationTableViewController
@synthesize vacation = _vacation;

-(void)setVacation:(NSString *)vacation
{
    if (_vacation != vacation) {_vacation=vacation;}
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    self.title = self.vacation;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}





#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   
        [segue.destinationViewController setVacation:self.vacation];
        

}

@end
