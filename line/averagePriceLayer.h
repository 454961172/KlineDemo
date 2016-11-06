//
//  averagePriceLayer.h
//  kline
//
//  Created by HuangZiJia on 2016/11/1.
//  Copyright © 2016年 GuangZhou Heng Rui Asset Management Co. Ltd. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@class KlineModel;

@interface averagePriceLayer : CALayer

@property (nonatomic, assign)CGFloat h;//view每个点代表的高度
@property (nonatomic, assign)CGFloat lowerPrice;//最低点的值
@property (nonatomic, assign)CGFloat x_scale;

//传入现在绘制的点下标  还有从20个点之前加上k线图显示的个数的数组
- (void)loadLayerPreMigration:(NSInteger)offsetX KmodelArray:(NSMutableArray <KlineModel *>*)array;


@end
