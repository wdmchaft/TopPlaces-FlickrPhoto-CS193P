//
//  PhotosByPlaceTableViewController.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 10/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotosByPlaceTableViewController.h"
#import "Photo.h"
#import "PhotoViewController.h"

@interface PhotosByPlaceTableViewController ()

@end

@implementation PhotosByPlaceTableViewController
@synthesize place = _place;




- (void) setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    
    //foto scattate da un certo fotografo
    request.predicate = [NSPredicate predicateWithFormat:@"scattateDove.place_description = %@", self.place.place_description];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]; // senza il selector l'ordinamento era case insensitive
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request 
                                                                       managedObjectContext:self.place.managedObjectContext
                                                                         sectionNameKeyPath:nil cacheName:nil ];
}

-(void)setPlace:(Place *)place
{
    _place = place;
    self.title = place.place_description;
     [self setupFetchedResultsController];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"photo cell of a place";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    //importo "photo.h" e non "photo+flick.h" perchè non creo foto ma le uso!!
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.title;
    //cell.detailTextLabel.text = photo.subtitle;
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath]; // ask NSFRC for the NSMO at the row in question
    if ([segue.identifier isEqualToString:@"Show Photo"]) {
        [segue.destinationViewController setPhotoFromVacation:photo];
        [segue.destinationViewController setTitle:photo.title];
    }
}


@end
