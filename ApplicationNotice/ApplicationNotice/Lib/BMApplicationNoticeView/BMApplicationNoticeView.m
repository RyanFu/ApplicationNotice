//
//  BMApplicationNoticeView.m
//  push
//
//  Created by ___liangdahong on 2017/4/6.
//  Copyright © 2017年 ___liangdahong. All rights reserved.
//

#import "BMApplicationNoticeView.h"
#import <AudioToolbox/AudioToolbox.h>

@interface BMApplicationNoticeView ()

@property (weak, nonatomic) IBOutlet UIScrollView *backgroundScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *pushTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pushDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *pushTimeLabel;
@property (strong, nonatomic, readwrite) UIView *contentView; ///< 内容view

@property (strong, nonatomic) NSDictionary *userInfo; ///< 推送数据
@property (copy, nonatomic) dispatch_block_t clickBlock; ///< 点击回调

@end

@implementation BMApplicationNoticeView

#pragma mark -

#pragma mark - init

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self addUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addUI];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self addUI];
    }
    return self;
}

#pragma mark - 生命周期

- (void)dealloc {
    
    [self.backgroundScrollView removeObserver:self forKeyPath:@"contentOffset"];
}

#pragma mark - getters setters

- (void)setUserInfo:(NSDictionary *)userInfo {
    
    _userInfo = userInfo;
    if ([userInfo isKindOfClass:[NSDictionary class]] && [userInfo[@"aps"] isKindOfClass:[NSDictionary class]]) {
        self.pushDescLabel.text = userInfo[@"aps"][@"alert"];
    }
}

- (UIView *)contentView {

    if (!_contentView) {
        _contentView = [[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil][0];
    }
    return _contentView;
}

#pragma mark - 公有方法

+ (void)showRemoteNotification:(NSDictionary *)userInfo
                         sound:(BOOL)sound
                    clickBlock:(dispatch_block_t)clickBlock {
    if (sound) {
        AudioServicesPlaySystemSound(1312);
    }

    // 需优化
    for (UIView *view in [UIApplication sharedApplication].keyWindow.subviews) {
        if ([view isKindOfClass:[self class]]) {
            [view removeFromSuperview];
        }
    }
    BMApplicationNoticeView *view = [BMApplicationNoticeView new];
    view.backgroundScrollView.showsVerticalScrollIndicator = NO;
    view.backgroundScrollView.showsHorizontalScrollIndicator = NO;
    view.backgroundScrollView.bounces = NO;
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    view.userInfo = userInfo;
    view.clickBlock = clickBlock;

    [view.backgroundScrollView addObserver:view forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    UIWindow *win = [UIApplication sharedApplication].keyWindow;
    [win addSubview:view];

    view.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *constraintTop = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:win attribute:NSLayoutAttributeTop multiplier:1.0 constant:-75.0];
    NSLayoutConstraint *constraintLeft = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:win attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *constraintRight = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:win attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *constraintHeight = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:0 constant:100];
    [win addConstraints:@[constraintTop, constraintLeft, constraintHeight, constraintRight]];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            constraintTop.constant = 0;
            [view.superview layoutIfNeeded];
        } completion:nil];
    });

    __weak typeof(BMApplicationNoticeView) *wself = view;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            __weak typeof(BMApplicationNoticeView) *sself = wself;
            constraintTop.constant = -75.0;
            [sself.superview layoutIfNeeded];
        } completion:^(BOOL finished) {
            __weak typeof(BMApplicationNoticeView) *sself = wself;
            [sself  removeFromSuperview];
            for (UIView *view in [UIApplication sharedApplication].keyWindow.subviews) {
                if ([view isKindOfClass:[self class]]) {
                    return;
                }
            }
            [UIApplication sharedApplication].statusBarHidden = NO;
        }];
    });
}

#pragma mark - 私有方法

- (void)addUI {
    
    [self addSubview:self.contentView];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *constraintTop    = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *constraintLeft   = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *constraintBottom = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    NSLayoutConstraint *constraintRight  = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    [self addConstraints:@[constraintTop, constraintLeft, constraintBottom, constraintRight]];

    NSDictionary *infoDictionary = [[NSBundle bundleForClass:[self class]] infoDictionary];
    
    NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    if (!appName) {
        appName = [infoDictionary objectForKey:@"CFBundleName"];
    }
    
    UIImage *appIcon = [UIImage imageNamed:@"AppIcon60x60"];
    if (!appIcon) {
        appIcon = [UIImage imageNamed:@"AppIcon80x80"];
    }
    
    self.iconImageView.image = appIcon;
    self.iconImageView.layer.cornerRadius = 3;
    self.iconImageView.clipsToBounds = YES;
    self.pushTitleLabel.text   = appName;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    CGPoint point = [change[NSKeyValueChangeNewKey] CGPointValue];
    if (point.y > 40.0) {
        if (!self.backgroundScrollView.tracking) {
            [self removeFromSuperview];
            for (UIView *view in [UIApplication sharedApplication].keyWindow.subviews) {
                if ([view isKindOfClass:[self class]]) {
                    return;
                }
            }
            [UIApplication sharedApplication].statusBarHidden = NO;
        }
    }
}

#pragma mark - 事件响应

- (IBAction)topBackgroundClick:(UITapGestureRecognizer *)sender {
    
    if (self.clickBlock) {
        self.clickBlock();
    }
}

@end
