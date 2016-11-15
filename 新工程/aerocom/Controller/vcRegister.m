//
//  vcRegister.m
//  aerocom
//
//  Created by 丁付德 on 15/6/30.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcRegister.h"
#import "HTAutocompleteManager.h"

#define  registeredInterFaceIndex       2311244
#define  updateUserInfoInterfaceIndex  2532

@interface vcRegister()<UITextFieldDelegate>
{
    NSString *acc;
}
@property (weak, nonatomic) IBOutlet UIView *viewMain;

@property (unsafe_unretained, nonatomic) IBOutlet HTAutocompleteTextField *txfAccount;
@property (weak, nonatomic) IBOutlet UITextField *txfPassword;
@property (weak, nonatomic) IBOutlet UITextField *txfPasswordSecond;


@property (weak, nonatomic) IBOutlet UIButton *btnRegister;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnRegisterHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnCancelHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnRegisterContentHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnCancelContentHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgHeight;
@property (weak, nonatomic) IBOutlet UILabel *lblRegiseter;
@property (weak, nonatomic) IBOutlet UILabel *lblCancel;



- (IBAction)btnClick:(UIButton *)sender;


@property (weak, nonatomic) IBOutlet UILabel *lblAccount;
@property (weak, nonatomic) IBOutlet UILabel *lblPassword;
@property (weak, nonatomic) IBOutlet UILabel *lblConfirmPassword;

@property (weak, nonatomic) IBOutlet UIView *lineX;
@property (weak, nonatomic) IBOutlet UIView *lineX2;
@property (weak, nonatomic) IBOutlet UIView *lineX3;



@end

@implementation vcRegister

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavTitle:self title:@"注册"];
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

-(void)initView
{
    self.containHeight.constant = ScreenHeight;
    self.imgHeight.constant = RealHeight(530.0);
    self.btnRegisterHeight.constant = RealHeight(1183.0);
    self.btnCancelHeight.constant = RealHeight(90.0);
    self.btnRegisterContentHeight.constant = self.btnCancelContentHeight.constant = RealHeight(150.0);
    
    self.btnRegister.layer.cornerRadius = self.btnCancel.layer.cornerRadius = 15;
    self.btnCancel.layer.borderColor = RGBA(255.0, 255.0, 255.0, 0.5).CGColor;
    self.btnCancel.layer.borderWidth = 1;
    
    self.lblAccount.text = kString(@"用户名");
    self.lblPassword.text = kString(@"密码");;
    self.lblConfirmPassword.text = kString(@"确认密码");
//    [self.btnRegister setTitle:kString(@"注册") forState:UIControlStateNormal];
//    [self.btnCancel setTitle:kString(@"取消") forState:UIControlStateNormal];
    
    [HTAutocompleteTextField setDefaultAutocompleteDataSource:[HTAutocompleteManager sharedManager]];
    self.txfAccount.autocompleteType = HTAutocompleteTypeEmail;
    self.txfAccount.keyboardType = UIKeyboardTypeEmailAddress;
    
    self.txfAccount.delegate = self;
    self.txfPassword.delegate = self;
    self.txfPasswordSecond.delegate = self;
    
    self.txfAccount.placeholder = kString(@"用户名");
    self.txfPassword.placeholder =  kString(@"密码");
    self.txfPasswordSecond.placeholder = kString(@"确认密码");
    
    self.lblRegiseter.text = kString(@"注册");
    [self.btnRegister setBackgroundImage:[UIImage imageFromColor:DRed] forState:UIControlStateNormal];
    [self.btnRegister setBackgroundImage:[UIImage imageFromColor:RGB(192, 25, 42)] forState:UIControlStateHighlighted];
    self.btnRegister.layer.cornerRadius = 10;
    self.btnRegister.layer.masksToBounds = YES;
    
    self.lblCancel.text = kString(@"取消");
    [self.btnCancel setBackgroundImage:[UIImage imageFromColor:DClear] forState:UIControlStateNormal];
    [self.btnCancel setBackgroundImage:[UIImage imageFromColor:DWhiteA(0.3)] forState:UIControlStateHighlighted];
    self.btnCancel.layer.cornerRadius = 10;
    self.btnCancel.layer.masksToBounds = YES;
    
    
    self.txfAccount.returnKeyType = self.txfPassword.returnKeyType = UIReturnKeyNext;
    self.txfPasswordSecond.returnKeyType = UIReturnKeyDone;
    self.txfAccount.clearButtonMode = self.txfPassword.clearButtonMode = self.txfPasswordSecond.clearButtonMode = UITextFieldViewModeWhileEditing;
}

- (IBAction)btnClick:(UIButton *)sender
{
    [self resign];
    switch (sender.tag) {
        case 1:
            NSLog(@"注册");
            [self registered];
            break;
        case 2:
            [self back];
            break;
        case 3:
        {
            
        }
            break;
            
        default:
            break;
    }
}

