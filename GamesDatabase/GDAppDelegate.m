//
//  GDAppDelegate.m
//  GamesDatabase
//
//  Created by Antonio MG on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GDAppDelegate.h"

#import "GDGamesListViewController.h"

#import "GameInfo.h"

@implementation GDAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize navigationController = _navigationController;

#define SETTINGS_FIRST_RUN  @"firstRun"
#define JSON_KEY_MAIN       @"games"
#define JSON_KEY_PLATFORM   @"platform"
#define JSON_KEY_STORY      @"story"
#define JSON_KEY_NAME       @"name"
#define JSON_KEY_RATE       @"rate"
#define JSON_KEY_URL        @"imgURL"
#define JSON_KEY_WIKIURL    @"wikiURL"

- (void)dealloc
{
    [_window release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [_navigationController release];
    [super dealloc];
}

//Handling custom schema.
//The URL can be called from Safari or from any other app
//For example:
//gamesdb://name=Super%20Mario&rate=3
//gamesdb://name=Mega&rate=5

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //Read the URL and the parameters
    NSString *name;
    int rate;
    
    NSString *parameterString = [[[url absoluteString] componentsSeparatedByString:@"gamesdb://"] objectAtIndex:1];    
    parameterString = [parameterString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSArray *keyValuePairs = [parameterString componentsSeparatedByString:@"&"];
    
    //check if the parameters are correct
    NSArray *nameParameter = [[keyValuePairs objectAtIndex:0] componentsSeparatedByString:@"="];
    NSArray *rateParameter = [[keyValuePairs objectAtIndex:1] componentsSeparatedByString:@"="];
    
    if ([[nameParameter objectAtIndex:0] isEqualToString:@"name"] && [[rateParameter objectAtIndex:0] isEqualToString:@"rate"]){
        name = [nameParameter objectAtIndex:1];
        rate = [[rateParameter objectAtIndex:1] intValue];
        
        if (rate >= 0 && rate<= 5){
            //Replace in the database
            NSManagedObjectContext *context = [self managedObjectContext];
            
            NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
            [fetch setEntity:[NSEntityDescription entityForName:@"GameInfo" inManagedObjectContext:context]];
            [fetch setPredicate:[NSPredicate predicateWithFormat:@"name contains %@",name]];
            
            NSError *error;
            GameInfo *gameToUpdate = [[context executeFetchRequest:fetch error:&error] lastObject];
            [fetch release];
            
            gameToUpdate.rate = [NSNumber numberWithInt:rate];
            
            [context save:nil];
        }
    }
    
    //In any case, the app will run
    return YES;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //Load the json and write the database (only the first time)
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //To reload the data without deleting the app:
    //[userDefaults setBool:FALSE forKey:SETTINGS_FIRST_RUN];
    
    if (![userDefaults objectForKey:SETTINGS_FIRST_RUN]){
    
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Data" ofType:@"json"];
        
        NSError *errorParsing;
        NSDictionary *dataToParse = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:NSJSONReadingMutableContainers error:&errorParsing];
        
        if (dataToParse != nil){
            
            //JSON parsed ok, save it in database
            NSManagedObjectContext *context = [self managedObjectContext];
            
            //Delete all previous content (this will avoid duplicate content if there was an error)
            NSFetchRequest *fetch = [[[NSFetchRequest alloc] init] autorelease];
            [fetch setEntity:[NSEntityDescription entityForName:@"GameInfo" inManagedObjectContext:context]];
            NSArray *result = [context executeFetchRequest:fetch error:nil];
            for (id gameItem in result){
                [context deleteObject:gameItem];
            }
            
            //For every element, create a gameInfo object
            for (NSDictionary *gameParsed in [dataToParse objectForKey:JSON_KEY_MAIN])
            {
                GameInfo *gameInfo = [NSEntityDescription insertNewObjectForEntityForName:@"GameInfo" inManagedObjectContext:context];
                gameInfo.name = [gameParsed objectForKey:JSON_KEY_NAME];
                gameInfo.platform = [gameParsed objectForKey:JSON_KEY_PLATFORM];
                gameInfo.story = [gameParsed objectForKey:JSON_KEY_STORY];
                gameInfo.imgURL = [gameParsed objectForKey:JSON_KEY_URL];
                gameInfo.rate = [NSNumber numberWithInt:[[gameParsed objectForKey:JSON_KEY_RATE] intValue]];
                
                NSError *error;
                if (![context save:&error]) {
                    NSLog(@"Problem saving: %@", [error localizedDescription]);
                }
                else{
                    //Everything went correct
                    [userDefaults setBool:TRUE forKey:SETTINGS_FIRST_RUN];
                    [userDefaults synchronize];
                }
            }
            
            
        }
        else{
            NSLog(@"Error parsing JSON:%@", [errorParsing localizedDescription]);
        }
    }

    //Init the app
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.

    GDGamesListViewController *mainViewController = [[[GDGamesListViewController alloc] initWithNibName:@"GDGamesListViewController" bundle:nil] autorelease];
    self.navigationController = [[[UINavigationController alloc] initWithRootViewController:mainViewController] autorelease];
    mainViewController.managedObjectContext = self.managedObjectContext;
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"GamesDatabase" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"GamesDatabase.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
