//
//  GUAAlertView.m
//  GUAAlertView
//
//  Created by gua on 11/11/14.
//  Copyright (c) 2014 GUA. All rights reserved.
//

#import "GUAAlertView.h"

//#define Border(_label, _color)              _label.layer.borderWidth = 1; _label.layer.borderColor = _color.CGColor;



static const float finalAngle = 0;                      // 入场旋转角度
//static const BOOL isDissByTran = NO;                    // 出场是否实时改变旋转角度
static const CGFloat inTime = 1.5;                      // 入场动画时间
static const CGFloat outTime = 1.5;                     // 出场动画时间

static const float backgroundViewAlpha = 0.85;
//static const float alertViewCornerRadius = 8;


@interface GUAAlertView ()


// backgroundView, alertView
@property (nonatomic) UIView *backgroundView;
@property (nonatomic) UIView *alertView;
@property (nonatomic) UIView *contentView;

// titleLabel, messageLable, button
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *messageLabel;
@property (nonatomic) UIButton *button;

// autolayout constraint for alertview centerY
@property (nonatomic) NSLayoutConstraint *alertConstraintCenterY;

// title, message, button text
@property (nonatomic) NSString *titleText;
@property (nonatomic) NSString *messageText;
@property (nonatomic) NSString *buttonTitleText;

// blocks
@property (nonatomic, copy) GUAAlertViewBlock buttonBlock;
@property (nonatomic, copy) GUAAlertViewBlock dismissBlock;

@property (nonatomic) float rorateDirection;


@end


@implementation GUAAlertView

#pragma mark - init

+ (instancetype)alertViewWithTitle:(NSString *)title
                           message:(NSString *)message
                       buttonTitle:(NSString *)buttonTitle
               buttonTouchedAction:(GUAAlertViewBlock)buttonAction
                     dismissAction:(GUAAlertViewBlock)dismissAction {
    return [[GUAAlertView alloc] initWithTitle:title message:message buttonTitle:buttonTitle buttonTouchedAction:buttonAction dismissAction:dismissAction];
}

+ (instancetype)alertViewWithContentView:(UIView *)contentView
               buttonTouchedAction:(GUAAlertViewBlock)buttonBlock
                     dismissAction:(GUAAlertViewBlock)dismissBlock
{
    return [[GUAAlertView alloc] initWithContentView:contentView buttonTouchedAction:buttonBlock dismissAction:dismissBlock];
}

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                  buttonTitle:(NSString *)buttonTitle
          buttonTouchedAction:(GUAAlertViewBlock)buttonAction
                dismissAction:(GUAAlertViewBlock)dismissAction {
    self = [super init];
    if (self) {
        _buttonTitleText = buttonTitle;
        _messageText = message;
        _titleText = title;

        _buttonBlock = buttonAction;
        _dismissBlock = dismissAction;

        [self setup];
    }
    return self;
}

- (instancetype)initWithContentView:(UIView *)contentView
          buttonTouchedAction:(GUAAlertViewBlock)buttonAction
                dismissAction:(GUAAlertViewBlock)dismissAction {
    self = [super init];
    if (self) {
        _contentView = contentView;
        _buttonBlock = buttonAction;
        _dismissBlock = dismissAction;
        
        [self setup];
    }
    return self;
}

#pragma mark - setups

