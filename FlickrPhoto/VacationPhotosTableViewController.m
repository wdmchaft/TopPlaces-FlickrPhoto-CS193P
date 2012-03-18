//
//  VacationPhotosTableViewController.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 15/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VacationPhotosTableViewController.h"
#import "Photo.h"
#import "PhotoViewController.h"

@interface VacationPhotosTableViewController ()

@end

@implementation VacationPhotosTableViewController
@synthesize place = _place;
@synthesize mytag =_mytag;
@synthesize vacationName = _vacationName;



- (void) setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    NSManagedObjectContext *moc = [[VacationHelper sharedManagedDocumentForVacation:self.vacationName] managedObjectContext];
    if (moc == self.place.managedObjectContext ) NSLog(@"ao sono uguali");
    if (self.place) {
        NSLog(@"query place");
        //foto scattate da un certo fotografo
        request.predicate = [NSPredicate predicateWithFormat:@"scattateDove.place_description = %@", self.place.place_description];
        //moc = self.place.managedObjectContext;    
    }  else if (self.mytag)
    { NSLog(@"query tag: %@",self.mytag.tag_name);
        //request.predicate = [NSPredicate predicateWithFormat:@"etichettataDa.tag_name CONTAINS %@", self.tag.tag_name];
        request.predicate = [NSPredicate predicateWithFormat:@"ANY etichettataDa.tag_name = %@", self.mytag.tag_name]; // va bene anche il predicato sopra; questo qui è qualcosa tipo : qualsiasi (foto) collegata al tag (etichettataDa) che si chiama tag_name
        // moc = self.mytag.managedObjectContext;
    }
    
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]; // senza il selector l'ordinamento era case insensitive
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request 
                                                                       managedObjectContext:moc
                                                                         sectionNameKeyPath:nil cacheName:nil ];
}



-(void)setMytag:(Tag *)mytag
{
    _mytag=mytag;
    self.title=mytag.tag_name;
    [self setupFetchedResultsController];
}


-(void)setPlace:(Place *)place
{
    _place = place;
    self.title = place.place_description;
    [self setupFetchedResultsController];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"vacation photo cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = ![photo.title isEqualToString:@""]? photo.title : @"untitled";
    cell.detailTextLabel.text = photo.tags;
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([segue.identifier isEqualToString:@"Show Photo"]) {
        [segue.destinationViewController setPhotoFromVacation:photo];
        [segue.destinationViewController setTitle:photo.title];
    }
}
@end


