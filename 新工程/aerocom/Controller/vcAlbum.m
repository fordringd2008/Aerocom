//
//  vcAlbum.m
//  aerocom
//
//  Created by 丁付德 on 15/7/2.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcAlbum.h"
#import "ImgScrollView.h"
#import "TapImageView.h"

#define viewStatusShowFrame             CGRectMake(0, ScreenHeight - NavBarHeight - 50, ScreenWidth, 50)
#define viewStatusHiddenFrame           CGRectMake(0, ScreenHeight - NavBarHeight, ScreenWidth, 50)
#define ANIMATIONTIME                   0.2
#define tableViewFirstFrame             CGRectMake(0, 0, ScreenWidth, ScreenHeight - NavBarHeight)
#define tableViewSecondtFrame           CGRectMake(0, 0, ScreenWidth, ScreenHeight - NavBarHeight - 50)

#define imgSelected                     [UIImage imageNamed:@"select_bar_press"]
#define imgUnSelected                   [UIImage imageNamed:@"select_bar_normal"]


@interface vcAlbum()<UITableViewDataSource,UITableViewDelegate,TapImageViewDelegate,ImgScrollViewDelegate,UIScrollViewDelegate>
{
    UITableView *myTable;
    UICollectionView *clv;
    UIScrollView *myScrollView;
    NSInteger currentIndex;
    
    UIView *markView;
    UIView *scrollPanel;
    UITableViewCell *tapCell;
    
    ImgScrollView *lastImgScrollView;
    BOOL isInDelete;                        // 当前是否是删除模式
    
    UIView *viewStatus;                     // 底部的删除状态栏
    UIButton *btnSelectAll;                 // 全选按钮
    
    NSMutableArray *arrSelect;              // 选中的要删除的索引       类型 NSNumber
    
    BOOL isShowRightButton;
    

}

@property (strong, nonatomic) NSMutableArray  *arrData;

@end

@implementation vcAlbum

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavTitle:self title:@"相册"];//我的花园
    
    [self initData];
    [self initView];
    
    // 图片编辑功能
    
    isShowRightButton = YES;
    [self refreshRightButton];
}

-(void)rightButtonClick
{
    if (isShowRightButton) {
        if(!self.arrData.count)
            return;
        isInDelete = !isInDelete;
        [self changeShowStatusView];
        [myTable reloadData];
    }
}

-(void)refreshRightButton
{
    if (isShowRightButton)
        [self initRightButton:nil imgName:@"delect_bg"];
    else
        [self initRightButton:nil imgName:nil];
}

-(void)initData
{
    NSNumber * flowerID = self.flower.my_plant_id ? self.flower.my_plant_id : self.flower.my_plant_id;
    self.arrData = [[Album findByAttribute:@"flowerID" withValue:flowerID] mutableCopy];
    NSLog(@"count = %lu" ,(unsigned long)self.arrData.count);
    isInDelete = NO;
    arrSelect = [NSMutableArray new];
}
-(void)initView
{
    scrollPanel = [[UIView alloc] initWithFrame:self.view.bounds];
    scrollPanel.backgroundColor = RGBA(245, 245, 245, 0.5);
    scrollPanel.alpha = 0;
    [self.view addSubview:scrollPanel];
    
    markView = [[UIView alloc] initWithFrame:scrollPanel.bounds];
    markView.backgroundColor = [UIColor blackColor];
    markView.alpha = 0.0;
    [scrollPanel addSubview:markView];
    
    myScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [scrollPanel addSubview:myScrollView];
    myScrollView.pagingEnabled = YES;
    myScrollView.delegate = self;
    CGSize contentSize = myScrollView.contentSize;
    contentSize.height = self.view.bounds.size.height;
    contentSize.width = ScreenWidth * self.arrData.count;
    myScrollView.contentSize = contentSize;
    
    myTable = [[UITableView alloc] initWithFrame:tableViewFirstFrame];
    myTable.dataSource = self;
    myTable.backgroundColor = [UIColor redColor];
    myTable.delegate = self;
    myTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    myTable.showsVerticalScrollIndicator = NO;
    myTable.backgroundColor = RGB(245.0, 245.0, 245.0);
    self.view.backgroundColor = RGB(245.0, 245.0, 245.0);
    [self.view addSubview:myTable];
    
    viewStatus = [[UIView alloc] initWithFrame:viewStatusHiddenFrame];
    [self.view insertSubview:viewStatus aboveSubview:myTable];
    
    btnSelectAll = [[UIButton alloc] initWithFrame:CGRectMake(10, 15, 20, 20)];
    [btnSelectAll setBackgroundImage:imgUnSelected forState:UIControlStateNormal];
    [btnSelectAll addTarget:self action:@selector(selectedAll:) forControlEvents:UIControlEventTouchUpInside];
    [viewStatus addSubview:btnSelectAll];
    
    UILabel *lblAll = [[UILabel alloc] initWithFrame:CGRectMake(35, 10, 150, 30)];
    lblAll.text = kString(@"全选");
    lblAll.font = [UIFont systemFontOfSize:16];
    lblAll.textColor = [UIColor darkGrayColor];
    [viewStatus addSubview:lblAll];
    
    UIButton *btnDelete = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 110, 10, 100, 30)];
