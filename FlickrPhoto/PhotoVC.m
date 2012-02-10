//
//  PhotoVC.m
//  FlickrPhoto
//
//  Created by Marzoli Alessandro on 08/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoVC.h"
#import "FlickrFetcher.h"
@interface PhotoVC() <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation PhotoVC
@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;
@synthesize spinner = _spinner;
@synthesize photoToShow = _photoToShow;

- (void)scrollViewSetup {
      //per avere subito un'immagine sul display che visualizza gran parte dell'immagine: ASPECT FILL nello storyboard :)
    UIImage *image = self.imageView.image;
    self.scrollView.zoomScale = 1;
    self.scrollView.contentSize = image.size;
    self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // code to zoom to correct level for aspect fill
    float heightRatio = self.imageView.image.size.height / self.scrollView.frame.size.height;
    float widthRatio = self.imageView.image.size.width / self.scrollView.frame.size.width;
    NSLog(@" %g",heightRatio);
    NSLog(@" %g",widthRatio);
    if (heightRatio > widthRatio) {
        self.scrollView.zoomScale = 1 / widthRatio;
    } else {
        self.scrollView.zoomScale = 1 / heightRatio;
    }
}


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
     self.scrollView.backgroundColor = [UIColor blackColor];
    [self.spinner startAnimating];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue,^{
        //block
        NSURL *urlPhoto = [FlickrFetcher urlForPhoto:self.photoToShow format:FlickrPhotoFormatLarge];
        NSData *imageData = [NSData dataWithContentsOfURL:urlPhoto];
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


}


- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
   //[self scrollViewSetup];  //nota: resetta lo zoom
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self; // lo posso fare anche dallo storyboard lez.8 1:01
   
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
