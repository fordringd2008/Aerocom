//
//  StartViewController.m
//  FitTu
//
//  Created by yyh on 14/12/23.
//  Copyright (c) 2014年 yyh. All rights reserved.
//

#import "vcStart.h"
#import "AppDelegate.h"
#import "vcUser.h"
#import "Myanotation.h"

#define  btnHiddenFrame        CGRectMake(ScreenWidth, ScreenHeight * 0.5, ScreenWidth * 0.3, 50)
#define  btnShowFrame          CGRectMake(ScreenWidth * 0.6, ScreenHeight * 0.5, ScreenWidth * 0.3, 50)


@interface vcStart ()<UIScrollViewDelegate>
{
    BOOL isScrollEnd;
    UIButton *btnGo;
    UITapGestureRecognizer *recognizer;
    UISwipeGestureRecognizer *recongizer_left;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
//@property (nonatomic, strong) UIButton *startButton;
@end

@implementation vcStart

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initScrollView];
    [self initPageControl];
}

//添加scrollView
- (void)initScrollView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    self.scrollView.bounces = NO;
    for (int i = 0; i < 3; i ++)
    {
        NSString *imageName;
        imageName = [NSString stringWithFormat:@"00%d引导页",i + 1];
        UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
        imgView.frame = CGRectMake(ScreenWidth * i, 0, ScreenWidth, ScreenHeight);
        [_scrollView addSubview:imgView];
    }
    
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(ScreenWidth * 3, ScreenHeight);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    
    self.scrollView.contentOffset = CGPointMake(0, 0);
    [self.view addSubview:self.scrollView];
}

// 添加pageControl
- (void)initPageControl
{
    self.pageControl = [UIPageControl new];
    self.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    self.pageControl.pageIndicatorTintColor = DWhiteA(0.3);
    self.pageControl.bounds = CGRectMake(0, 0, 90, 20);
    self.pageControl.center = CGPointMake(ScreenWidth / 2, ScreenHeight - 40);
    [self.pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    self.pageControl.numberOfPages = 3;//self.scrollView.contentSize.width/ScreenWidth;
    self.pageControl.currentPage = 0;
    
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.pageControl];
}

#pragma mark -
#pragma mark PageControlDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = scrollView.contentOffset.x / ScreenWidth;
    [self showButton:self.pageControl.currentPage];
}

#pragma mark -
#pragma mark PageControlDelegate

- (void)changePage:(UIPageControl *)aPageControl
{
    [self.scrollView setContentOffset:CGPointMake(aPageControl.currentPage * ScreenWidth, 0) animated:YES];
    [self showButton:aPageControl.currentPage];
}

//显示按钮
- (void)showButton:(NSInteger )index
{
    if (index == 2)
    {
        self.scrollView.scrollEnabled = NO;
        self.pageControl.hidden = YES;
        
        btnGo = [[UIButton alloc] initWithFrame:btnHiddenFrame];
        [btnGo setTitle: kString(@"开始") forState:UIControlStateNormal];
        [btnGo setBackgroundColor:RGBA(255, 255, 255, 0.5)];
        btnGo.layer.cornerRadius = 15;
        [btnGo addTarget:self action:@selector(changeRootViewController) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btnGo];
        
        [UIView transitionWithView:btnGo duration:0.35 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [btnGo setFrame:btnShowFrame];
        } completion:^(BOOL finished){}];
    }
}

// 点击手势
-(void)tapRecognizer:(UIGestureRecognizer *)recognizer
{
    //[self changeRootViewController];
    [UIView transitionWithView:btnGo duration:0.35 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [btnGo setFrame:btnShowFrame];
    } completion:^(BOOL finished){}];
}

- (void)changeRootViewController
{
    [Myanotation resetLatitudeAndLongitude];
    [self.view removeGestureRecognizer:recognizer];
    [self.view removeGestureRecognizer:recongizer_left];
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    UIStoryboard *login = [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]];
    UINavigationController *loginNav = login.instantiateInitialViewController;
    delegate.window.rootViewController = loginNav;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
