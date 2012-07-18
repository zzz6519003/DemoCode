//
//  GDGamesListViewController.h
//  GamesDatabase
//
//  Created by Antonio MG on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GDGamesListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UISearchBarDelegate>

@property (nonatomic,retain) NSManagedObjectContext* managedObjectContext;

@property (nonatomic, retain) IBOutlet UITableView *gamesTable;

@end
