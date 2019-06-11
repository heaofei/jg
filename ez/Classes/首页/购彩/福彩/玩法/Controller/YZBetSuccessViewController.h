//
//  YZBetSuccessViewController.h
//  ez
//
//  Created by apple on 14-9-19.
//  Copyright (c) 2014年 9ge. All rights reserved.
//
typedef enum : NSUInteger {
    BetTypeNormal = 1,//1：正常
    BetTypeFastBet = 2,//2：快速投注
    BetTypeSmartBet = 3,//3：智能追号
    BetTypeUnionbuyBet = 4,//4：合买
} PayVcType;

#import "YZBaseViewController.h"

@interface YZBetSuccessViewController : YZBaseViewController

@property (nonatomic, assign) PayVcType payVcType;
@property (nonatomic, assign) int isDismissVC;
@property (nonatomic, assign) int termCount;

@end
