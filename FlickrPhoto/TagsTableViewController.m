//
//  TagsTableViewController.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 10/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TagsTableViewController.h"
#import "Tag+Create.h"
#import "VacationHelper.h"
#import "VacationPhotosTableViewController.h"

@interface TagsTableViewController ()
@property (nonatomic, strong) UIManagedDocument *tagsDatabase; 

@end

@implementation TagsTableViewController
@synthesize tagsDatabase = _tagsDatabase;
@synthesize vacation = _vacation;

-(void)setVacation:(NSString *)vacation
{
    if (_vacation!=vacation) _vacation=vacation;
}

-(void)setTagsDatabase:(UIManagedDocument *)tagsDatabase
{
    if (_tagsDatabase != tagsDatabase) {
        _tagsDatabase = tagsDatabase;
     [self useDocument];
    }
}

- (void) setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
   
    //all TAGS!!
    //request.predicate = nil;
   
    

    
    
   request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"used" ascending:NO selector:@selector(compare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request 
                                                                       managedObjectContext:self.tagsDatabase.managedObjectContext
                                                                         sectionNameKeyPath:nil cacheName:nil ];
}

//hook to the database!
-(void)useDocument
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.tagsDatabase.fileURL path]]) // se il db non esiste nel disco
    {
        //[self.tagsDatabase saveToURL:self.tagsDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            //[self setupFetchedResultsController];  
            //[self fetchFlickrDataIntoDocument:self.tagsDatabase];
            
        //}];
    } else if (self.tagsDatabase.documentState == UIDocumentStateClosed) // se il db esiste ma è chiuso
    {
        [self.tagsDatabase openWithCompletionHandler:^(BOOL success) {
            [self setupFetchedResultsController];  
            NSLog(@"db chiuso");
            
        }];
    } else if (self.tagsDatabase.documentState == UIDocumentStateNormal) // se il db è già aperto
    {
        [self setupFetchedResultsController]; 
        NSLog(@"db aperto");
    }
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.title=@"Tags";
    if (!self.tagsDatabase) {
        
        self.tagsDatabase = [VacationHelper sharedManagedDocumentForVacation:self.vacation];
    }
    //else{ [self useDocument];}

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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"tag cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [tag.tag_name capitalizedString];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photos (nel db) %@", [tag.taggedPhotos count], tag.used];
    
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
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
  if ([segue.identifier isEqualToString:@"vacation photos"]){
        Tag *tag =[self.fetchedResultsController objectAtIndexPath:indexPath];
      [segue.destinationViewController setMytag:tag];
      [segue.destinationViewController setVacationName:self.vacation];
    }

}

@end
