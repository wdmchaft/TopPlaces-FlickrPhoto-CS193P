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
            //NSLog(@"we're on screen, so update the image");
        } else {                        // we're not on screen, so no need to loadImage (it will happen next viewWillAppear:)
            self.imageView.image = nil; // but image has changed (so we can't leave imageView.image the same, so set to nil)
            //NSLog(@"we're not on screen, so no need to loadImage");
        }

    }
    if ([self splitViewBarButtonItemPresenter]) {
        

            UIBarButtonItem *visit_button = [[UIBarButtonItem alloc] initWithTitle:@"unvisit" style:UIBarButtonItemStyleBordered target:nil action:@selector(visitMe:)];
            UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            
            
        NSMutableArray *toolbarItems = [[NSMutableArray alloc] init];
        //  [toolbarItems removeObject:visit_button];
        //[toolbarItems removeObject:flexibleSpaceLeft];
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
    //per avere subito un'immagine sul display che visualizza gran parte dell'immagine: ASPECT FILL nello storyboard :)
    
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
            //NSLog(@"Foto non in cache");
            
            /**
             CGRect bounds = [self.view bounds];
             CGPoint centerPoint = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
             self.scrollView.backgroundColor = [UIColor blackColor];
             //self.imageView.hidden=YES; 
             
             UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
             [spinner setBackgroundColor:[UIColor redColor]];
             [spinner setCenter:centerPoint];
             [self.view addSubview:spinner];
             [spinner startAnimating];
             **/
            [self.spinner startAnimating];
            
            dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
            dispatch_async(downloadQueue,^{
                //block
                
                NSURL *urlPhoto = [FlickrFetcher urlForPhoto:self.photoToShow format:FlickrPhotoFormatLarge];
                NSData *imageData = [NSData dataWithContentsOfURL:urlPhoto];
                [self.cache put:imageData for:self.photoToShow]; //NSFileManager è thread-safe (a meno che non usi la stessa istanza in 2 thread separati)
                
                //***SIMULA LA LATENZA DELLA RETE mettendo il thread in sleep per 5sec***
                //[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.spinner stopAnimating]; //nello storyboard è impostato come hidesWhenStopped
                    
                    self.imageView.image = [UIImage imageWithData:imageData]; 
                    // imposto il size dello scrollview uguale a quello dell'immagine
                    
                    [self scrollViewSetup];
                    
                    //self.scrollView.contentSize = self.imageView.image.size; //contentsize is the width and height of your content
                    
                    //setting the frame which is where in the content area of the scrollview that the image view is gonna live (setting it to be the entire content area)
                    //per avere subito un'immagine sul display che visualizza gran parte dell'immagine: ASPECT FILL nello storyboard
                    //questa riga di codice successiva mi crea un frame (rettangolo della view con le coordinate della superview) in 0,0 grande quanto l'immagine in large mode
                    //self.imageView.frame= CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
                    
                    //RICORDARSI DI IMPOSTARE IL DELEGATE!! :)
                });
                
            });
            dispatch_release(downloadQueue); //altrimenti c'è un memory leak
            
        } //fine else se la foto non è in cache
    } //fine controllo esistenza self.photoToShow --> se non esiste non faccio nulla
}

/**
//getter L'ho tolto una volta implementato l'assignment 6 perchè mi serve anche la condizione self.photoToShow=nil in viewWillAppear
- (NSDictionary *)photoToShow
{
    //se non imposto la foto, prendo l'ultima
    if (!_photoToShow) {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:LAST_VIEWED_PHOTOS_KEY] lastObject]){ //se esiste almeno un elemento in NSUserDefaults (esempio: primo avvio dell'app da ipad, devo visualizzare un immagine iniziale ma non ho niente nè in userdefaults nè in cache
            _photoToShow = [[[NSUserDefaults standardUserDefaults] objectForKey:LAST_VIEWED_PHOTOS_KEY] lastObject];
        } else{
            //NSLog(@"non è nessuna immagine!"); 
            //non devo gestire nient'altro perchè in fetchPhoto se è nil non faccio nulla
        }
    }
    return _photoToShow;
}
**/


//setter
-(void) setPhotoToShow:(NSDictionary *)photoToShow
{ 
    if (_photoToShow != photoToShow) { 
        _photoToShow = photoToShow;
        
        // for good usability, immediately show photo title while waiting for photo download
        NSString *titolo = [self.photoToShow objectForKey:FLICKR_PHOTO_TITLE];
        self.title = titolo;
        
        //self.scrollView.zoomScale=1; //se la foto è diversa, resetto a 1 lo zoom
        
        //la salvo dentro un orderset
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
            //potevo usare anche:
            //[lastPhotos removeObject:photoToShow];
            //[lastPhotos addObject:photoToShow];
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
      //  [toolbarItems removeObject:visit_button];
        //[toolbarItems removeObject:flexibleSpaceLeft];
        if (self.splitViewBarButtonItem) [toolbarItems addObject:self.splitViewBarButtonItem];
        [toolbarItems addObject:flexibleSpaceLeft];
        [toolbarItems addObject:visit_button];
            self.toolbar.items = toolbarItems;
    }
}


#pragma mark - Ipad

/*** IPAD ***/

//setter
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
    //mostra il button solo in portrait mode
    return [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Photos"; 
    // tell the detail view to put this button up
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    //tell the detail view to take the button away
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
}





- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */

/**
- (void)updateVisitButtonTitle
{
    self.visitButton.title = @"visit";    
    NSArray *vacations = [VacationManager vacationsList];
    for (NSString *vacationName in vacations) {
        UIManagedDocument *doc = [VacationManager sharedManagedDocumentForVacation:[vacationName lastPathComponent]];
        Photo *photo = [Photo photoInDocumentWithFlickrId:[self.photoToShow valueForKey:FLICKR_PHOTO_ID] inManagedObjectContext:doc.managedObjectContext];
       if (photo) self.visitButton.title = @"unvisit";
        //else self.visitButton.title = @"visit";
    
    }    
}
**/

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.scrollView.backgroundColor = [UIColor blackColor];
    //UIBarButtonItem *vacationButton = nil;
    
    if (self.photoToShow) {
        self.visitButton.title= @"visit";
        //[self updateVisitButtonTitle]; //perchè posso aggiungere e rimuovere una foto mentre la vedo (non da una delle vacation)
        [self fetchPhoto]; 
           }
    else if (self.photoFromVacation) {
        self.visitButton.title= @"unvisit"; // posso solo fare il delete
        //NSLog(@"loading photo from db ...");
        [self loadImage];
           }
    
  }



//premo il tasto visit ed appare la lista di vacanze

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
    //[PhotoManager useDocumentName:@"my default vacation" toDeletePhoto:self.photoFromVacation];
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

//aggiunge la foto alla vacanza
-(void)visit:(NSString *)vacationName
{
    NSString *docName = [vacationName lastPathComponent];
   [PhotoManager useDocument:docName withPhoto:self.photoToShow];
    
    self.visitButton.title = @"unvisit";
   
}

//quando seleziono una vacanza...
-(void)VirtualVacationsTableViewController:(VirtualVacationsTableViewController *)sender didSelectVacation:(NSString *)vacationName
{
    [self visit:vacationName];
    [self dismissModalViewControllerAnimated:YES];
    
}


- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    //[self scrollViewSetup];  //nota: resetta lo zoom
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self; // lo posso fare anche dallo storyboard lez.8 1:01
    self.splitViewController.delegate = self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView; //return la view che voglio zoomare
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

