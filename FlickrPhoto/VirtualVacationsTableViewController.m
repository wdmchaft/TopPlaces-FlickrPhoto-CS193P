//
//  VirtualVacationsTableViewController.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 07/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VirtualVacationsTableViewController.h"
#import "SingleVacationTableViewController.h"


@interface VirtualVacationsTableViewController ()

@end

@implementation VirtualVacationsTableViewController

@synthesize vacations = _vacations;
@synthesize delegate = _delegate;

-(void)setVacations:(NSArray *)vacations
{
    if (_vacations != vacations)
    {
        _vacations = vacations;
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
    /**
    //recupero la lista di vacanze...
    if (!self.vacations)
    {
        NSURL *documentDirectoryPath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory 
                                                             inDomains:NSUserDomainMask] lastObject]; //document dir
        
        // get the contents of the directory
        NSArray *keys = [[NSArray alloc] initWithObjects:NSURLNameKey, nil];
        
        //recupero tutti i documenti nella 'document directory'
        NSArray *urls = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:documentDirectoryPath 
                                                      includingPropertiesForKeys:keys 
                                                                         options:NSDirectoryEnumerationSkipsHiddenFiles 
                                                                           error:nil];
        //creo una lista
        NSMutableArray *vacationsUrls = [[NSMutableArray alloc] init];
        
        for (NSURL *url in urls) {
            NSString *name =[url absoluteString];
            // and see if there are files that contain vacations
            if ([name rangeOfString:@"vacation"].location != NSNotFound) {
                // and add all these urls to an url array
                [vacationsUrls addObject:url];
            }
        }
        if ([vacationsUrls count] == 0) //se non ho nessun documento 'vacation'
        {
        //ne creo uno di default di nome "my default vacation"
            //osservazione: lo creo, ma non lo salvo: lo salvo quando lo aggancio al db? però in questo modo se esco dall'app prima non ho la "my defaul vacation salvata" per cui me la ricrea ogni volta (tanto, cmq sia, finchè non l'aggancio al db è vuota!)
            //risposta: nel tutorial si consiglia di salvare quando si modifica, quindi mi sono risposto :)
            [vacationsUrls addObject:[documentDirectoryPath URLByAppendingPathComponent:@"my default vacation"]]; //creo il path
            NSLog(@"my vacation default creato! %@", [vacationsUrls description]);
        }
        
        NSMutableArray *vacationDocuments = [[NSMutableArray alloc] initWithCapacity:[vacationsUrls count]]; //bastava anche init
        
        // loop over all documents and add each document to the vacations array
        //da una lista di path ricavo una lista di UIManagedDocument
        for (NSURL *vacation in vacationsUrls) {
            [vacationDocuments addObject:[[UIManagedDocument alloc] initWithFileURL:vacation]];
        }
        self.vacations = vacationDocuments;
     }
**/
    if (!self.vacations)
    {
    //VacationManager *vm=[[VacationManager alloc] init]; 
        self.vacations = [VacationHelper vacationsList];
    }

 
    
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
    
    }

}

@end