- (void)setup {
    [self setupBackground];

    [self setupAlertView];

    [self setupTitleLabel];

    [self setupContent];

    

    
    [self setupButton];
    

    
    // setup KVO
//    [self setupKVO];

    // setup layout constraints
    [self setupLayoutConstraints];
    
    if (_contentView)
    {
        [_alertView addSubview:_contentView];
        _alertView.backgroundColor = [UIColor clearColor];
        
//        Border(_alertView, [UIColor redColor]);
//        
//        Border(_contentView, [UIColor blueColor]);
        
        // 270
        UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(IPhone4 ? 220 : 240, 0, 30, 30)];
//        btnCancel.backgroundColor = [UIColor blackColor];
        [btnCancel setBackgroundImage:[UIImage imageNamed:@"error1"] forState:UIControlStateNormal];
        [_alertView addSubview:btnCancel];
        
        [btnCancel addTarget:self
                    action:@selector(buttonAction:)
          forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)setupLayoutConstraints {
    // metrics and views
    NSDictionary *metrics = @{@"padding": @20,
                              @"buttonHeight": @44,
                              };
    NSDictionary *views = @{@"title": _titleLabel,
                            @"content": _messageLabel,
                            @"button": _button,
                            };

    // vertical layout
    [_alertView addConstraints:[NSLayoutConstraint
                                constraintsWithVisualFormat:
                                @"V:|-padding-[title]-[content]-padding-[button(==buttonHeight)]|"
                                options:0
                                metrics:metrics
                                views:views]];

    // horizontal layout
    [_alertView addConstraints:[NSLayoutConstraint
                                constraintsWithVisualFormat:@"H:|-[title]-|"
                                options:0
                                metrics:metrics
                                views:views]];
    [_alertView addConstraints:[NSLayoutConstraint
                                constraintsWithVisualFormat:@"H:|-[content]-|"
                                options:0
                                metrics:metrics
                                views:views]];
    [_alertView addConstraints:[NSLayoutConstraint
                                constraintsWithVisualFormat:@"H:|[button]|"
                                options:0
                                metrics:metrics
                                views:views]];
}

- (void)setupBackground {
    UIView *v = [UIView new];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.backgroundColor = [UIColor blackColor];
    v.alpha = 0.85;
    [self addSubview:v];
    [self addSizeFitConstraint:v toView:self widthConstant:0 heightConstant:0];
    _backgroundView = v;
}


- (void)setupAlertView {
    // init
    _alertView = [UIView new];
    _alertView.translatesAutoresizingMaskIntoConstraints = NO;
    _alertView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_alertView];

    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    panGesture.minimumNumberOfTouches = 1;
    panGesture.maximumNumberOfTouches = 1;
    [_alertView addGestureRecognizer:panGesture];

    // autolayout constraint
    NSLayoutConstraint *constraintCenterX =
    [NSLayoutConstraint constraintWithItem:_alertView
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1
                                  constant:0];

    NSLayoutConstraint *constraintCenterY =
    [NSLayoutConstraint constraintWithItem:_alertView
                                 attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeCenterY
                                multiplier:1
                                  constant:0];
    self.alertConstraintCenterY = constraintCenterY;

    NSLayoutConstraint *constraintWidth =
    [NSLayoutConstraint constraintWithItem:_alertView
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1
                                  constant: (IPhone4 ?  250 :  270)];
    
    NSLayoutConstraint *constraintHeightMin =
    [NSLayoutConstraint constraintWithItem:_alertView
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationGreaterThanOrEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1
                                  constant:(IPhone4 ?  335 + 40:  394)];

    NSLayoutConstraint *constraintHeightMax =
    [NSLayoutConstraint constraintWithItem:_alertView
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationLessThanOrEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeHeight
                                multiplier:1
                                  constant:-50];
    [self addConstraints:@[constraintCenterX, constraintCenterY, constraintWidth, constraintHeightMin, constraintHeightMax]];
}

- (void)setupTitleLabel {
    UILabel *label = [self labelWithText:_titleText];
    label.font = [UIFont boldSystemFontOfSize:17];
    [_alertView addSubview:label];
    _titleLabel = label;
}

- (void)setupContent {
    UILabel *label = [self labelWithText:_messageText];
    label.font = [UIFont systemFontOfSize:14];
    [_alertView addSubview:label];
    _messageLabel = label;
}

- (void)setupButton {
    // init
    
    _button = [UIButton buttonWithType:UIButtonTypeSystem];
    _button.translatesAutoresizingMaskIntoConstraints = NO;

    // gray seperator
    _button.backgroundColor = [UIColor whiteColor];
    _button.layer.shadowColor = [[UIColor grayColor] CGColor];
    _button.layer.shadowRadius = 0.5;
    _button.layer.shadowOpacity = 1;
    _button.layer.shadowOffset = CGSizeZero;
    _button.layer.masksToBounds = NO;

    // background color
    [_button setBackgroundImage:imageFromColor([UIColor grayColor])
                       forState:UIControlStateHighlighted];
    [_button setBackgroundImage:imageFromColor([UIColor whiteColor])
                       forState:UIControlStateNormal];

    // title
    [_button setTitle:_buttonTitleText forState:UIControlStateNormal];
    [_button setTitle:_buttonTitleText forState:UIControlStateSelected];
    _button.titleLabel.font = [UIFont boldSystemFontOfSize:_button.titleLabel.font.pointSize];

    // action
    [_button addTarget:self
                action:@selector(buttonAction:)
      forControlEvents:UIControlEventTouchUpInside];

    if (_contentView) {
        _button.hidden = YES;
    }
    [_alertView addSubview:_button];
}

#pragma mark - gesture recognizer

- (void)pan:(UIPanGestureRecognizer *)recognizer {
    UIView *v = recognizer.view;
    CGPoint translation = [recognizer translationInView:v];
    [recognizer setTranslation:CGPointZero inView:v];

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint position =  [recognizer locationInView:v];
        self.rorateDirection = position.x > CGRectGetMidX(v.bounds) ? 1 : -1;
    } else if(recognizer.state == UIGestureRecognizerStateChanged) {
        // update alertview constraint
        self.alertConstraintCenterY.constant += translation.y;

        // rotate
        float halfScreenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
        float ratio = self.alertConstraintCenterY.constant / halfScreenHeight;
        // change background alpha when slide down
        if (ratio > 0) {
            _backgroundView.alpha = backgroundViewAlpha - ratio * backgroundViewAlpha;
        }

        CGFloat finalDegree = 45;
        CGFloat radian = finalDegree * (M_PI / 180) * ratio * self.rorateDirection;
        radian = 0;                                                 // 消失的时候 不使用角度小时
        v.transform = CGAffineTransformMakeRotation(radian);
        
    } else {
        [self panEnd];
    }
}

