//
//  KlineView.m
//  kline
//
//  Created by HuangZiJia on 2016/11/1.
//  Copyright © 2016年 GuangZhou Heng Rui Asset Management Co. Ltd. All rights reserved.
//

#import "KlineView.h"

#import "KlineModel.h"
#import "averagePriceLayer.h"


static const NSInteger KlineCellSpace = 2;//cell间隔
static const NSInteger KlineCellWidth = 6;//cell宽度
static const NSInteger CellOffset = 3;//偏移的单位（速度）

static const CGFloat scale_Min = 0.1;//最小缩放量
static const CGFloat scale_Max = 1;//最大缩放量


@interface KlineView()

@property (nonatomic, strong)CAShapeLayer *ShapeLayer;//父layer

@property (nonatomic, assign)NSInteger ShowArrayMaxCount;//展示的最大个数 保存这个最大值

@property (nonatomic, strong)UIPanGestureRecognizer *pan;//拖动手势
@property (nonatomic, strong)NSMutableArray *KlineShowArray;//保存k线图需要展示的数据

@property (nonatomic, assign)CGFloat ShowHeight;//保存这个view的高
@property (nonatomic, assign)CGFloat ShowWidth;//保存这个view的宽

@property (nonatomic, assign)CGFloat h;//view每个点代表的高度
@property (nonatomic, assign) NSInteger count;//view能容纳显示多少个


@property (nonatomic, assign)NSInteger OffsetIndex;//偏移量 记录数据下标开始的显示范围
@property (nonatomic, assign)CGFloat x_scale;//x坐标缩放的比例

@property (nonatomic, strong)CAShapeLayer *TrackingCrosslayer;//十字光标的layer层

@property (nonatomic, strong)UIColor *redColor;//红色 涨的蜡烛
@property (nonatomic, strong)UIColor *BlueColor;//蓝色 跌的蜡烛 偏绿色吧
@property (nonatomic, strong)UIColor *whiteColor;//白色 平的蜡烛

@property (nonatomic, strong)averagePriceLayer *APLayer;//均线的


@end

@implementation KlineView


#pragma mark- 基本设置

- (instancetype)initWithFrame:(CGRect)frame Delegate:(id<lineDataSource>)delegate{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;
        //暂时不理会均线
        self.APLayer = [averagePriceLayer layer];
        self.APLayer.frame = self.bounds;
//        self.backgroundColor = [UIColor blackColor];
        
        [self Kline_init];
    }
    return self;
}

- (void)Kline_init{
    self.KlineShowArray = [NSMutableArray new];
    
    self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [self addGestureRecognizer:self.pan];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    [self addGestureRecognizer:pinch];
    
    self.redColor = [UIColor redColor];
    self.BlueColor = [UIColor colorWithRed:71/255.0 green:211/255.0 blue:209/255.0 alpha:1];
    self.whiteColor = [UIColor whiteColor];
    
    [self reload];
}

#pragma mark- 响应手势
- (void)panGesture:(UIPanGestureRecognizer *)pan{
   
    //十字光标开启 进入滑动显示对应的model数据
    if (self.isShowTrackingCross) {
        //记录初始点
         CGPoint point = [pan locationInView:pan.view];
        if (pan.state == UIGestureRecognizerStateChanged) {
            //移动十字光标
            [self TrackingCrossFromPoint:point];
        }else if(pan.state == UIGestureRecognizerStateEnded){
            //手指离开后 3秒后移除十字光标
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.ShowTrackingCross = NO;
            });
        }
    }else{
        //十字光标关闭 拉动显示图显示其它数据
        //判断左右移动
         CGPoint point = [pan translationInView:pan.view];
        //更改移动点
        [self offset_xPoint:point];
        
    }
}

//缩放
- (void)pinchAction:(UIPinchGestureRecognizer *)pinch{
    @synchronized (self) {
        //查看缩放比例
        self.x_scale *= pinch.scale;
        //调整比例
        if (_x_scale < scale_Min) {
            self.x_scale = scale_Min;
        }else if (_x_scale > scale_Max){
            self.x_scale = scale_Max;
        }
    }
    [self reload];
}

