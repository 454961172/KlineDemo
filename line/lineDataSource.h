//
//  lineDataSource.h
//  kline
//
//  Created by HuangZiJia on 2016/10/31.
//  Copyright © 2016年 GuangZhou Heng Rui Asset Management Co. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CAShapeLayer,KlineModel;

@protocol lineDataSource <NSObject>

//展示的下标位置 count 展示的个数
- (KlineModel *)LineView:(UIView *)view cellAtIndex:(NSInteger)index;
- (NSInteger)numberOfLineView:(UIView *)view ;//返回数组总共要移动的个数

@optional
- (void)TrackingCrossIndexModel:(KlineModel *)model IndexPoint:(CGPoint)Point;//十字光标滑动时候选择的model和对应的point

- (void)willReload;//在这个方法里面  会刷新最高最低价格

@end
