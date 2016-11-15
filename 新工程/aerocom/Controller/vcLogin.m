//
//  vcLogin.m
//  aerocom
//
//  Created by 丁付德 on 15/6/30.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcLogin.h"
#import "HTAutocompleteManager.h"
#import "BLEManager+Helper.h"

#define LightWhite  RGBA(255, 255, 255, 0.3)

#define  loginInterfaceIndex  3232
#define  getUserInfoInfaceIndex 32121


@interface vcLogin()<UITextFieldDelegate>
{
    NSString *acc;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scvMain;
@property (weak, nonatomic) IBOutlet UIView *vcMain;
@property (unsafe_unretained, nonatomic) IBOutlet HTAutocompleteTextField *txfAccount;
@property (weak, nonatomic) IBOutlet UITextField *txfPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIImageView *imgBeiJing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgHeight;
@property (weak, nonatomic) IBOutlet UILabel *lblLogin;


- (IBAction)btnClick:(UIButton *)sender;
- (IBAction)btnBeijingClick:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *lblAccount;
@property (weak, nonatomic) IBOutlet UILabel *lblPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnBackPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnRegister;

@property (weak, nonatomic) IBOutlet UIView *lineX;
@property (weak, nonatomic) IBOutlet UIView *lineX2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineXHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineX2Height;
@property (weak, nonatomic) IBOutlet UIImageView *imv;


@end

@implementation vcLogin

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self setBar];
    
    [self initView];
    [self resign];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

//-(BOOL)prefersStatusBarHidden
//{
//    return YES;
//}




-(void)dealloc
{
    NSLog(@"vcLogin 释放");
}

- (IBAction)btnClick:(UIButton *)sender
{
    [self resign];
    switch (sender.tag)
    {
        case 1:
        {
            NSLog(@"login");
            if (!self.txfAccount.text.length || !self.txfPassword.text.length) {
                LMBShow(@"用户名和密码不能为空");return;
            }
            [self resign];
            if (self.txfAccount.text.length > 0 && self.txfPassword.text.length > 0)
            {
                MBShowAll;
                __block vcLogin *blockSelf = self;
                HDDAF;
                RequestCheckAfter(
                  [net login:blockSelf.txfAccount.text password:blockSelf.txfPassword.text];,
                  [blockSelf dataSuccessBack_login:dic];)
            }
        }
            break;
        case 2:
            [self performSegueWithIdentifier:@"login_to_backPassword" sender:nil];
            break;
        case 3:
            [self performSegueWithIdentifier:@"login_to_register" sender:nil];
            break;
            
        default:
            break;
    }
}

- (IBAction)btnBeijingClick:(id)sender
{
    [self resign];
}

-(void)initView
{
    self.containHeight.constant = ScreenHeight;
    self.imgHeight.constant = RealHeight(620);
    
    self.btnHeight.constant = RealHeight(150);
    self.btnLogin.layer.cornerRadius = 15;
    self.lineXHeight.constant =self.lineX2Height.constant = 2;
    
    self.txfAccount.placeholder = kString(@"用户名");
    self.txfPassword.placeholder =  kString(@"密码");
    [self.btnBackPassword setTitle:kString(@"找回密码") forState:UIControlStateNormal];
    [self.btnRegister setTitle:kString(@"注册") forState:UIControlStateNormal];
    
    [HTAutocompleteTextField setDefaultAutocompleteDataSource:[HTAutocompleteManager sharedManager]];
    self.txfAccount.autocompleteType = HTAutocompleteTypeEmail;
    self.txfAccount.keyboardType = UIKeyboardTypeEmailAddress;
    self.txfAccount.returnKeyType = UIReturnKeyNext;
    
    self.lblLogin.text = kString(@"登录");
    [self.btnLogin setBackgroundImage:[UIImage imageFromColor:DRed] forState:UIControlStateNormal];
    [self.btnLogin setBackgroundImage:[UIImage imageFromColor:RGB(192, 25, 42)] forState:UIControlStateHighlighted];
    self.btnLogin.layer.cornerRadius = 10;
    self.btnLogin.layer.masksToBounds = YES;
    
    
#if defined(DEBUG)
    self.txfAccount.text = @"402578703@qq.com";
    self.txfPassword.text = @"123456";
#endif
    
    self.txfAccount.delegate = self;
    self.txfPassword.delegate = self;
    self.txfPassword.returnKeyType = UIReturnKeyGo;
    
    self.txfAccount.clearButtonMode = self.txfPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
}