//重新绘制
- (void)reload{
    if ([self.delegate respondsToSelector:@selector(numberOfLineView:)]) {
        self.ShowArrayMaxCount = [self.delegate numberOfLineView:self];
    }
    self.ShowHeight = CGRectGetHeight(self.frame);
    self.ShowWidth = CGRectGetWidth(self.frame);
    
    if (!self.x_scale) {
        self.x_scale = 1;
    }
    //计算这个视图里面 能容纳多少个蜡烛图  宽度/(间隔＋单位蜡烛的宽度)*缩放的比例
    self.count = self.ShowWidth/((KlineCellSpace+KlineCellWidth)*self.x_scale);
    //计算现在是从哪一个下标开始取 总个数减去显示的个数
    NSInteger index = self.ShowArrayMaxCount - _count;
    
    if (index < 0) {
        index = 0;
    }
    self.OffsetIndex = index;//初始化偏移位置
    
    //开始绘图
    [self offsetNormal];
}

- (void)offsetNormal{
    [self offset_xPoint:CGPointMake(0, 0)];
}

//计算最高最低
- (void)CalculationHeightAndLowerFromArray:(NSArray *)array{
    _lowerPrice = 0;
    _heightPrice = 0;
    //遍历获取最高最低值
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KlineModel *model = obj;
        
        CGFloat HeighestFloat = MAX(model.HighestPrice, model.LastPrice);
        
        if (HeighestFloat > self.heightPrice) {
            _heightPrice = HeighestFloat;
        }
        
        if (self.lowerPrice == 0) {
            _lowerPrice = model.LowestPrice;
        }
        
        
        if (model.LowestPrice < self.lowerPrice || model.LastPrice < self.lowerPrice) {
            if (model.LastPrice > 0 && model.LowestPrice > 0) {
                _lowerPrice = MIN(model.LowestPrice, model.LastPrice);
            }
        }
    }];
    
    //调整比例
    _lowerPrice *= 0.9996;
    _heightPrice *= 1.0004;
    
    //
    [self CalculationH];
    
}

//计算每个点代表的值是多少
- (void)CalculationH{
    //将改变的值 放出去
    if ([self.delegate respondsToSelector:@selector(willReload)]) {
        [self.delegate willReload];
    }
    self.h = (self.heightPrice-self.lowerPrice)/self.ShowHeight;
    
    [self CalculationShowPointFromLastPrices:self.KlineShowArray];
}




//计算所有点位
- (void)CalculationShowPointFromLastPrices:(NSArray <KlineModel *>*)array{
    //重置ShapeLayer 父层
    [self initShapeLayer];
    [array enumerateObjectsUsingBlock:^(KlineModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //生成蜡烛图 添加到父层
        CAShapeLayer *cellCAShapeLayer = [self GetShapeLayerFromModel:model Index:idx];
        [self.ShapeLayer addSublayer:cellCAShapeLayer];
    }];



    //把这些层添加到这个view
    [self.layer addSublayer:self.ShapeLayer];
    [self.layer addSublayer:self.APLayer];
}

//替换以后一个点
- (void)replacementLastPoint:(KlineModel *)model{
    //如果父视图存在
    if (self.ShapeLayer) {
        //删除最后一个点
        NSArray *layerArray = self.ShapeLayer.sublayers;
        if (layerArray) {
            if (layerArray.count >0) {
                CAShapeLayer *Slayer = (CAShapeLayer *)[self.ShapeLayer.sublayers lastObject];
                [Slayer removeFromSuperlayer];
            }
        }
    }else{
        [self initShapeLayer];
    }
    //生成新的点 添加到父视图
    CAShapeLayer *layer = [self GetShapeLayerFromModel:model Index:self.KlineShowArray.count-1];
    [self.ShapeLayer addSublayer:layer];
}

