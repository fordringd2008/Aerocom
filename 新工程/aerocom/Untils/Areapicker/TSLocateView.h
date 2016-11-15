//
//  UICityPicker.h
//  DDMates
//
//  Created by ShawnMa on 12/16/11.
//  Copyright (c) 2011 TelenavSoftware, Inc. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import "TSLocation.h"
#import "County.h"
#import "State.h"


@interface TSLocateView : UIActionSheet<UIPickerViewDelegate, UIPickerViewDataSource> {
@private
    NSMutableArray * counties; // provinces;
    NSMutableArray	* states;   // cities;
}

@property (weak, nonatomic) IBOutlet UIPickerView *locatePicker;
@property (strong, nonatomic) TSLocation *locate;

- (id)initWithTitle:(NSString *)title delegate:(id /*<UIActionSheetDelegate>*/)delegate;

- (void)showInView:(UIView *)view;

@end