-(void)resign
{
    [self.txfAccount resignFirstResponder];
    [self.txfPassword resignFirstResponder];
    [self viewMove:NO];
    self.lineX.backgroundColor = self.lineX2.backgroundColor = LightWhite;
}

-(void)dataSuccessBack_login:(NSDictionary *)dic
{
    NSInteger statue = [dic[@"status"] integerValue];
    switch (statue) {
        case 1:
            MBHide;
            LMBShow(@"账号不存在");
            break;
        case 2:
            MBHide;
            LMBShow(@"密码不正确");
            break;
        case 0:
        {
            SetUserDefault(userInfoAccess, dic[@"access"]);  // 保存在本地
            if (GetUserDefault(userInfoEmail)) {
                NSMutableDictionary *dict = [GetUserDefault(userInfoEmail) mutableCopy];
                [dict setObject:self.txfAccount.text forKey:dic[@"access"]];
                SetUserDefault(userInfoEmail, dict);
            }else
            {
                NSMutableDictionary *dict = [NSMutableDictionary new];
                [dict setObject:self.txfAccount.text forKey:dic[@"access"]];
                SetUserDefault(userInfoEmail, dict);
            }
            self.userInfo = myUserInfo;
            
            NSString * access = dic[@"access"];
            acc = access;
            __block vcLogin *blockSelf = self;
            RequestCheckBefore(
               [net getUserInfo:access];,
               [blockSelf dataSuccessBack_getUserInfo:dic];,
               MBHide;)
        }
            break;
        default:
            break;
    }
}

-(void)dataSuccessBack_getUserInfo:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        self.userInfo = [[UserInfo findByAttribute:@"access" withValue:acc] firstObject];
        self.userInfo.email = self.txfAccount.text;
        self.userInfo.user_pic_url = [dic[@"user_pic_url"] description].length == 0 ? @"touxiang" : [dic[@"user_pic_url"] description];
        self.userInfo.user_nick_name = dic[@"user_nick_name"];
        self.userInfo.user_country_code = @(([dic[@"user_country_code"] isEqualToString:@""] ? 0 : [(NSString *)dic[@"user_country_code"] integerValue]));
        self.userInfo.user_state_code = @(([dic[@"user_state_code"] isEqualToString:@""] ? 0 : [(NSString *)dic[@"user_state_code"] integerValue]));
        self.userInfo.user_city_code = @(([dic[@"user_city_code"] isEqualToString:@""] ? 0 : [(NSString *)dic[@"user_city_code"] integerValue]));
        self.userInfo.user_gender = @([(NSString *)dic[@"user_gender"] intValue]);
        self.userInfo.user_weight = @([(NSString *)dic[@"user_weight"] doubleValue]);
        self.userInfo.user_height = @([(NSString *)dic[@"user_height"] doubleValue]);
        self.userInfo.user_birthday = [dic[@"user_birthday"] toDate:dic[@"user_birthday"]];
        self.userInfo.update_time = @((long)dic[@"update_time"]);
        self.userInfo.isUpate = @(YES);
        DBSave;
        
        SetUserDefault(DSys, @YES);
        
        if (![[SyncDate numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"access == %@", self.userInfo.access] inContext:DBefaultContext] integerValue]) {     //  || 1
            __block vcLogin *blockSelf = self;
            RequestCheckNoWaring(
                 [net getMyPlantData:blockSelf.userInfo.access  my_plant_id:nil k_date_from:0 k_date_to:10000];,
                 [blockSelf dataSuccessBack_getMyPlantData:dic];);
        }
        else
        {
            MBHide;
            __block vcLogin *blockSelf = self;
            NextWait([blockSelf gotoMainStoryBoard];, 1);
        }
    }
    else
    {
        NSLog(@"没有信息");
        MBHide;
    }
}

