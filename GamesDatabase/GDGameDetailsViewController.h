//
//  GDGameDetailsViewController.h
//  GamesDatabase
//
//  Created by Antonio MG on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GameInfo.h"

@interface GDGameDetailsViewController : UIViewController

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *platformLabel;
@property (nonatomic, retain) IBOutlet UILabel *rate;
@property (nonatomic, retain) IBOutlet UITextView *plotView;
@property (nonatomic, retain) IBOutlet UIImageView *gameImage;
@property (nonatomic, retain) GameInfo *gameInfo;

@end