//制作CAShapeLayer
- (CAShapeLayer *)GetShapeLayerFromModel:(KlineModel *)model Index:(NSInteger)idx{
    CGFloat OpenPrice = (model.OpenPrice- self.lowerPrice)/self.h;//开盘价减去这个视图的最小价格得出差值除以每一个点代表的值 以下一样
    CGFloat PreClosePrice = (model.PreClosePrice- self.lowerPrice)/self.h;
    CGFloat x = (KlineCellSpace+KlineCellWidth)*idx*self.x_scale;
    CGFloat y = OpenPrice > PreClosePrice ? PreClosePrice : OpenPrice;
    //fabs 取整
    CGFloat height = MAX(fabs(PreClosePrice-OpenPrice), 1);
    
    
    //在这里绘制好方形  如果出现蜡烛倒置  可用showheight－height 或者倒转这个layer
    CGRect rect = CGRectMake(x, y, KlineCellWidth*self.x_scale, height);
    
    //用贝塞尔描路径
    UIBezierPath *cellpath = [UIBezierPath bezierPathWithRect:rect];
    cellpath.lineWidth = 0.75;
    
    //移动点 绘制最高最低值
    [cellpath moveToPoint:CGPointMake(x+KlineCellWidth/2, y)];
    [cellpath addLineToPoint:CGPointMake(x+KlineCellWidth/2, (model.LowestPrice- self.lowerPrice)/self.h)];
    
    [cellpath moveToPoint:CGPointMake(x+KlineCellWidth/2, y+height)];
    [cellpath addLineToPoint:CGPointMake(x+KlineCellWidth/2, (model.HighestPrice- self.lowerPrice)/self.h)];
    
    //生成layer 用贝塞尔路径给他渲染
    CAShapeLayer *cellCAShapeLayer = [CAShapeLayer layer];
    cellCAShapeLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    cellCAShapeLayer.fillColor = [UIColor clearColor].CGColor;
    
    //调整颜色
    if (model.OpenPrice == model.PreClosePrice) {
        cellCAShapeLayer.strokeColor = _whiteColor.CGColor;
    }else if (model.OpenPrice > model.PreClosePrice){
        cellCAShapeLayer.strokeColor = _redColor.CGColor;
    }else{
        cellCAShapeLayer.fillColor = _BlueColor.CGColor;
    }
    cellCAShapeLayer.path = cellpath.CGPath;
    
    [cellpath removeAllPoints];
    //返回一个蜡烛图
    return cellCAShapeLayer;
}


//滑动效果
- (void)offset_xPoint:(CGPoint)point{
    if ([self.delegate respondsToSelector:@selector(LineView:cellAtIndex:)]) {
        
        //计算偏移量
        if (point.x < 0) {
            self.OffsetIndex += CellOffset;
        }else if(point.x > 0){
            self.OffsetIndex -= CellOffset;
        }
        if (self.OffsetIndex < 0) {
            self.OffsetIndex = 0;
        }
        if (self.OffsetIndex > _ShowArrayMaxCount-_count) {
            self.OffsetIndex = _ShowArrayMaxCount-_count-1;
        }
        
        NSInteger index = self.OffsetIndex;
  
        if (index < 0) {
            index = 0;
        }

        //获取到对应的数据
        @synchronized (self) {
            [self.KlineShowArray removeAllObjects];
            NSInteger count = MIN(_count, _ShowArrayMaxCount);
            for (NSInteger i = 0; i<count; i++,index++) {
                KlineModel *model = [self.delegate LineView:self cellAtIndex:index];
                if (model) {
                    [self.KlineShowArray addObject:model];
                }
                
            }
        }
        
        //继续走流程
        [self CalculationHeightAndLowerFromArray:self.KlineShowArray];
        
        //这是均线的 不理他。
        [self initAP];
        
    }
    
    
}

