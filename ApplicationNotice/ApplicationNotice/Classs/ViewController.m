//
//  ViewController.m
//  ApplicationNotice
//
//  Created by ___liangdahong on 2017/4/6.
//  Copyright © 2017年 ___liangdahong. All rights reserved.
//

#import "ViewController.h"
#import "BMApplicationNoticeView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    [BMApplicationNoticeView showRemoteNotification:@{@"aps" : @{@"alert" : @"test push"}} sound:arc4random_uniform(2) clickBlock:^{
        NSLog(@"clickBlock");
    }];
}

@end
