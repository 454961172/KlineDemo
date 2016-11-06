//
//  lineView.m
//  kline
//
//  Created by HuangZiJia on 2016/10/27.
//  Copyright © 2016年 GuangZhou Heng Rui Asset Management Co. Ltd. All rights reserved.
//

#import "lineView.h"
#import "KlineModel.h"

#import <UIKit/UIKit.h>

static const NSInteger CellOffset = 10;


@interface lineView()


@property (nonatomic, assign)NSInteger count;
@property (nonatomic, strong)CAShapeLayer *ShapeLayer;

@property (nonatomic, strong)NSMutableArray *showArray;
@property (nonatomic, assign)CGFloat h;//单位点代表的高度

@property (nonatomic, strong)CAShapeLayer *ChangeLayer;
@property (nonatomic, strong)CAShapeLayer *TrackingCrosslayer;

@property (nonatomic, assign)NSInteger MaxCount;
@property (nonatomic, assign)NSInteger OffsetIndex;//偏移量 数据下标开始的显示范围

@property (nonatomic, assign)CGFloat height;

@property (nonatomic, strong)UIPanGestureRecognizer *pan;


@end

@implementation lineView

#pragma mark- 设置范围
- (instancetype)initWithFrame:(CGRect)frame Delegate:(id<lineDataSource>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showArray = [NSMutableArray new];
        self.delegate = delegate;
        [self reload];
        
    }
    return self;
}



#pragma mark- 设置代理 手势
- (void)setDelegate:(id<lineDataSource>)delegate{
    _delegate = delegate;
    if ([_delegate isKindOfClass:[UIViewController class]] || [_delegate isKindOfClass:[UIView class]]) {
        if (!self.pan) {
            self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        }
        if ([_delegate isKindOfClass:[UIView class]]) {
            UIView *view = (UIView *)_delegate;
            [view addGestureRecognizer:self.pan];
            view.userInteractionEnabled = YES;
        }else{
            UIViewController *vc = (UIViewController *)_delegate;
            [vc.view addGestureRecognizer:self.pan];
        }
    }
}
- (void)pan:(UIPanGestureRecognizer *)panGesture{
   
    
    if (self.showTrackingCross) {
         CGPoint point = [panGesture locationInView:panGesture.view];
        if (panGesture.state == UIGestureRecognizerStateChanged) {
            [self TrackingCrossFromPoint:point];
        }else if(panGesture.state == UIGestureRecognizerStateEnded){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.showTrackingCross = NO;
            });
        }
    }else{
         CGPoint point = [panGesture translationInView:panGesture.view];
         [self offset_xPoint:point];
        
    }
    
}


#pragma mark-
- (void)reload{
    if (!self.x_scale) {
        self.x_scale = 1;
    }
    
    self.count =  CGRectGetWidth(self.frame)/self.x_scale;
    self.height = CGRectGetHeight(self.frame);
    
    if ([self.delegate respondsToSelector:@selector(numberOfLineView:)]) {
        self.MaxCount = [self.delegate numberOfLineView:self];
        
    }
    if ([self.delegate respondsToSelector:@selector(LineView:cellAtIndex:)]) {
        NSInteger index = self.MaxCount-self.count;
        if (index < 0) {
            index = 0;
        }
        self.OffsetIndex = index;
        [self offset_xPoint:CGPointMake(0, 0)];
    }
}
//计算最高最低
- (void)CalculationHeightAndLowerFromArray:(NSArray *)array{
    _lowerPrice = 0;
    _heightPrice = 0;
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KlineModel *model = obj;
        if (model.HighestPrice > self.heightPrice) {
            _heightPrice = model.HighestPrice;
        }
        if (self.lowerPrice == 0) {
            _lowerPrice = model.LowestPrice;
        }
        if (model.LowestPrice < self.lowerPrice) {
            _lowerPrice = model.LowestPrice;
        }
        
    }];
    [self CalculationH];
}

//计算最高最低值
- (void)CalculationH{
    //将改变的值 放出去
    if ([self.delegate respondsToSelector:@selector(willReload)]) {
        [self.delegate willReload];
    }
    
    
    self.h = (self.heightPrice-self.lowerPrice)/self.height;
    
    [self CalculationShowPointFromLastPrices:self.showArray];
}

//计算所有点位
- (void)CalculationShowPointFromLastPrices:(NSArray *)array{

    UIBezierPath *path = [UIBezierPath bezierPath];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < array.count-1) {
            KlineModel *model = obj;
            CGPoint point = CGPointMake(idx*self.x_scale, self.height - (model.LastPrice-self.lowerPrice)/self.h);
            if (idx == 0) {
                [path moveToPoint:point];
            }else{
                [path addLineToPoint:point];
            }
        }
    }];
    path.lineWidth = 0.75;
    path.lineCapStyle = kCGLineCapRound; //线条拐角
    path.lineJoinStyle = kCGLineCapRound; //终点处理
    
    //绘制不变的部分
    if (self.ShapeLayer) {
        self.ShapeLayer.path = nil;
        [self.ShapeLayer removeFromSuperlayer];
    }
    self.ShapeLayer = [CAShapeLayer layer];
    self.ShapeLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    self.ShapeLayer.strokeColor = [UIColor colorWithRed:40/255.0 green:135/255.0 blue:255/255.0 alpha:1].CGColor;
    self.ShapeLayer.fillColor = [UIColor clearColor].CGColor;
    
    self.ShapeLayer.path = path.CGPath;
    [self.layer addSublayer:self.ShapeLayer];
    
    [self replacementLastPoint:[array lastObject]];
}

