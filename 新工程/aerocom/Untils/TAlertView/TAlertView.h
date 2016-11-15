//
//  TAlertView.h
//  Taxation
//
//  Created by Seven on 15-1-13.
//  Copyright (c) 2015年 Allgateways. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ALERT_TIP,
    ALERT_ACTION,
    ALERT_TIP_ACTION,
    ALERT_DATEPICKER,
    ALERT_TXF
} ALERT_TYPE;

typedef void(^action)(void);
typedef void(^actionWithParam)(id date);

typedef NSInteger(^actionReturn) (NSInteger a);

@interface TAlertView : UIView

- (id)initWithTitle:(NSString *)title message:(NSString *)msg;
- (void)showWithActionSure:(action)sure cancel:(action)cancel;
- (void)showTips;
- (void)showActionCamera:(action)camera photoA:(action)picker;
- (void)showActionDate:(actionWithParam)dateselected;
- (void)close;

- (id)initWithTitle:(NSString *)title message:(NSString *)msg cancelStr:(NSString *)cancelStr sureStr:(NSString *)surStr;

- (void)showWithTXFActionSure:(action)sure cancel:(action)cancel day:(NSString *)day;

@property (nonatomic, copy) NSString *cancelStr;
@property (nonatomic, copy) NSString *surStr;
@end

//@interface TAlertAction : NSObject
//
//@property (strong, nonatomic) NSString *title;
//@property (strong, nonatomic) void (^action)();
//
//+ (instancetype)actionWithTitle:(NSString *)title action:(void(^)())action;
//
//@end

