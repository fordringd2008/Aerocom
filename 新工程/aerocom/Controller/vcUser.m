//
//  vcUser.m
//  aerocom
//
//  Created by 丁付德 on 15/6/30.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcUser.h"
#import "tvcUser.h"
#import "County.h"
#import "State.h"

@interface vcUser() <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tabview;

@end

@implementation vcUser

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavTitle:self title:@"用户中心"];
    self.isPop = NO;

    [self initLeftButton:@"iosmulu"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initTableView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self readDataFromJSON];
}


-(void)dealloc
{
    NSLog(@"vcUser 释放");
}


-(void)initTableView
{
    //
    self.tabview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStyleGrouped];
    self.tabview.dataSource = self;
    self.tabview.delegate = self;
    self.tabview.scrollEnabled = YES;
    self.tabview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tabview.rowHeight =  55;
    self.tabview.backgroundColor = RGB(234, 234, 234);
    [self.tabview registerNib:[UINib nibWithNibName:@"tvcUser" bundle:nil] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview: self.tabview];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return RealHeight(70.0);
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcUser *cell = [tvcUser cellWithTableView:tableView];
    cell.isShowLine = indexPath.row != 2;
    switch (indexPath.row) {
        case 0:
        {
            cell.lblTitle.text = [NSString stringWithFormat:@"%@:", kString(@"邮箱")];
            cell.lblEmail.text = self.userInfo.email;
            [cell.imvRIght setHidden:YES];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
        case 1:
        {
            cell.lblTitle.text = [NSString stringWithFormat:@"%@:", kString(@"更改个人设置")];
            [cell.lblEmail setHidden:YES];
        }
            break;
        case 2:
        {
            cell.lblTitle.text = [NSString stringWithFormat:@"%@:", kString(@"退出登录")];
            [cell.lblEmail setHidden:YES];
        }
            break;
            
        default:
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.row) {
        case 1:
            NSLog(@"-------1");
            [self performSegueWithIdentifier:@"user_to_userEdit" sender:nil];
            break;
        case 2:
        {
            TAlertView *alert = [[TAlertView alloc] initWithTitle:@"提示" message:@"确定退出？"];
            [alert showWithActionSure:^
            {
                NSLog(kString(@"确定"));
                if (GetUserDefault(userInfoEmail))                      // 注销的时候，  本地一定是存放的有的
                {
                    NSMutableDictionary *dic = [GetUserDefault(userInfoEmail) mutableCopy];
                    NSString *s = GetUserDefault(userInfoAccess);
                    if (s) [dic removeObjectForKey:s];
                    
                    SetUserDefault(userInfoEmail, dic);
                }
                SetUserDefault(userInfoAccess, nil);
                self.userInfo = nil;
                [NSObject returnUserNil];
                
                SetUserDefault(DSys, @NO);
                
                // 断开所有连接
                self.Bluetooth.isFailToConnectAgain = NO;
                SetUserDefault(isNotRealNewBLE, @(NO));
                [self.Bluetooth stopLink:nil];
                [self.navigationController popViewControllerAnimated:NO];
                [self gotoLoginStoryBoard];
            } cancel:^{
            }];
        }
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



- (void)readDataFromJSON
{
    NSInteger langIndex = [self getPreferredLanguage];   // 获取当前语言
    
    NSNumber *language = @1;
    switch (langIndex) {
        case 1:
        {
            language = @1;
        }
            break;
        case 2:
        {
            language = @2;
        }
            break;
        case 3:
        {
            language = @3;
        }
            break;
    }
    
    NSArray *countyFromLocal = [County findByAttribute:@"language" withValue:language];
    
    if (countyFromLocal.count == 0)
    {
        NSLog(@"读取json  并写入本地数据库");
        NSData *data = [self getCountiesAndCitiesrDataFromJSON];
        NSDictionary *dicData = (NSDictionary *)data;
        
        NSArray *arrCounty = dicData[@"Location"][@"CountryRegion"];
        for (int i = 0; i < arrCounty.count; i++)
        {
            County *cou = [County MR_createEntityInContext:DBefaultContext];
            cou.language = language;
            cou.countyID = @(i);
            cou.countyName = arrCounty[i][@"@attributes"][@"Name"];
            cou.writeTime = [NSDate date];
            NSMutableArray *arrSet = [NSMutableArray new];
            
            NSArray *arState = nil;
            arState = arrCounty[i][@"State"];
            if (!arState)
            {
                State *st = [State MR_createEntityInContext:DBefaultContext];
                st.county = cou;
                st.language = language;
                st.stateID =  cou.countyID;
                st.stateName = cou.countyName;
                st.writeTime = [NSDate date];
                [arrSet addObject:st];
            }
            else if (arState.count == 1) {
                arState = arrCounty[i][@"State"][@"City"];
                for (int j = 0; j < arState.count; j++) {
                    State *st = [State MR_createEntityInContext:DBefaultContext];
                    st.county = cou;
                    st.language = language;
                    st.stateID = @(j);
                    st.stateName = arState[j][@"@attributes"][@"Name"];
                    st.writeTime = [NSDate date];
                    [arrSet addObject:st];
                }
            }
            else
            {
                for (int j = 0; j < arState.count; j++) {
                    State *st = [State MR_createEntityInContext:DBefaultContext];
                    st.county = cou;
                    st.language = language;
                    st.stateID = @(j);
                    st.stateName = arState[j][@"@attributes"][@"Name"];
                    st.writeTime = [NSDate date];
                    [arrSet addObject:st];
                }
            }
            
            NSSet *stateSet = [NSSet setWithArray:[arrSet mutableCopy]];
            [cou addStates:stateSet];
        }
        DBSave;
    }
}











@end
