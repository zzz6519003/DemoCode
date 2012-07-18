//
//  GDGameDetailsViewController.m
//  GamesDatabase
//
//  Created by Antonio MG on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GDGameDetailsViewController.h"

@interface GDGameDetailsViewController ()

@property (nonatomic, retain) NSOperationQueue *queue;

@end

@implementation GDGameDetailsViewController

@synthesize nameLabel = _nameLabel;
@synthesize platformLabel = _platformLabel;
@synthesize rate = _rate;
@synthesize plotView = _plotView;
@synthesize gameImage = _gameImage;
@synthesize gameInfo = _gameInfo;
@synthesize queue = _queue;


-(void)dealloc
{
    [_nameLabel release];
    [_platformLabel release];
    [_rate release];
    [_plotView release];
    [_gameImage release];
    [_gameInfo release];
    [_queue release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.queue = [[[NSOperationQueue alloc] init] autorelease];
        
        self.title = @"Details";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Put the data in the screen
    
    //Load the image in background mode
    NSBlockOperation *downloadImgBlock = [NSBlockOperation blockOperationWithBlock:^(void){
        NSURL *imgURL = [NSURL URLWithString:self.gameInfo.imgURL];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imgURL]];
        //Set the image in the main thread, to save time updating it
        [self performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
    }];
    [self.queue addOperation:downloadImgBlock];
    
    //Load the texts
    self.nameLabel.text = self.gameInfo.name;
    self.plotView.text = self.gameInfo.story;
    self.platformLabel.text = self.gameInfo.platform;
    self.rate.text = [NSString stringWithFormat:@"%d/5", [self.gameInfo.rate intValue]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.nameLabel = nil;
    self.platformLabel = nil;
    self.rate = nil;
    self.plotView = nil;
    self.gameImage = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)setImage:(UIImage *)image{
    self.gameImage.image = image;
}

@end
