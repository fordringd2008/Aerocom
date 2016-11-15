//
//  CustomTabBarViewController.m
//  SoftTrans
//
//  Created by yyh on 6/9/14.
//  Copyright (c) 2014 yyh. All rights reserved.
//

#import "CustomTabBarController.h"
#import "vcUser.h"
#import "vcSet.h"
#import "vcHelp.h"
#import "LSNavigationController.h"

@interface CustomTabBarController ()

@end

@implementation CustomTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadSubviewController];
}

-(void)loadSubviewController
{
    UIStoryboard *indexSB = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]]; // navMain
    LSNavigationController *navIndex = [indexSB instantiateViewControllerWithIdentifier:@"navMain"];
    LSNavigationController *navUser = [indexSB instantiateViewControllerWithIdentifier:@"navUser"];
    LSNavigationController *navSet = [indexSB instantiateViewControllerWithIdentifier:@"navSet"];
    LSNavigationController *navHelp = [indexSB instantiateViewControllerWithIdentifier:@"navHeip"];
    
    
    navIndex.showLeft = ^(){
        AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        YRSideViewController *sideViewController = [delegate sideViewController];
        [sideViewController showLeftViewController:true];
    };
    
    navUser.showLeft = [navIndex.showLeft copy];
    navSet.showLeft = [navIndex.showLeft copy];
    navHelp.showLeft = [navIndex.showLeft copy];
    
    self.viewControllers = [NSArray arrayWithObjects:navIndex, navUser, navSet, navHelp,nil];
    self.tabBar.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