- (void)panEnd {
    if (fabs(self.alertView.center.y - self.bounds.size.height) < (self.bounds.size.height / 4)) {
        [self dismiss];
    } else {
        [self resetAlertViewPosition];
    }
}

#pragma mark - show and dismiss

- (void)show {
    UIWindow *w = [[UIApplication sharedApplication] keyWindow];
    UIView *topView = w.subviews[0];

    // NOTE, hack for iOS7.
    // only keyWindow.subviews[0] get rotation event in iOS7
    [topView addSubview:self];

    self.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSizeFitConstraint:self toView:topView widthConstant:0 heightConstant:0];

    [self showAlertView];
}

- (void)showAlertView {
    // init state
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat y = -(CGRectGetHeight(screenBounds) + CGRectGetHeight(_alertView.frame)/2);

    _backgroundView.alpha = backgroundViewAlpha;
    _alertView.center = CGPointMake(_alertView.center.x, y);
    _alertView.transform = CGAffineTransformMakeRotation(finalAngle);

    // animation
    [UIView animateWithDuration:inTime               // 进场动画时间
                          delay:0.0
         usingSpringWithDamping:0.9
          initialSpringVelocity:0.9
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _backgroundView.alpha = backgroundViewAlpha;
                         _alertView.transform = CGAffineTransformMakeRotation(0);
                         _alertView.center = CGPointMake(CGRectGetMidX(self.bounds),
                                                         CGRectGetMidY(self.bounds));
                     } completion:^(BOOL finished) {
                     }];
}

- (void)dismiss {
    [UIView animateWithDuration:outTime               // 出厂动画时间
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _backgroundView.alpha = 0.0;

                         _alertView.transform = CGAffineTransformMakeRotation(finalAngle);
                         _alertView.alpha = 0.0;

                         CGRect screenBounds = [UIScreen mainScreen].bounds;
                         float finalY = screenBounds.size.height / 2 + self.alertView.bounds.size.height;
                         self.alertConstraintCenterY.constant += finalY;

                         [self layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                         if (_dismissBlock != NULL) {
                             _dismissBlock();
                         }
                     }];
}

- (void)resetAlertViewPosition {
    [UIView animateWithDuration:0.3
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _backgroundView.alpha = backgroundViewAlpha;
                         _alertView.transform = CGAffineTransformMakeRotation(0);
                         self.alertConstraintCenterY.constant = 0;
                         [self layoutIfNeeded];
                     } completion:^(BOOL finished) {
                     }];
}

#pragma mark - button action

- (void)buttonAction:(UIButton *)sender {
    if (_buttonBlock != NULL) {
        _buttonBlock();
    }
    [self dismiss];
}

#pragma mark - helper methods

- (UILabel *)labelWithText:(NSString *)text {
    UILabel *label = [UILabel new];
    label.text = text;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;

    return label;
}

- (void)addSizeFitConstraint:(id)view1
                      toView:(id)view2
               widthConstant:(CGFloat)widthConstant
              heightConstant:(CGFloat)heightConstant {
    NSLayoutConstraint *centerX =
    [NSLayoutConstraint constraintWithItem:view1
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:view2
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1
                                  constant:0];

    NSLayoutConstraint *centerY =
    [NSLayoutConstraint constraintWithItem:view1
                                 attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:view2
                                 attribute:NSLayoutAttributeCenterY
                                multiplier:1
                                  constant:0];

    NSLayoutConstraint *width =
    [NSLayoutConstraint constraintWithItem:view1
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:view2
                                 attribute:NSLayoutAttributeWidth
                                multiplier:1.1     // NOTE, hack to work with ios7
                                  constant:widthConstant];

    NSLayoutConstraint *height =
    [NSLayoutConstraint constraintWithItem:view1
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:view2
                                 attribute:NSLayoutAttributeHeight
                                multiplier:1.1     // NOTE, hack to work with ios7
                                  constant:heightConstant];
    
    [view2 addConstraints:@[centerX, centerY, width, height]];
}

UIImage *
imageFromColor(UIColor *color){
      CGRect rect = CGRectMake(0, 0, 1, 1);
      UIGraphicsBeginImageContext(rect.size);
      CGContextRef context = UIGraphicsGetCurrentContext();
      CGContextSetFillColorWithColor(context, [color CGColor]);
      CGContextFillRect(context, rect);
      UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
      UIGraphicsEndImageContext();

      return image;
}

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
