//
//  PhotoViewController.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 08/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoViewController.h"
#import "FlickrFetcher.h"
#import "PhotoCaching.h"
#import "VacationHelper.h"
#import "VirtualVacationsTableViewController.h"

@interface PhotoViewController() <UIScrollViewDelegate, VirtualVacationsTableViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong,nonatomic) PhotoCaching *cache;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *visitButton;

@end

@implementation PhotoViewController
@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;
@synthesize spinner = _spinner;
@synthesize toolbar = _toolbar;
@synthesize photoToShow = _photoToShow;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize cache = _cache;
@synthesize visitButton = _visitButton;
@synthesize photoFromVacation = _photoFromVacation;



- (void)loadImage
{
    if (self.imageView) { 
        if (self.photoFromVacation.photo_url) {
            
             [self.spinner startAnimating];
            dispatch_queue_t imageDownloadQ = dispatch_queue_create("flickr downloader 2", NULL);
            dispatch_async(imageDownloadQ, ^{
                 NSURL *photoUrl = [NSURL URLWithString:self.photoFromVacation.photo_url];
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:photoUrl]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.spinner stopAnimating]; //nello storyboard è impostato come hidesWhenStopped
                    self.imageView.image = image;
                });
            });
            dispatch_release(imageDownloadQ);
        } else {
            self.imageView.image = nil;
        }
    }
}


-(void)setPhotoFromVacation:(Photo *)photoFromVacation
{
    if (_photoFromVacation != photoFromVacation)
    {
        _photoFromVacation = photoFromVacation;
        if (self.imageView.window) {    // we're on screen, so update the image
            [self loadImage];   
     
        } else {                        // we're not on screen, so no need to loadImage (it will happen next viewWillAppear:)
            self.imageView.image = nil; // but image has changed (so we can't leave imageView.image the same, so set to nil)

        }

    }
    if ([self splitViewBarButtonItemPresenter]) {
        

            UIBarButtonItem *visit_button = [[UIBarButtonItem alloc] initWithTitle:@"unvisit" style:UIBarButtonItemStyleBordered target:nil action:@selector(visitMe:)];
            UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            
            
        NSMutableArray *toolbarItems = [[NSMutableArray alloc] init];
        if (self.splitViewBarButtonItem) [toolbarItems addObject:self.splitViewBarButtonItem];
        [toolbarItems addObject:flexibleSpaceLeft];
        [toolbarItems addObject:visit_button];
        self.toolbar.items = toolbarItems;
    }

         
    
}


- (PhotoCaching *)cache {
    if (!_cache) {
        _cache = [[PhotoCaching alloc] init];
    }
    return _cache;
}

- (void)scrollViewSetup {
    
    UIImage *image = self.imageView.image;
    self.scrollView.zoomScale = 1;
    self.scrollView.contentSize = image.size;
    self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    CGFloat widthScale = (self.scrollView.bounds.size.width / self.scrollView.contentSize.width);
    CGFloat heightScale = (self.scrollView.bounds.size.height / self.scrollView.contentSize.height);
    //maximum zoom scale: 5
    self.scrollView.minimumZoomScale = MIN(widthScale, heightScale);
    self.scrollView.zoomScale = MAX(widthScale, heightScale);

    
}

-(void)fetchPhoto{
    self.imageView.image = nil;

    if (self.photoToShow) {
        
        
        if ([self.cache contains:self.photoToShow])
        {//se la foto è nella cache
            NSData *photoData = [self.cache retrieve:self.photoToShow];
            self.imageView.image = [UIImage imageWithData:photoData]; 
        }
        
        else{
     
            [self.spinner startAnimating];
            
            dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
            dispatch_async(downloadQueue,^{
                //block
                
                NSURL *urlPhoto = [FlickrFetcher urlForPhoto:self.photoToShow format:FlickrPhotoFormatLarge];
                NSData *imageData = [NSData dataWithContentsOfURL:urlPhoto];
                [self.cache put:imageData for:self.photoToShow];
                
       
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.spinner stopAnimating]; 
                    
                    self.imageView.image = [UIImage imageWithData:imageData]; 
                                       
                    [self scrollViewSetup];
                    
                                });
                
            });
            dispatch_release(downloadQueue); 
            
        } 
    } 
}


