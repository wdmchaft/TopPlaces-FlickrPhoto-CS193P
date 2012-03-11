//
//  PhotoVC.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 08/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoVC.h"
#import "FlickrFetcher.h"
#import "PhotoCaching.h"
#import "VacationManager.h"
#import "Photo+Flickr.h"

@interface PhotoVC() <UIScrollViewDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong,nonatomic) PhotoCaching *cache;
@end

@implementation PhotoVC
@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;
@synthesize spinner = _spinner;
@synthesize toolbar = _toolbar;
@synthesize photoToShow = _photoToShow;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize cache = _cache;
@synthesize imageURL = _imageURL;

- (void)loadImage
{
    if (self.imageView) { 
        if (self.imageURL) {
            
             [self.spinner startAnimating];
            dispatch_queue_t imageDownloadQ = dispatch_queue_create("flickr downloader 2", NULL);
            dispatch_async(imageDownloadQ, ^{
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.imageURL]];
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

- (void)setImageURL:(NSURL *)imageURL
{
     //NSLog(@" %@",imageURL);
    if (![_imageURL isEqual:imageURL]) {
        _imageURL = imageURL;
        if (self.imageView.window) {    // we're on screen, so update the image
            [self loadImage];   
            NSLog(@"we're on screen, so update the image");
        } else {                        // we're not on screen, so no need to loadImage (it will happen next viewWillAppear:)
            self.imageView.image = nil; // but image has changed (so we can't leave imageView.image the same, so set to nil)
             NSLog(@"we're not on screen, so no need to loadImage");
        }
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
    
    // code to zoom to correct level for aspect fill
    float heightRatio = self.imageView.image.size.height / self.scrollView.frame.size.height;
    float widthRatio = self.imageView.image.size.width / self.scrollView.frame.size.width;
    //NSLog(@" %g",heightRatio);
    //NSLog(@" %g",widthRatio);
    if (heightRatio > widthRatio) {
        self.scrollView.zoomScale = 1 / widthRatio;
    } else {
        self.scrollView.zoomScale = 1 / heightRatio;
    }
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
    
    
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
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


#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.scrollView.backgroundColor = [UIColor blackColor];
    UIBarButtonItem *vacationButton = nil;
    
    if (self.photoToShow) {
        NSLog(@"wwww"); 
        [self fetchPhoto];
        vacationButton = [[UIBarButtonItem alloc] 
                          initWithTitle:@"visit"                                            
                          style:UIBarButtonItemStyleBordered 
                          target:self 
                          action:@selector(visitMe)];
    
    }
    else if (self.imageURL) {
        NSLog(@"db");
        [self loadImage];
        vacationButton = [[UIBarButtonItem alloc] 
                          initWithTitle:@"unvisit"                                            
                          style:UIBarButtonItemStyleBordered 
                          target:self 
                          action:@selector(clickMe)];
    
    }


   if (vacationButton) self.navigationItem.rightBarButtonItem = vacationButton;
    
    
}


-(void) fetchFlickrDataIntoDocument:(UIManagedDocument *)document
{
    dispatch_queue_t fetchQ  = dispatch_queue_create("Flickr fetcher", NULL);
    dispatch_async(fetchQ, ^{
       
        [document.managedObjectContext performBlock:^{ //in questo modo sono nel thread giusto (dove è stato creato NSManagedObject) e non nel "flickr fetcher" thread (34')
            
            //se sapessi che viene fatto nel main thread potrei fare il "ritorno" al main thread come quando lavoro sulla ui
            
            // perform in the NSMOC's safe thread (main thread)
            
            
                // start creating obj in doc's context
                //popolo il db in background
                [Photo photoWithFlickrInfo:self.photoToShow inManagedObjectContext:document.managedObjectContext];
                
                // should probably saveToURL:forSaveOperation:(UIDocumentSaveForOverwriting)completionHandler: here!
                // we could decide to rely on UIManagedDocument's autosaving, but explicit saving would be better
                // because if we quit the app before autosave happens, then it'll come up blank next time we run
                // this is what it would look like (ADDED AFTER LECTURE) ...
                [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
                // note that we don't do anything in the completion handler this time
                
                
            
            
        }]; 
        
    });
    dispatch_release(fetchQ);
}

-(void)useDocument:(UIManagedDocument*)managedDocument
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[managedDocument.fileURL path]]) // se il db non esiste nel disco
    {
        [managedDocument saveToURL:managedDocument.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
           // [self setupFetchedResultsController];  
            [self fetchFlickrDataIntoDocument:managedDocument]; //inserisco nel db
            NSLog(@"db creato");
            
        }];
    } else if (managedDocument.documentState == UIDocumentStateClosed) // se il db esiste ma è chiuso
    {
        [managedDocument openWithCompletionHandler:^(BOOL success) {
            //[self setupFetchedResultsController];  
             [self fetchFlickrDataIntoDocument:managedDocument]; //inserisco nel db
            NSLog(@"db chiuso");
            
        }];
    } else if (managedDocument.documentState == UIDocumentStateNormal) // se il db è già aperto
    {
        //[self setupFetchedResultsController];  
         [self fetchFlickrDataIntoDocument:managedDocument]; //inserisco nel db
        NSLog(@"db aperto");
    }
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  
    NSString *docName= [actionSheet buttonTitleAtIndex:buttonIndex]; //dal tasto dell'actionSheet mi ricavo il nome della cartella nella directory
    if (![docName isEqualToString:@"Cancel"])
        {
      NSLog(@" %@ ", docName);
    [self useDocument:[VacationManager sharedManagedDocumentForVacation:docName]]; // richiamo useDocument con una shared session
        }
    //add photo to the core data
}

-(void)visitMe
{
  
   UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"Vacations"
                                        delegate:self
                               cancelButtonTitle:nil
                          destructiveButtonTitle:nil
                               otherButtonTitles:nil];
    
    // Show the sheet
    //[sheet showInView:self.view];
    VacationManager *vm= [[VacationManager alloc] init];
    NSArray *vacations = vm.vacations;
    
    
    for (int i = 0; i < [vacations count]; i++) {
        
        [sheet addButtonWithTitle:[[vacations objectAtIndex:i] lastPathComponent]];
        
    }
    
    [sheet addButtonWithTitle:@"Cancel"];
    sheet.cancelButtonIndex = [vacations count] +1;
    
    [sheet showFromTabBar:self.tabBarController.tabBar];
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

