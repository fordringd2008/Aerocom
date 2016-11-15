//
//  UICityPicker.m
//  DDMates
//
//  Created by ShawnMa on 12/16/11.
//  Copyright (c) 2011 TelenavSoftware, Inc. All rights reserved.
//

#import "TSLocateView.h"



#define kDuration 0.3

@implementation TSLocateView

@synthesize locatePicker;
@synthesize locate;

- (id)initWithTitle:(NSString *)title delegate:(id /*<UIActionSheetDelegate>*/)delegate
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"TSLocateView" owner:self options:nil] objectAtIndex:0];
    if (self)
    {
        self.delegate = delegate;
        self.locatePicker.dataSource = self;
        self.locatePicker.delegate = self;
        
        counties = [NSMutableArray new];
        
        NSLog(@"读取本地数据库");
        counties = [[County findAllSortedBy:@"countyID" ascending:YES inContext:DBefaultContext] mutableCopy];
        
        NSSet *nsState = ((County *)counties[0]).states;
        states = [self setNSDestByOrder:nsState orderStr:@"stateID" ascending:YES];
        
        //初始化默认数据
        self.locate = [[TSLocation alloc] init];
        self.locate.county_S = counties[0];
        self.locate.state_S = states[0];
        
        [self.delegate actionSheet:self clickedButtonAtIndex:0];
    }
    return self;
}

- (void)showInView:(UIView *) view
{
    self.frame = CGRectMake(0, ScreenHeight-256, ScreenWidth, 256);
    [view addSubview:self];
}

#pragma mark - PickerView lifecycle

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [counties count];
            break;
        case 1:
            return [states count];
            break;
        default:
            return 0;
            break;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return ((County *)counties[row]).countyName;
            break;
        case 1:
            return ((State *)states[row]).stateName;
            break;
        default:
            return nil;
            break;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (component) {
        case 0:
        {
            NSSet *setStates = ((County *)counties[row]).states;
            
            states = [setStates setNSDestByOrder:setStates orderStr:@"stateID" ascending:YES];
            
            [self.locatePicker selectRow:0 inComponent:1 animated:NO];
            [self.locatePicker reloadComponent:1];
            
            self.locate.county_S = counties[row];
            self.locate.state_S = states[0];
            [self.delegate actionSheet:self clickedButtonAtIndex:0];
        }
            break;
        case 1:
        {
            self.locate.state_S = states[row];
            [self.delegate actionSheet:self clickedButtonAtIndex:1];
        }
                    break;
        default:
            break;
    }
}


#pragma mark - Button lifecycle
- (IBAction)cancel:(id)sender {
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = kDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    [self setAlpha:0.0f];
    [self.layer addAnimation:animation forKey:@"TSLocateView"];
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:kDuration];
    if(self.delegate) {
        [self.delegate actionSheet:self clickedButtonAtIndex:0];
    }
}

- (IBAction)locate:(id)sender {
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = kDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    [self setAlpha:0.0f];
    [self.layer addAnimation:animation forKey:@"TSLocateView"];
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:kDuration];
    if(self.delegate) {
        [self.delegate actionSheet:self clickedButtonAtIndex:1];
    }
}
@end
