//
//  vcFlowerList.m
//  aerocom
//
//  Created by 丁付德 on 15/7/10.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcFlowerList.h"
#import "tvcFlowerList.h"
#import "vcFlowerDetail.h"
static NSString * const kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier = @"kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier";

@interface vcFlowerList ()

@property(nonatomic, copy) NSArray *famousPersons;                                          // 全部数据
@property(nonatomic, copy) NSArray *filteredPersons;                                        // 过滤后的数据
@property(nonatomic, copy) NSArray *sections;                                               // 组
@property(nonatomic, strong) UISearchDisplayController *strongSearchDisplayController;

@property(nonatomic, strong, readwrite) UITableView *tableView;
@property(nonatomic, strong, readwrite) UISearchBar *searchBar;


@property (nonatomic, strong) NSMutableArray *arrData;
//@property (nonatomic, strong) UITableView *tabView;

@end

@implementation vcFlowerList


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNavTitle:self title:@"花草分类选择"];
    
    NSLog(@"加载");
    __block vcFlowerList *blockSelf = self;
    NextWaitInGlobal(
         [blockSelf initData:0];, 0);
    //
    NextWaitInMain([blockSelf.tableView reloadData];);
    [self initData:100];
    NSLog(@"加载完");
    [self initTable];
    
    self.strongSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.delegate = self;
    
    self.tableView.contentOffset = CGPointMake(0, CGRectGetHeight(self.searchBar.bounds));
    [self.tableView flashScrollIndicators];
    
    // 在加载完所有数据前禁用搜索栏
    blockSelf.searchBar.userInteractionEnabled = NO;
}

- (void)dealloc
{
    NSLog(@"vcFlowerList 被销毁了");
}

- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    [self.tableView scrollRectToVisible:self.searchBar.frame animated:animated];
}


-(void)initData:(NSUInteger)count
{
    if (count)
    {
        NSString *regex = @"^(A|B).*";
        self.arrData = [[FlowerType findAllWithPredicate:[NSPredicate predicateWithFormat:@"SELF.startLetter MATCHES %@", regex] inContext:DBefaultContext] mutableCopy];
        NSLog(@"self.arrData = %d", (int)self.arrData.count);
    }
    else
        self.arrData = [[FlowerType findAllSortedBy:@"startLetter" ascending:YES inContext:DBefaultContext] mutableCopy];
    _showSectionIndexes = YES;
    self.famousPersons = self.arrData;
    
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    NSMutableArray *unsortedSections = [[NSMutableArray alloc] initWithCapacity:[[collation sectionTitles] count]];
    for (NSUInteger i = 0; i < [[collation sectionTitles] count]; i++)
    {
        [unsortedSections addObject:[NSMutableArray array]];
    }
    
    for (FlowerType *ft in self.famousPersons)
    {
        NSInteger index = [collation sectionForObject:ft.startLetter collationStringSelector:@selector(description)];
        [[unsortedSections objectAtIndex:index] addObject:ft];
    }
    
    NSMutableArray *sortedSections = [[NSMutableArray alloc] initWithCapacity:unsortedSections.count];
    for (NSMutableArray *section in unsortedSections)
    {
        [sortedSections addObject:[collation sortedArrayFromArray:section collationStringSelector:@selector(name)]];
    }
    
    __block vcFlowerList *bloSelf = self;
    NextWaitInMain(
       NSLog(@"------------- > 加载的数量 ： %@", @(count));
       if(!count) bloSelf.searchBar.userInteractionEnabled = YES;
       bloSelf.sections = sortedSections;
       [bloSelf.tableView reloadData];
    );
}

-(void)initTable
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, ScreenWidth, ScreenHeight - NavBarHeight - 50)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 50;
    self.tableView.bounces = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"tvcFlowerList" bundle:nil] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:self.tableView];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
    self.searchBar.placeholder = kString(@"搜索");
    self.searchBar.delegate = self;
    [self.view addSubview:self.searchBar];
}

#pragma mark - TableView Delegate and DataSource

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.tableView && self.showSectionIndexes)
    {
        return [[NSArray arrayWithObject:UITableViewIndexSearch] arrayByAddingObjectsFromArray:[[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];
    } else {
        return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView && self.showSectionIndexes)
    {
        if ([(NSArray *)[self.sections objectAtIndex:section] count] > 0)
        {
            return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if ([title isEqualToString:UITableViewIndexSearch])
    {
        [self scrollTableViewToSearchBarAnimated:NO];
        return NSNotFound;
    }
    else
        return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index] - 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView)
    {
        if (self.showSectionIndexes)
            return self.sections.count;
        else
            return 1;
    }
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView)
    {
        if (self.showSectionIndexes)
        {
            //NSLog(@"------------ 1 :%@", @([(NSArray *)[self.sections objectAtIndex:section] count]));
            return [(NSArray *)[self.sections objectAtIndex:section] count];
        }
        else
        {
//            NSLog(@"------------ 2 :%@", @(self.famousPersons.count));
            return self.famousPersons.count;
        }
    }
    else
    {
//        NSLog(@"------------ 3 :%@", @(self.filteredPersons.count));
        return self.filteredPersons.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcFlowerList*cell = [tvcFlowerList cellWithTableView:tableView];
    
    if (self.filteredPersons)
    {
        //NSLog(@"--- > %@", @(indexPath.row));
        if (indexPath.row < self.filteredPersons.count)
        {
            FlowerType *model = self.filteredPersons[indexPath.row];
            if (![cell.model isEqual:model]) cell.model = model;
        }
    }
    else
    {
        NSArray *arr = self.sections[indexPath.section];
        if(arr && arr.count > indexPath.row)
        {
            FlowerType *model = self.sections[indexPath.section][indexPath.row];
            if (![cell.model isEqual:model]) cell.model = model;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FlowerType *model;
    if (self.filteredPersons)
    {
        model = self.filteredPersons[indexPath.row];
    }
    else
    {
        model = self.sections[indexPath.section][indexPath.row];
    }
    
    [self performSegueWithIdentifier:@"flowerList_to_flowerDetail" sender:model];
}


#pragma mark - Search Delegate
// 第一次显示的回调
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    self.filteredPersons = self.famousPersons;
}

// 取消筛选的回调
- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.filteredPersons = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // scientificname otherName
    NSPredicate *pr = [NSPredicate predicateWithFormat:@"name contains %@ or otherName contains %@ or scientificname contains %@", searchString, searchString, searchString];
    self.filteredPersons = self.famousPersons;
    self.filteredPersons = [self.filteredPersons filteredArrayUsingPredicate:pr];
    NSLog(@"self.filteredPersons.count = %lu", (unsigned long)self.filteredPersons.count);
    return YES;
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"flowerList_to_flowerDetail"]) {
        vcFlowerDetail *vc = (vcFlowerDetail *)segue.destinationViewController;
        vc.model = sender;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}



@end
