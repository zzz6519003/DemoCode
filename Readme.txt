### GamesDatabase ###

================================================================================
DESCRIPTION:

The GamesDatabase project is an open source demo app that demostrates some advanced features in iOS. It's only purpose is to show some iOS features for demo purposes.

The app contains a main view where all the games are displayed, with a search bar and a sort by button. Once one of the games is selected, the app will move to the details view, where the user can see the details of it.

Some of the features already included:

- Model View Controller pattern.
- Core Data to save the data.
- JSON file containing the initial data, and NSJSONSerialization to parse it.
- Custom schema, so the app has an entry point every  time Safari or other app call the URL: gamesdb://
- Some UIKit elements as UITableview, UIBarButtonItem, UIActionSheet, UIImageView, UILabel, UITextView.
- NSSortDescriptor to sort the array.
- NSOperationQueue to download the images in background.
- NSUserDefaults to avoid rewriting the json in the database every time it opens.


The code is clean of warnings and memory leaks.

It has been tested with Intruments (Leaks and Allocations)

================================================================================
BUILD REQUIREMENTS:

iOS SDK 5.0

================================================================================
RUNTIME REQUIREMENTS:

iOS 5.0 or later

================================================================================
DEVICE:

iPhone

================================================================================

Antonio Martinez  - August 2012
tonio.mg@gmail.com