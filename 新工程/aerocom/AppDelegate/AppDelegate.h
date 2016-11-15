//
//  AppDelegate.h
//  ListedDemo
//
//  Created by 丁付德 on 15/6/22.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YRSideViewController.h"
#import <CoreData/CoreData.h>
#import "CustomTabBarController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CustomTabBarController *customTb;
@property (strong, nonatomic) YRSideViewController *sideViewController;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

//- (void)saveContext;
//- (NSURL *)applicationDocumentsDirectory;


@end

