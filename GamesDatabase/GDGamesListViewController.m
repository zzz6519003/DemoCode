//
//  GDGamesListViewController.m
//  GamesDatabase
//
//  Created by Antonio MG on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
// This is the ViewController of the main view. It will display the data of the model in the view, following the MVC design pattern.
// It includes a search bar, and a Sort By Name or Rate functionality.
// When the user touchs a cell, it will move to the details screen.


#import "GDGamesListViewController.h"
#import "GDGameDetailsViewController.h"

#import "GameInfo.h"

@interface GDGamesListViewController ()

@property (nonatomic, retain) NSArray *gamesOriginal;
@property (nonatomic, retain) NSMutableArray *gamesFiltered;
@property (nonatomic, retain) NSMutableArray *imgsDownloaded;
@property (nonatomic, retain) NSOperationQueue *queue;

-(void)sortArrayBy:(NSString *)field;
-(IBAction)showSortByActionSheet:(id)sender;

@end

@implementation GDGamesListViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize gamesOriginal = _gamesOriginal;
@synthesize gamesFiltered = _gamesFiltered;
@synthesize queue = _queue;
@synthesize imgsDownloaded = _imgsDownloaded;
@synthesize gamesTable = _gamesTable;

-(void)dealloc
{    
    [_managedObjectContext release];
    [_gamesOriginal release];
    [_gamesFiltered release];
    [_queue release];
    [_imgsDownloaded release];
    [_gamesTable release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.queue = [[[NSOperationQueue alloc] init] autorelease];
        self.imgsDownloaded = [[[NSMutableArray alloc] init] autorelease];
        
        UIBarButtonItem *sortButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Sort By", @"Sort By") style:UIBarButtonItemStylePlain
                                                                         target:self action:@selector(showSortByActionSheet:)];      
        self.navigationItem.rightBarButtonItem = sortButton;
        [sortButton release];
        
        self.title = NSLocalizedString(@"Games Wall", @"Games Wall");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    //Get the data from the database
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"GameInfo" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    self.gamesOriginal = [[[NSArray alloc] initWithArray:[self.managedObjectContext executeFetchRequest:fetchRequest error:&error]] autorelease];
    [fetchRequest release];
    
    //Put the objects in the filtered array
    self.gamesFiltered = [[[NSMutableArray alloc] initWithArray:self.gamesOriginal] autorelease];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.gamesTable = nil;
    self.gamesOriginal = nil;
    self.gamesFiltered = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Table view data source & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.gamesFiltered count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GameCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    GameInfo *gameInfo = [self.gamesFiltered objectAtIndex:indexPath.row];
    cell.textLabel.text = gameInfo.name;
    cell.detailTextLabel.text = gameInfo.platform;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //the user has selected a cell, look for the info in the gamesArray and open the details View
    
    GameInfo *info = [self.gamesFiltered objectAtIndex:indexPath.row];

    GDGameDetailsViewController *detailsView = [[GDGameDetailsViewController alloc] initWithNibName:@"GDGameDetailsViewController" bundle:nil];
    detailsView.gameInfo = info;
    [self.navigationController pushViewController:detailsView animated:YES];
    [detailsView release];

}

#pragma mark IB Actions

//Show the action sheet when the user press in SortBy
-(IBAction)showSortByActionSheet:(id)sender {
   
    UIActionSheet *sortBySelection = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Sort By", @"Sort By") delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Rate",@"Name", nil];
    sortBySelection.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [sortBySelection showInView:self.view];
    [sortBySelection release];
}


#pragma mark ActionSheet Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  
    switch (buttonIndex) {
        case 0:
            [self sortArrayBy:@"rate"];
            break;
        case 1:
            [self sortArrayBy:@"name"];
            break;
            
        default:
            break;
    }
}

#pragma SearchBar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    //Filter the array
    NSMutableArray *itemsToDelete = [NSMutableArray array];
    
    for (GameInfo *game in self.gamesFiltered){
        if ([game.name rangeOfString:searchText options:NSCaseInsensitiveSearch].location == NSNotFound){
            
            [itemsToDelete addObject:game];
        }
    }
    
    [self.gamesFiltered removeObjectsInArray:itemsToDelete];
    
    [self.gamesTable reloadData];

    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //Search is finished
    [searchBar resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
    //Cancel all the search    
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    
    self.gamesFiltered = [[[NSMutableArray alloc] initWithArray:self.gamesOriginal] autorelease];
    
    [self.gamesTable reloadData];
}
    
#pragma mark Sort methods   

//sort the array of games depending on the user selection and display it
-(void)sortArrayBy:(NSString *)field{
    
    //Reorder the array by rate or name
    BOOL isAscending;
    
    if ([field isEqualToString:@"rate"]){
        isAscending = false;
    }
    else if ([field isEqualToString:@"name"]){
        isAscending = true;
    }
    else{
        isAscending = false;
    }
    
    //Create the descriptor
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:field
                                                  ascending:isAscending] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [self.gamesFiltered sortedArrayUsingDescriptors:sortDescriptors];    
    self.gamesFiltered = [[[NSMutableArray alloc] initWithArray:sortedArray] autorelease];
    
    //Reload the data in the view
    [self.gamesTable reloadData];
}


@end
