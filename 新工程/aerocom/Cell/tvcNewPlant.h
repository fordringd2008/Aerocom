//
//  tvcNewPlant.h
//  aerocom
//
//  Created by 丁付德 on 15/7/9.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "FDLabelView.h"

@protocol tvcNewPlantDelegate <NSObject>

-(void)stcChange:(NSInteger)index tadex:(NSInteger)tadex;

-(void)txfChange:(UITextField *)txf;

-(void)btnReturnClick;

@end

@interface tvcNewPlant : UITableViewCell <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITextField *txfvalue;
@property (weak, nonatomic) IBOutlet UISegmentedControl *stcSwitch;
@property (weak, nonatomic) IBOutlet UILabel *lblValue;
@property (weak, nonatomic) IBOutlet UIImageView *imvRight;
@property (assign, nonatomic) NSInteger tagIndex;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblTilteWidth;



@property (nonatomic, strong) id<tvcNewPlantDelegate> delegate;

- (IBAction)change:(UISegmentedControl *)sender;

- (IBAction)txfDidBeginEditing:(UITextField *)sender;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
