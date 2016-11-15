//
//  TapImageView.m
//  TestLayerImage
//
//  Created by lcc on 14-8-1.
//  Copyright (c) 2014年 lcc. All rights reserved.
//

#import "TapImageView.h"

@interface TapImageView()
{
    UITapGestureRecognizer *tap;
}

@end

@implementation TapImageView

- (void)dealloc
{
    _t_delegate = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //[self refreshSelf];
    }
    return self;
}

- (void) Tapped:(UIGestureRecognizer *) gesture
{
//    NSLog(@"-----Tapped");
    if ([self.t_delegate respondsToSelector:@selector(tappedWithObject:)])
        [self.t_delegate tappedWithObject:self];
}

- (void)changeDelete:(UIButton *)btn
{
//    NSLog(@"-----changeDelete");
    if ([self.t_delegate respondsToSelector:@selector(changeSelect:)])
        [self.self.t_delegate changeSelect:self];
}


-(void)refreshSelf:(BOOL)isSelect
{
//    NSLog(@"----- > refreshSelf");
    for (int i = 0; i < self.subviews.count; i++)
    {
        UIView *vw  = self.subviews[i];
        [vw removeFromSuperview];
    }
    
    if (self.isInDelete)
    {
        UIButton *btnMask = [[UIButton alloc] initWithFrame:self.bounds];
        [btnMask addTarget:self action:@selector(changeDelete:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:btnMask];
        
        UIImageView *imvSelect = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width -  20, 0, 20, 20)];
        self.isSelected = isSelect;
        imvSelect.image = isSelect ? [UIImage imageNamed:@"select_bar_press"] : [UIImage imageNamed:@"select_bar_normal"];
        [self addSubview:imvSelect];
        if (tap)
            [self removeGestureRecognizer:tap];
    }
    else
    {
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Tapped:)];
        [self addGestureRecognizer:tap];
        self.isSelected = NO;
        for (UIView *vw in self.subviews) {
            [vw removeFromSuperview];
        }
    }
    
    self.clipsToBounds = YES;
    self.contentMode = UIViewContentModeScaleAspectFill;
    self.userInteractionEnabled = YES;
}




@end
