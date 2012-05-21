//
//  VirtualVacationsTableViewController.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 07/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VirtualVacationsTableViewController.h"
#import "SingleVacationTableViewController.h"


@interface VirtualVacationsTableViewController () <FormViewControllerDelegate>

@end

@implementation VirtualVacationsTableViewController

@synthesize vacations = _vacations;
@synthesize delegate = _delegate;

-(void)addNewVacation:(FormViewController *)sender withName:(NSString *)name
{

    NSURL *documentDirectoryPath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory 
                                                                           inDomains:NSUserDomainMask] lastObject]; //document dir
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[[documentDirectoryPath URLByAppendingPathComponent:name]absoluteString]]) {
        
        
        NSURL *managedDocURL= [[documentDirectoryPath URLByAppendingPathComponent:name]absoluteURL];
        UIManagedDocument *managedDoc = [[UIManagedDocument alloc] initWithFileURL:managedDocURL];
                                 
        [managedDoc saveToURL:[documentDirectoryPath URLByAppendingPathComponent:name] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
        
        if (success) NSLog(@"Document saved");
        else NSLog(@"Document NOT saved");
        
        }];
    }
    
  
    NSMutableSet *newVacationsSet = [[NSMutableSet alloc] initWithArray:self.vacations];
    [newVacationsSet addObject:[documentDirectoryPath URLByAppendingPathComponent:name]]; //con un set non ho nomi duplicati
     NSMutableArray *newVacationsList = [[NSMutableArray alloc] initWithArray:[[newVacationsSet allObjects] mutableCopy]];
    self.vacations = newVacationsList;
    [sender dismissModalViewControllerAnimated:YES];
}


-(void)setVacations:(NSArray *)vacations
{
    if (_vacations != vacations)
    {
        _vacations = vacations;
    [self.tableView reloadData];
    }
}

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
    // If no action is performed, simply dismiss
    [[self presentingViewController] dismissModalViewControllerAnimated:YES];
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:(BOOL)animated];
        
    //if (!self.vacations) //con questo if non mi aggiornava la Lista se inserisco una Vacation aggiuntiva quando sto guardando una foto
    //{
    //VacationManager *vm=[[VacationManager alloc] init]; 
        self.vacations = [VacationHelper vacationsList];
    //}
 
    
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

#pragma mark - Table view data source
/**
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}
**/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.vacations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"vacation cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
      NSString *fileName = [[self.vacations objectAtIndex:indexPath.row] lastPathComponent];
       
    
    
     //NSRange  range = [fileName rangeOfString:@"vacation"];
     //cell.textLabel.text = [fileName substringToIndex:range.location-1];
    
    cell.textLabel.text =fileName; //come testo lascio il nome della directory
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    //[self performSegueWithIdentifier:@"show vacation" sender:self]; //dal momento che ho collegato direttamente la cella alla TVC successiva, non occorre questa riga altrimenti genererebbe un errore: Unbalanced calls to begin/end appearance transitions for <SingleVacationTVC: 0x70c8f10>.
    NSString *vacationName = [self.vacations objectAtIndex:indexPath.row];
    [self.delegate VirtualVacationsTableViewController:self didSelectVacation:vacationName];

}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show vacation"]) {


        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];

        [segue.destinationViewController setVacation:[[self.vacations objectAtIndex:indexPath.row]lastPathComponent]];
    
    } else  if ([segue.identifier isEqualToString:@"show form"]) {
        [segue.destinationViewController setDelegate:self];
    }

}



@end
