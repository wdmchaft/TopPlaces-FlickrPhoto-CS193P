//
//  SingleVacationTVC.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 07/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SingleVacationTVC.h"

@interface SingleVacationTVC ()

@end

@implementation SingleVacationTVC
@synthesize vacation = _vacation;

-(void)setVacation:(UIManagedDocument *)vacation
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
    NSString *fileName = [self.vacation.fileURL lastPathComponent];
    //NSRange  range = [fileName rangeOfString:@"vacation"];
    //self.title = [fileName substringToIndex:range.location-1];
    self.title = fileName;
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}





#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
/**
    switch (indexPath.row) {
        case 0:
            [self performSegueWithIdentifier:@"itinerary" sender:self];
            break;
        case 1:
            [self performSegueWithIdentifier:@"tags" sender:self];
            break;
        default:
            break;
    }
**/
}

@end
