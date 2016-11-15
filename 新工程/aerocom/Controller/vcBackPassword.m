//
//  vcBackPassword.m
//  aerocom
//
//  Created by 丁付德 on 15/6/30.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcBackPassword.h"
#import "HTAutocompleteManager.h"

#define  findPasswordInterFaceIndex    322312

@interface vcBackPassword()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *viewMain;

@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (unsafe_unretained, nonatomic) IBOutlet HTAutocompleteTextField *txfEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnPass;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnPassHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMainContentHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnPassContentHeight;
@property (weak, nonatomic) IBOutlet UILabel *lblPass;
@property (weak, nonatomic) IBOutlet UILabel *lblCancel;



- (IBAction)btnClick:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *lineX;

@end


@implementation vcBackPassword

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationItem.title = @"";我的花园
    [self setNavTitle:self title:@"找回密码"];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self setBar];
    [self initView];
    [self resign];
}

-(void)initView
{
    self.viewMainContentHeight.constant = ScreenHeight;
    self.imgHeight.constant = RealHeight(620.0);
    self.btnPassHeight.constant = RealHeight(1183.0);
    self.btnPassContentHeight.constant = RealHeight(150.0);
    self.btnPass.layer.cornerRadius = self.btnCancel.layer.cornerRadius = 15;
    self.btnCancel.layer.borderColor = RGBA(255.0, 255.0, 255.0, 0.5).CGColor;
    self.btnCancel.layer.borderWidth = 1;
    self.lblEmail.text = kString(@"邮箱");
//    [self.btnPass setTitle:kString(@"发送") forState:UIControlStateNormal];
//    [self.btnCancel setTitle:kString(@"取消") forState:UIControlStateNormal];
    
    [HTAutocompleteTextField setDefaultAutocompleteDataSource:[HTAutocompleteManager sharedManager]];
    self.txfEmail.autocompleteType = HTAutocompleteTypeEmail;
    self.txfEmail.keyboardType = UIKeyboardTypeEmailAddress;
    self.txfEmail.delegate =self;
    self.txfEmail.placeholder = kString(@"邮箱");
    
    self.lblPass.text = kString(@"发送");
    [self.btnPass setBackgroundImage:[UIImage imageFromColor:DRed] forState:UIControlStateNormal];
    [self.btnPass setBackgroundImage:[UIImage imageFromColor:RGB(192, 25, 42)] forState:UIControlStateHighlighted];
    self.btnPass.layer.cornerRadius = 10;
    self.btnPass.layer.masksToBounds = YES;
    
    self.lblCancel.text = kString(@"取消");
    [self.btnCancel setBackgroundImage:[UIImage imageFromColor:DClear] forState:UIControlStateNormal];
    [self.btnCancel setBackgroundImage:[UIImage imageFromColor:DWhiteA(0.3)] forState:UIControlStateHighlighted];
    self.btnCancel.layer.cornerRadius = 10;
    self.btnCancel.layer.masksToBounds = YES;
    
    self.txfEmail.returnKeyType = UIReturnKeyDone;
    self.txfEmail.clearButtonMode = UITextFieldViewModeWhileEditing;
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

- (IBAction)btnClick:(UIButton *)sender
{
    [self resign];
    switch (sender.tag) {
        case 1:
        {
            if ([self.txfEmail.text isEmailType]) {
                __block vcBackPassword *blockSelf = self;
                RequestCheckAfter(
                                  [net findPassword:blockSelf.txfEmail.text];,
                                  [blockSelf dataSuccessBack_getNewestPlantJSONData:dic];)
            }
            else LMBShow(@"邮箱格式不正确");
        }
            break;
        case 2:
            [self back];
            break;
        case 3:
            
            break;
            
        default:
            break;
    }
}

-(void)resign
{
    [self.txfEmail resignFirstResponder];
    [self viewMove:NO];
    self.lineX.backgroundColor = RGBA(255.0, 255.0, 255.0, 0.3);
    
}


-(void)dataSuccessBack_findPassword:(NSDictionary *)dic
{
    if (CheckIsOK)
        LMBShow(@"发送成功");
    else if([dic[@"status"] isEqualToString:@"1"])
        LMBShow(@"账号不存在");
    else
        return;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.lineX.backgroundColor = RGBA(255.0, 255.0, 255.0, 1);
    if (IPhone4) [self viewMove:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:_txfEmail]) {
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
