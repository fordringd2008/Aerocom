//
//  vcFlowerList.h
//  aerocom
//
//  Created by 丁付德 on 15/7/10.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcBase.h"

@interface vcFlowerList : vcBase <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated;

@property(nonatomic, assign, readonly) BOOL showSectionIndexes;
//@property(nonatomic, strong, readonly) UITableView *tableView;
//@property(nonatomic, strong, readonly) UISearchBar *searchBar;

@end
