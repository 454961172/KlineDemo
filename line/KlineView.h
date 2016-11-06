//
//  KlineView.h
//  kline
//
//  Created by HuangZiJia on 2016/11/1.
//  Copyright © 2016年 GuangZhou Heng Rui Asset Management Co. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "lineDataSource.h"

@class CAShapeLayer,KlineModel;

@interface KlineView : UIView

@property (nonatomic, weak)id<lineDataSource>delegate;

- (instancetype)initWithFrame:(CGRect)frame Delegate:(id<lineDataSource>)delegate;//这种写法一般是不可取的 不能强制要求设置代理。 因为这个类特殊 所以偷懒了。


@property (nonatomic, assign,readonly)CGFloat heightPrice;//外界可能需要展示这个最高价
@property (nonatomic, assign,readonly)CGFloat lowerPrice;//外界可能需要展示这个最低价
@property (nonatomic, assign,getter=isShowTrackingCross)BOOL ShowTrackingCross;


- (void)reload;//重新刷新视图 外界数据变化的时候可用
- (void)replacementLastPoint:(KlineModel *)model;//替换最后一点 tcp数据跳动的时候可用

@end