-(void)registered
{
    NSString *strAccount = [self.txfAccount.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *strPD = [self.txfPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *strPDSe = [self.txfPasswordSecond.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    BOOL isEmailOK = [strAccount isEmailType];
    BOOL isPasswordOK = strPDSe.length == 0 || strPD.length == 0;
    BOOL isPasswordSame = [strPD isEqualToString:strPDSe];
    
    if (!isEmailOK) {
        LMBShow(@"邮箱格式不正确");
        return;
    }else if (isPasswordOK) {
        LMBShow(@"密码不能为空");
        return;
    }else if (!isPasswordSame) {
        LMBShow(@"两次输入的不匹配");
        return;
    }
    MBShowAll;
    __block vcRegister *blockSelf = self;
    HDDAF;
    RequestCheckAfter(
      [net registered:strAccount password:strPD];,
      [blockSelf dataSuccessBack_registered:dic];)
}

-(void)dataSuccessBack_registered:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        acc = dic[@"access"];
        SetUserDefault(userInfoAccess, acc);
        
        if (GetUserDefault(userInfoEmail))
        {
            NSMutableDictionary *dicF = [GetUserDefault(userInfoEmail) mutableCopy];
            [dicF setObject:self.txfAccount.text forKey:dic[@"access"]];
            SetUserDefault(userInfoEmail, dicF);
        }else
        {
            NSMutableDictionary *dicF = [NSMutableDictionary new];
            [dicF setObject:self.txfAccount.text forKey:dic[@"access"]];
            SetUserDefault(userInfoEmail, dicF);
        }
        self.userInfo = myUserInfo;
        [self perfectUserInfo];
    }
    else if([dic[@"status"] isEqualToString:@"1"])
    {
        MBHide;
        LMBShow(@"账号已存在");
    }
}

-(void)dataSuccessBack_updateUserInfo:(NSDictionary *)dic
{
    MBHide;
    if (CheckIsOK) {
        LMBShow(@"注册成功");
        __block vcRegister *blockSelf = self;
        NextWait([blockSelf gotoMainStoryBoard];, 1);
    }
}


-(void)perfectUserInfo
{
    NSMutableDictionary *dicUp = [NSMutableDictionary new];
    [dicUp setObject:self.userInfo.access forKey:@"access"];
    [dicUp setObject:[self.userInfo.user_pic_url isEqualToString:@"touxiang"] ? @"": self.userInfo.user_pic_url  forKey:@"user_pic_url"];
    [dicUp setObject:self.userInfo.user_nick_name ? self.userInfo.user_nick_name : @"" forKey:@"user_nick_name"];
    [dicUp setObject:self.userInfo.user_country_code forKey:@"user_country_code"];
    [dicUp setObject:self.userInfo.user_state_code forKey:@"user_state_code"];
    [dicUp setObject:self.userInfo.user_gender forKey:@"user_gender"];
    [dicUp setObject:self.userInfo.user_height forKey:@"user_height"];
    [dicUp setObject:self.userInfo.user_weight forKey:@"user_weight"];
    [dicUp setObject:[self.userInfo.user_birthday toString:@"YYYYMMdd"] forKey:@"user_birthday"];
    
    __block vcRegister *blockSelf = self;
    RequestCheckNoWaring(
     [net updateUserInfo:dicUp];,
     [blockSelf dataSuccessBack_updateUserInfo:dic];)
}

-(void)resign
{
    [self.txfAccount resignFirstResponder];
    [self.txfPassword resignFirstResponder];
    [self.txfPasswordSecond resignFirstResponder];
    [self viewMove:NO];
    self.lineX.backgroundColor = self.lineX2.backgroundColor = self.lineX3.backgroundColor = RGBA(255.0, 255.0, 255.0, 0.3);
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.lineX.backgroundColor = self.lineX2.backgroundColor = self.lineX3.backgroundColor = RGBA(255.0, 255.0, 255.0, 0.3);
    if (textField.tag == 1)
        self.lineX.backgroundColor = RGBA(255.0, 255.0, 255.0, 1);
    else if (textField.tag == 2)
        self.lineX2.backgroundColor = RGBA(255.0, 255.0, 255.0, 1);
    else
        self.lineX3.backgroundColor = RGBA(255.0, 255.0, 255.0, 1);
    
    if (IPhone4) [self viewMove:YES];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:_txfAccount]) {
        [_txfPassword becomeFirstResponder];
    }else if ([textField isEqual:_txfPassword]){
        [_txfPasswordSecond becomeFirstResponder];
    }else if ([textField isEqual:_txfPasswordSecond]){
        [self viewMove:NO];
        [textField resignFirstResponder];
    }
    return true;
}


-(void)viewMove:(BOOL)isTop
{
    [UIView transitionWithView:self.view duration:0.35 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        if (isTop)
            [self.viewMain setFrame:CGRectMake(0, -NavBarHeight, ScreenWidth, ScreenHeight)];
        else
            [self.viewMain setFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    } completion:^(BOOL finished) {}];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}


@end
