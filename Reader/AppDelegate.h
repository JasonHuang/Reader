//
//  AppDelegate.h
//  Reader
//
//  Created by 黄 鹏霄 on 13-6-4.
//  Copyright (c) 2013年 renweishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PSStackedView/PSStackedView.h>

#define XAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@class PSStackedViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    PSStackedViewController *stackController_;
}

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong, readonly) PSStackedViewController *stackController;


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