//替换以后一个元素
- (void)replacementLastPoint:(KlineModel *)model{
    
    if (model.LastPrice > self.heightPrice) {
        _heightPrice = model.LastPrice;
        [self CalculationH];
        return;
    }
    if (model.LastPrice < self.lowerPrice) {
        _lowerPrice = model.LastPrice;
        [self CalculationH];
        return;
    }
    
    KlineModel *starModel;
    
    if (self.showArray.count > 1) {
        starModel = [self.showArray objectAtIndex:self.showArray.count-2];
        
        //重置
        if (!self.ChangeLayer) {
            self.ChangeLayer = [CAShapeLayer layer];
            self.ChangeLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
            self.ChangeLayer.strokeColor = [UIColor colorWithRed:40/255.0 green:135/255.0 blue:255/255.0 alpha:1].CGColor;
            self.ChangeLayer.fillColor = [UIColor clearColor].CGColor;
            
        }else{
            self.ChangeLayer.path = nil;
        }
        
        
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        CGPoint point = CGPointMake(self.showArray.count-2, self.height - (starModel.LastPrice-self.lowerPrice)/self.h);
        [path moveToPoint:point];
        
        CGPoint point1 = CGPointMake(self.showArray.count-1, self.height - (model.LastPrice-self.lowerPrice)/self.h);
        [path addLineToPoint:point1];
        path.lineWidth = 0.75;
        path.lineCapStyle = kCGLineCapRound; //线条拐角
        path.lineJoinStyle = kCGLineCapRound; //终点处理

        self.ChangeLayer.path = path.CGPath;
        
        
        [self.layer addSublayer:self.ChangeLayer];
        
    }else if(self.showArray.count == 1){
        UIBezierPath *path = [UIBezierPath bezierPath];
        CGPoint point = CGPointMake(0, self.height - (model.LastPrice-self.lowerPrice)/self.h);
        [path moveToPoint:point];
        [path addLineToPoint:point];
        path.lineWidth = 0.75;
        path.lineCapStyle = kCGLineCapRound; //线条拐角
        path.lineJoinStyle = kCGLineCapRound; //终点处理
        
        self.ShapeLayer.path = path.CGPath;
    }
    
    
    
}

//滑动效果
- (void)offset_xPoint:(CGPoint)point{
    
    
    if ([self.delegate respondsToSelector:@selector(LineView:cellAtIndex:)]) {

        //计算偏移量
        if (point.x < 0) {
            self.OffsetIndex += CellOffset;
        }else if (point.x > 0){
            self.OffsetIndex -= CellOffset;
        }
        if (self.OffsetIndex < 0) {
            self.OffsetIndex = 0;
        }
        if (self.OffsetIndex > _MaxCount-_count) {
            self.OffsetIndex = _MaxCount-_count-1;
        }
        
        NSInteger index = self.OffsetIndex;
        if (index < 0) {
            index = 0;
        }
        
        
        @synchronized (self) {
            [self.showArray removeAllObjects];
            
            for (NSInteger i = 0; i<_count; i++,index++) {
                [self.showArray addObject:[self.delegate LineView:self cellAtIndex:index]];
            }
            
        }
        
        [self CalculationHeightAndLowerFromArray:self.showArray];
        
    }
    
    
}



//十字光标
- (void)TrackingCrossFromPoint:(CGPoint)point{
    if (self.showArray.count == 0) {
        return;
    }
    NSInteger index = point.x/self.x_scale;
    if (index > self.showArray.count-1) {
        index = self.showArray.count-1;
    }
    KlineModel *model = self.showArray[index];
    
    
    CGPoint point_X = CGPointMake(0, self.height - (model.LastPrice-self.lowerPrice)/self.h);
    CGPoint point_endX = CGPointMake(CGRectGetWidth(self.frame), self.height - (model.LastPrice-self.lowerPrice)/self.h);
    
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:point_X];
    [path addLineToPoint:point_endX];
    
    
    CGPoint point_Y = CGPointMake(point.x, 0);
    CGPoint point_endY = CGPointMake(point.x, self.height);
    
    [path moveToPoint:point_Y];
    [path addLineToPoint:point_endY];
    
    path.lineWidth = 0.75;
    path.lineCapStyle = kCGLineCapRound; //线条拐角
    path.lineJoinStyle = kCGLineCapRound; //终点处理
    
    if (!self.TrackingCrosslayer) {
        self.TrackingCrosslayer = [CAShapeLayer layer];
        self.TrackingCrosslayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        self.TrackingCrosslayer.strokeColor = [UIColor colorWithRed:40/255.0 green:135/255.0 blue:255/255.0 alpha:1].CGColor;
        self.TrackingCrosslayer.fillColor = [UIColor clearColor].CGColor;
        
    }else{
        self.TrackingCrosslayer.path = nil;
    }
    
    self.TrackingCrosslayer.path = path.CGPath;
    
    
    [self.layer addSublayer:self.TrackingCrosslayer];
    
    if ([self.delegate respondsToSelector:@selector(TrackingCrossIndexModel:IndexPoint:)]) {
        [self.delegate TrackingCrossIndexModel:model IndexPoint:CGPointMake(point_X.y, point_Y.x)];
    }

}


- (void)setShowTrackingCross:(BOOL)showTrackingCross{
    _showTrackingCross = showTrackingCross;
    if (showTrackingCross) {
        
        CGPoint centerPoint = self.center;
        [self TrackingCrossFromPoint:centerPoint];
    }else{
        if (self.TrackingCrosslayer) {
            [self.TrackingCrosslayer removeFromSuperlayer];
        }
    }
}

- (void)removeLineLayer{
    [self.layer removeFromSuperlayer];
}

- (void)dealloc{
    NSLog(@"11");
}




@end