-(void)dataSuccessBack_getMyPlantData:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        NSArray *arr = dic[@"my_plant_data"];
        if (arr.count)
        {
            self.Bluetooth = [BLEManager sharedManager];
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                for (int i = 0; i < arr.count; i++)
                {
                    NSDictionary *d = arr[i];
                    NSDate *date = [self getDateFromInt:[self HmF2KIntToDate:[d[@"k_date"] integerValue]]];
                    NSLog(@"date:%@", date);
                    
                    SyncDate *syn = [SyncDate findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and my_plant_id == %@ and sub = 5 and dateValue == %@", self.userInfo.access, d[@"my_plant_id"], d[@"k_date"]] inContext:localContext];
                    if (!syn && [d[@"my_plant_id"] intValue])
                    {
                        syn = [SyncDate MR_createEntityInContext:localContext];
                        syn.my_plant_id = @([d[@"my_plant_id"] integerValue]);
                        syn.dateValue = @([d[@"k_date"] integerValue]);
                        syn.mean_light = @([d[@"my_plant_light"] integerValue]);
                        syn.mean_solimois = @([d[@"my_plant_humidity"] integerValue]);
                        syn.mean_ambienttem = @([d[@"my_plant_temperature_c"] integerValue]);
                        syn.count = @([d[@"counts"] integerValue]);
                        syn.light = d[@"light_array"];
                        syn.ambient_temperature = d[@"temperature_c_array"];
                        syn.soil_moisture = d[@"humidity_array"];
                        syn.year = @([date getFromDate:1]);
                        syn.month =  @([date getFromDate:2]);
                        syn.day = @([date getFromDate:3]);
                        syn.sub = @5;
                        syn.isUpload = @YES;
                        syn.score = [self.Bluetooth getScore:syn];
                        syn.access = self.userInfo.access;
                        syn.mean_ambienttem = @([self.Bluetooth intArrayToAVGByStr:[syn.ambient_temperature debugDescription]]);
                        syn.mean_light =  @([self.Bluetooth intArrayToAVGByStr:[syn.light debugDescription]]);
                        syn.mean_solimois =  @([self.Bluetooth intArrayToAVGByStr:[syn.mean_solimois debugDescription]]);
                        
                        
                        if (![syn.mean_ambienttem intValue] || ![syn.mean_light intValue] || ![syn.mean_solimois intValue] || ![syn.my_plant_id intValue]) {
                            [syn MR_deleteEntityInContext:localContext];
                            NSLog(@"删除一个");
                        }
                        else
                        {
                            NSLog(@"添加一个 %@-%@-%@, 光照 ：%@ 温度：%@， 湿度：%@， 平均 %@ %@ %@", syn.year,syn.month, syn.day, syn.light, syn.ambient_temperature, syn.soil_moisture, syn.mean_light, syn.mean_ambienttem, syn.mean_solimois );
                        }
                    }
                }
                DLSave;
                DBSave;
            }];
        }
        __block vcLogin *blockSelf = self;
        NextWait(MBHideInBlock;[blockSelf gotoMainStoryBoard];, 1);
    }
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.lineX.backgroundColor = self.lineX2.backgroundColor = LightWhite;
    if (textField.tag == 1)
        self.lineX.backgroundColor = DWhite;
    else
        self.lineX2.backgroundColor = DWhite;
    
    if (IPhone4) {
        [self viewMove:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:_txfAccount]) {
        [_txfPassword becomeFirstResponder];
    }else if ([textField isEqual:_txfPassword]){
        if (_txfAccount.text.length && _txfPassword.text.length) {
            [self btnClick:_btnLogin];
        }
    }
    return true;
}


-(void)viewMove:(BOOL)isTop
{
    [UIView transitionWithView:self.view duration:0.35 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        if (isTop)
            [self.vcMain setFrame:CGRectMake(0, -NavBarHeight, ScreenWidth, ScreenHeight)];
        else
            [self.vcMain setFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    } completion:^(BOOL finished) {}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}






@end
