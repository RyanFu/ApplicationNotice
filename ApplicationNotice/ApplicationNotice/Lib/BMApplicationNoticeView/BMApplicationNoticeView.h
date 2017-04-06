//
//  BMApplicationNoticeView.h
//  push
//
//  Created by ___liangdahong on 2017/4/6.
//  Copyright © 2017年 ___liangdahong. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 模仿系统原生推送的UI
 在 info.plist 文件添加
 View controller-based status bar appearance = NO
 */
@interface BMApplicationNoticeView : UIView

/**
 显示推送UI
 
 @param userInfo 推送内容
 @param sound 是否有音效
 @param clickBlock 点击回调block
 */
+ (void)showRemoteNotification:(NSDictionary*)userInfo
                         sound:(BOOL)sound
                    clickBlock:(dispatch_block_t)clickBlock;

@end