//    btnDelete.backgroundColor = RGB(1, 186, 19);
    [btnDelete setBackgroundImage:[UIImage imageFromColor:RGB(1, 186, 19)] forState:UIControlStateNormal];
    [btnDelete setBackgroundImage:[UIImage imageFromColor:RGB(1, 154, 19)] forState:UIControlStateHighlighted];
    
    btnDelete.titleLabel.font = [UIFont systemFontOfSize:16];
    btnDelete.tintColor = [UIColor whiteColor];
    [btnDelete setTitle:kString(@"删除") forState:UIControlStateNormal];
    [btnDelete addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
    btnDelete.layer.cornerRadius = 5;
    btnDelete.layer.masksToBounds = YES;
    
    [viewStatus addSubview:btnDelete];
}


#pragma mark -
#pragma mark - custom method
- (void) addSubImgView
{
    for (UIView *tmpView in myScrollView.subviews)
    {
        [tmpView removeFromSuperview];
    }
    
    for (int i = 0; i < self.arrData.count; i ++)
    {
        if (i == currentIndex)
        {
            continue;
        }
        
        TapImageView *tmpView = (TapImageView *)[tapCell viewWithTag:10 + i];
        
        //转换后的rect
        CGRect convertRect = [[tmpView superview] convertRect:tmpView.frame toView:self.view];
        
        ImgScrollView *tmpImgScrollView = [[ImgScrollView alloc] initWithFrame:(CGRect){i*myScrollView.bounds.size.width,0,myScrollView.bounds.size}];
        [tmpImgScrollView setContentWithFrame:convertRect];
        [tmpImgScrollView setImage:tmpView.image];
        [myScrollView addSubview:tmpImgScrollView];
        tmpImgScrollView.i_delegate = self;
        
        [tmpImgScrollView setAnimationRect];
    }
}

- (void) setOriginFrame:(ImgScrollView *) sender
{
    [UIView animateWithDuration:0.4 animations:^{
        [sender setAnimationRect];
        markView.alpha = 1.0;
    }];
}

#pragma mark -
#pragma mark - custom delegate
- (void) tappedWithObject:(id)sender
{
    isShowRightButton = NO;
    [self refreshRightButton];
    [self.view bringSubviewToFront:scrollPanel];
    scrollPanel.alpha = 1.0;
    
    TapImageView *tmpView = sender;
    currentIndex = tmpView.tag - 10;
    
    tapCell = tmpView.identifier;
    
    //转换后的rect
    CGRect convertRect = [[tmpView superview] convertRect:tmpView.frame toView:self.view];
    
    CGPoint contentOffset = myScrollView.contentOffset;
    contentOffset.x = currentIndex * ScreenWidth;// 320;
    myScrollView.contentOffset = contentOffset;
    
    //添加
    [self addSubImgView];
    
    ImgScrollView *tmpImgScrollView = [[ImgScrollView alloc] initWithFrame:(CGRect){contentOffset,myScrollView.bounds.size}];
    [tmpImgScrollView setContentWithFrame:convertRect];
    [tmpImgScrollView setImage:tmpView.image];
    [myScrollView addSubview:tmpImgScrollView];
    tmpImgScrollView.i_delegate = self;
    
    [self performSelector:@selector(setOriginFrame:) withObject:tmpImgScrollView afterDelay:0.1];
}

- (void) tapImageViewTappedWithObject:(id)sender
{
    isShowRightButton = YES;
    [self refreshRightButton];
    ImgScrollView *tmpImgView = sender;
    
    [UIView animateWithDuration:0.5 animations:^{
        markView.alpha = 0;
        [tmpImgView rechangeInitRdct];
    } completion:^(BOOL finished) {
        scrollPanel.alpha = 0;
    }];
    
}


