//
//  vcLeft.m
//  MasterDemo
//
//  Created by 丁付德 on 15/6/24.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcLeft.h"
#import "tvcLeft.h"

//#define BIGFRAME CGRectMake(0, 110, 220, 280)
//#define SMALLFRAME CGRectMake(-160, self.view.frame.size.height/2, 0, 0)
//#define ANIMATIONTIME 0.35


@interface vcLeft () <UITableViewDelegate, UITableViewDataSource>
{
    CGRect BIGFRAME;
    CGRect SMALLFRAME;
    NSTimeInterval ANIMATIONTIME;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scBig;
@property (weak, nonatomic) IBOutlet UIView *vcMain;
@property (weak, nonatomic) IBOutlet UIImageView *imgLogo;
@property (weak, nonatomic) IBOutlet UILabel *lblemail;
@property (weak, nonatomic) IBOutlet UITableView *tblMain;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scvContentWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewContentHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tbvHeight;


@property (strong, nonatomic) NSArray *arrTblImgData;
@property (strong, nonatomic) NSArray *arrTblNameData;

@end

@implementation vcLeft

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initTable];
    [self initData];
    
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self checkUser];
    
//    [UIView transitionWithView:self.tblMain duration:ANIMATIONTIME options:UIViewAnimationOptionBeginFromCurrentState animations:^{
//        [self.tblMain setFrame:BIGFRAME];
//    } completion:^(BOOL finished) {
//        [self.tblMain reloadData];
//    }];
    [self.view setFrame:CGRectMake(-100, 0, ScreenWidth, ScreenHeight)];
    [UIView transitionWithView:self.view duration:ANIMATIONTIME options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.view setFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    } completion:^(BOOL finished) {}];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [UIView transitionWithView:self.view duration:ANIMATIONTIME options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.view setFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    } completion:^(BOOL finished) {}];
    [super viewWillDisappear:animated];
}


-(void)initView
{
    self.scvContentWidth.constant = 267.0;
    self.viewContentHeight.constant = RealHeight(2208);
    
    self.imgHeight.constant = RealHeight(300.0);
    self.lblHeight.constant = RealHeight(50.0);
    self.tbvHeight.constant = RealHeight(150.0);
    
//    CGFloat totalTop = self.imgHeight.constant + self.lblHeight.constant + self.tbvHeight.constant;
//    
    BIGFRAME = CGRectMake(0, self.tblMain.frame.origin.y, 260, 375);
    SMALLFRAME = CGRectMake(-160, self.tblMain.frame.origin.y, 0, 0);
    ANIMATIONTIME = 0.35;
    
    self.imgLogo.layer.cornerRadius = 96.0 * 0.5;
    self.imgLogo.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.imgLogo.layer.borderWidth = 1;
    [self.imgLogo.layer setMasksToBounds:YES];
    
    self.lblemail.text = myUserInfo.email;
    
    //[self MatchingFont:self.view];
}

-(void)checkUser
{
    self.userInfo = myUserInfo;
    if (self.userInfo)
    {
        if (self.userInfo.imageData) {
            UIImage *img = [UIImage imageWithData:self.userInfo.imageData];
            self.imgLogo.image = img;
        }else
            [self.imgLogo sd_setImageWithURL:[NSURL URLWithString:self.userInfo.user_pic_url] placeholderImage: DefaultLogoImage];
        self.lblemail.text = self.userInfo.email;// self.userInfo.user_nick_name.length ? self.userInfo.user_nick_name :
    }
}


#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.arrTblImgData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcLeft *cell = [tvcLeft cellWithTableView:tableView];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.imgLogo.image = [UIImage imageNamed:self.arrTblImgData[indexPath.row]];
    cell.lblName.text = self.arrTblNameData[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //tvcLeft *currentCell = (tvcLeft *)[tableView cellForRowAtIndexPath:indexPath];
    //currentCell.imgBig.image = [UIImage imageNamed:@"iosbeijing2"];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSInteger row = 0;
    row = indexPath.row;
    delegate.customTb.selectedIndex = row;
    
    [delegate.sideViewController hideSideViewController:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //tvcLeft *currentCell = (tvcLeft *)[tableView cellForRowAtIndexPath:indexPath];
    //currentCell.imgBig.image = nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    CGFloat hei = RealHeight(170.0);
//    return hei;
    return 50;
}


-(void)initTable
{
    self.tblMain.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tblMain.backgroundColor = [UIColor clearColor];
    
//    self.tblMain.separatorStyle = 
}

-(void)initData
{
    self.arrTblImgData = [[NSArray alloc] initWithObjects:@"iosui1", @"iosui2", @"iosui3", @"iosui4", nil];
    self.arrTblNameData = [[NSArray alloc] initWithObjects:kString(@"我的花园"), kString(@"用户"), kString(@"系统设置"), kString(@"使用帮助"), nil];
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