-(void) setPhotoToShow:(NSDictionary *)photoToShow
{ 
    if (_photoToShow != photoToShow) { 
        _photoToShow = photoToShow;
        
        NSString *titolo = [self.photoToShow objectForKey:FLICKR_PHOTO_TITLE];
        self.title = titolo;
    
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableOrderedSet *lastPhotos = [NSMutableOrderedSet orderedSetWithArray:[defaults objectForKey:LAST_VIEWED_PHOTOS_KEY]]; //** kvalue
        if (!lastPhotos) {
            lastPhotos = [NSMutableOrderedSet orderedSet];
        }
        
        if ([lastPhotos containsObject:photoToShow]) 
        {
            int index = [lastPhotos indexOfObject:photoToShow];
            NSIndexSet *indexset = [NSIndexSet indexSetWithIndex:index];
            [lastPhotos moveObjectsAtIndexes:indexset toIndex:[lastPhotos indexOfObject:[lastPhotos lastObject]]];
          
        }
        else {
            if ([lastPhotos count]>=20) [lastPhotos removeObjectAtIndex:0];
            [lastPhotos addObject:photoToShow]; }
        
        [defaults setObject:[lastPhotos array] forKey:LAST_VIEWED_PHOTOS_KEY];
        [defaults synchronize];
        [self fetchPhoto];
        
    }  
    
    if ([self splitViewBarButtonItemPresenter]) {
        
            UIBarButtonItem *visit_button = [[UIBarButtonItem alloc] initWithTitle:@"visit" style:UIBarButtonItemStyleBordered target:nil action:@selector(visitMe:)];
            UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            

        NSMutableArray *toolbarItems = [[NSMutableArray alloc] init];
      
        if (self.splitViewBarButtonItem) [toolbarItems addObject:self.splitViewBarButtonItem];
        [toolbarItems addObject:flexibleSpaceLeft];
        [toolbarItems addObject:visit_button];
            self.toolbar.items = toolbarItems;
    }
}


#pragma mark - Ipad



- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (splitViewBarButtonItem != _splitViewBarButtonItem) {
        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
        if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
        if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolbar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

- (id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if (![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]) {
        detailVC = nil;
    }
    return detailVC;
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{ 
 
    return [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Photos"; 
 
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{

    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
}





- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.scrollView.backgroundColor = [UIColor blackColor];

    
    if (self.photoToShow) {
        self.visitButton.title= @"visit";

        [self fetchPhoto]; 
           }
    else if (self.photoFromVacation) {
        self.visitButton.title= @"unvisit"; 
        [self loadImage];
           }
    
  }




- (IBAction)visitMe:(UIBarButtonItem *)sender {
    VirtualVacationsTableViewController *vacationTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VirtualVacationsTableViewController"]; 
    [vacationTableViewController setDelegate:self];
    if ([sender.title isEqualToString:@"visit"]) {
        [self presentModalViewController:vacationTableViewController animated:YES];
    } else {
        [self unvisitMe];
    }

}


-(void)unvisitMe
{   
    [Photo deletePhoto:self.photoFromVacation fromManagedObjectContext:self.photoFromVacation.managedObjectContext];
    self.photoFromVacation = nil;
    [self.navigationController popViewControllerAnimated:YES];
    if ([self splitViewBarButtonItemPresenter]) {
        
        NSMutableArray *toolbarItems = [[NSMutableArray alloc] init];
        //[toolbarItems removeObject:visit_button];
        //[toolbarItems removeObject:flexibleSpaceLeft];
        if (self.splitViewBarButtonItem) [toolbarItems addObject:self.splitViewBarButtonItem];
        self.toolbar.items = toolbarItems;
    }

}

-(void)visit:(NSString *)vacationName
{
    NSString *docName = [vacationName lastPathComponent];
   [PhotoManager useDocument:docName withPhoto:self.photoToShow];
    
    self.visitButton.title = @"unvisit";
   
}

-(void)VirtualVacationsTableViewController:(VirtualVacationsTableViewController *)sender didSelectVacation:(NSString *)vacationName
{
    [self visit:vacationName];
    [self dismissModalViewControllerAnimated:YES];
    
}


- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self; 
    self.splitViewController.delegate = self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView; 
}



- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setScrollView:nil];
    [self setSpinner:nil];
    [self setToolbar:nil];
    [self setVisitButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end