// 改变是否选中的回调
- (void)changeSelect:(id)sender
{
    TapImageView *tmpView = sender;
    NSInteger currentInd = tmpView.tag - 10;
    
    BOOL isOldSelected = tmpView.isSelected;
    if ([arrSelect containsObject:@(currentInd)])
        [arrSelect removeObject:@(currentInd)];
    else
        [arrSelect addObject:@(currentInd)];
    
    
    if (arrSelect.count == self.arrData.count) {
        [btnSelectAll setBackgroundImage:imgSelected forState:UIControlStateNormal];
    }else
    {
        [btnSelectAll setBackgroundImage:imgUnSelected forState:UIControlStateNormal];
    }
    
    if (isOldSelected) {
        [btnSelectAll setBackgroundImage:imgUnSelected forState:UIControlStateNormal];
    }
    [myTable reloadData];
}


#pragma mark -
#pragma mark - scroll delegate
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    currentIndex = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

#pragma mark -
#pragma mark - table delegate
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell = cell == nil ? [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] : cell;
    
    CGFloat width;
    CGFloat height;
    
    width = ( ScreenWidth - 20 ) / 3.0;
    height = width / (ScreenWidth / ScreenHeight);
    for (UIView *vw in cell.contentView.subviews)
        [vw removeFromSuperview];
    
    for (int i = 0; i < self.arrData.count; i ++)
    {
        Album *al = self.arrData[i];
        
        CGFloat x = 5 + (5 + width) * (i % 3);
        CGFloat y = (height + 10) * (i / 3);
        
        TapImageView *tmpView = [[TapImageView alloc] initWithFrame:CGRectMake(x, 10 + y, width, height)];
        tmpView.t_delegate = self;
        tmpView.isInDelete = isInDelete;
        
        tmpView.backgroundColor = [UIColor whiteColor];
        tmpView.image = IMG(al.imgName);
        tmpView.tag = 10 + i;
        
        BOOL isSelect = [arrSelect containsObject:@(i)];
        [tmpView refreshSelf:isSelect];
        [cell.contentView addSubview:tmpView];
    }
    
    
    for (int i = 0; i < self.arrData.count; i++)
    {
        TapImageView *tmpView1 = (TapImageView *)[cell.contentView viewWithTag:(10 + i)];
        tmpView1.isInDelete = isInDelete;
        tmpView1.t_delegate = self;
        BOOL isSelect = [arrSelect containsObject:@(i)];
        [tmpView1 refreshSelf:isSelect];
        tmpView1.identifier = cell;
    }
    
    
    
    cell.contentView.backgroundColor = RGB(245.0, 245.0, 245.0);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = ( ScreenWidth - 20 ) / 3.0;
    CGFloat height = width / (ScreenWidth / ScreenHeight);
    
    CGFloat allHeight = ceil((double)self.arrData.count / 3.0) * (height + 10) + 10;
    return allHeight;
}

- (void)changeShowStatusView
{
    if (isInDelete)
    {
        [UIView transitionWithView:myTable duration:ANIMATIONTIME options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [myTable setFrame:tableViewSecondtFrame];
        } completion:^(BOOL finished) {}];
        [UIView transitionWithView:viewStatus duration:ANIMATIONTIME options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [viewStatus setFrame:viewStatusShowFrame];
        } completion:^(BOOL finished) {}];
    }
    else
    {
        [UIView transitionWithView:myTable duration:ANIMATIONTIME options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [myTable setFrame:tableViewFirstFrame];
        } completion:^(BOOL finished) {}];
        [UIView transitionWithView:viewStatus duration:ANIMATIONTIME options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [viewStatus setFrame:viewStatusHiddenFrame];
        } completion:^(BOOL finished) {}];
    }
}

//  全选
-(void)selectedAll:(UIButton *)btn
{
    if (arrSelect.count < self.arrData.count)
    {
        NSLog(@"全选中");
        [btn setBackgroundImage:imgSelected forState:UIControlStateNormal];
        [arrSelect removeAllObjects];
        for (int i = 0; i < self.arrData.count; i++)
            [arrSelect addObject:@(i)];
    }else
    {
        NSLog(@"全取消");
        [btn setBackgroundImage:imgUnSelected forState:UIControlStateNormal];
        [arrSelect removeAllObjects];
    }
    [myTable reloadData];
}


-(void)deleteImage:(UIButton *)btn
{
    NSLog(@"%@", arrSelect);
    if (arrSelect.count == 0) {
        return;
    }
    TAlertView *alert = [[TAlertView alloc] initWithTitle:@"提示" message:@"删除选中的图片？"];
    [alert showWithActionSure:^
     {
         for (NSNumber *num in arrSelect)
         {
             Album *ab = self.arrData[[num integerValue]];
             [Album MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"imgID == %@", ab.imgID] inContext:DBefaultContext];
         }
         DBSave;
         [self initData];
         [myTable reloadData];
         [self changeShowStatusView];
     } cancel:^{
     }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}





@end