- (void)initAP{
    NSInteger APIndex = self.OffsetIndex-20;
    if (APIndex < 0) {
        APIndex = 0;
    }
    NSMutableArray *APArray = [NSMutableArray new];
    for (NSInteger i = APIndex; i<self.OffsetIndex;i++) {
        [APArray addObject:[self.delegate LineView:self cellAtIndex:i]];
    }
    [APArray addObjectsFromArray:self.KlineShowArray];
    
    self.APLayer.x_scale = self.x_scale;
    self.APLayer.lowerPrice = self.lowerPrice;
    self.APLayer.h = self.h;
    [self.APLayer loadLayerPreMigration:APArray.count-self.KlineShowArray.count KmodelArray:APArray];
}


#pragma mark- 十字光标
//十字光标
- (void)TrackingCrossFromPoint:(CGPoint)point{
    if (self.KlineShowArray.count == 0) {
        return;
    }
    //通过point逆推得出index 现在的下标/(单元大小)*缩放量
    NSInteger index = point.x/(KlineCellSpace+KlineCellWidth)*self.x_scale;
    //防止数组越界
    if (index > self.KlineShowArray.count-1) {
        index = self.KlineShowArray.count-1;
    }
    if (index < 0) {
        return;
    }
    //获得对应的model
    KlineModel *model = self.KlineShowArray[index];
    
    //获取x坐标 和这个model的最新价或者其它价格对应的y  这里展示最新价
    CGPoint point_X = CGPointMake(0, (model.LastPrice-self.lowerPrice)/self.h);
    CGPoint point_endX = CGPointMake(self.ShowWidth, (model.LastPrice-self.lowerPrice)/self.h);
    
    //绘图
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:point_X];
    [path addLineToPoint:point_endX];
    
    
    CGPoint point_Y = CGPointMake(point.x, 0);
    CGPoint point_endY = CGPointMake(point.x, self.ShowHeight);
    
    [path moveToPoint:point_Y];
    [path addLineToPoint:point_endY];
    
    path.lineWidth = 0.75;
    path.lineCapStyle = kCGLineCapRound; //线条拐角
    path.lineJoinStyle = kCGLineCapRound; //终点处理
    
    //展示十字光标
    self.TrackingCrosslayer.path = nil;
    
    if (!self.TrackingCrosslayer) {
        self.TrackingCrosslayer = [CAShapeLayer layer];
        self.TrackingCrosslayer.frame = CGRectMake(0, 0, self.ShowWidth, self.ShowHeight);
        self.TrackingCrosslayer.strokeColor = [UIColor colorWithRed:40/255.0 green:135/255.0 blue:255/255.0 alpha:1].CGColor;
        self.TrackingCrosslayer.fillColor = [UIColor clearColor].CGColor;
        
    }
    
    self.TrackingCrosslayer.path = path.CGPath;
    
    [self.layer addSublayer:self.TrackingCrosslayer];
    //把值传递给外界
    if ([self.delegate respondsToSelector:@selector(TrackingCrossIndexModel:IndexPoint:)]) {
        [self.delegate TrackingCrossIndexModel:model IndexPoint:CGPointMake(point_X.y, point_Y.x)];
    }
    
}

- (void)initShapeLayer{
    if (self.ShapeLayer) {
        [self.ShapeLayer removeFromSuperlayer];
        self.ShapeLayer = nil;
    }
    if (self.ShapeLayer == nil) {
        self.ShapeLayer = [CAShapeLayer layer];
        self.ShapeLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        self.ShapeLayer.strokeColor = [UIColor colorWithRed:40/255.0 green:135/255.0 blue:255/255.0 alpha:1].CGColor;
        self.ShapeLayer.fillColor = [UIColor clearColor].CGColor;
    }
}


//隐藏十字光标
- (void)setShowTrackingCross:(BOOL)ShowTrackingCross{
    _ShowTrackingCross = ShowTrackingCross;
    if (ShowTrackingCross) {
        CGPoint centerPoint = self.center;
        [self TrackingCrossFromPoint:centerPoint];
    }else{
        if (self.TrackingCrosslayer) {
            [self.TrackingCrosslayer removeFromSuperlayer];
        }
    }
}




@end
