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

@interface PhotoVC() <UIScrollViewDelegate>
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
    
    // devo controllare (self.photoToShow)??

    
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
}

//getter
- (NSDictionary *)photoToShow
{
    //se non imposto la foto, prendo l'ultima
    if (!_photoToShow) {
        _photoToShow = [[[NSUserDefaults standardUserDefaults] objectForKey:LAST_VIEWED_PHOTOS_KEY] lastObject];
    }
    return _photoToShow;
}

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
    [self fetchPhoto];


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
