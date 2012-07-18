//
//  GameInfo.h
//  GamesDatabase
//
//  Created by Antonio MG on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GameInfo : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * platform;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) NSString * story;
@property (nonatomic, retain) NSString * imgURL;
@property (nonatomic, retain) NSString * wikiURL;

@end
