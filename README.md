# KlineDemo

#demo介绍文章: http://www.jianshu.com/p/f37ab1e73006

方法介绍（包含以上除了横屏外的所有效果实现）

#代理 改变视图变化的操作

@class CAShapeLayer,KlineModel;

@protocol lineDataSource <NSObject>

//展示的下标位置 count 展示的个数
- (KlineModel *)LineView:(UIView *)view cellAtIndex:(NSInteger)index;
- (NSInteger)numberOfLineView:(UIView *)view ;//返回数组总共要移动的个数

@optional
- (void)TrackingCrossIndexModel:(KlineModel *)model IndexPoint:(CGPoint)Point;//十字光标滑动时候选择的model和对应的point

- (void)willReload;//在这个方法里面  会刷新最高最低价格

@end


#外部方法

@property (nonatomic, weak)id<lineDataSource>delegate;

- (instancetype)initWithFrame:(CGRect)frame Delegate:(id<lineDataSource>)delegate;//这种写法一般是不可取的 不能强制要求设置代理。 因为这个类特殊 所以偷懒了。


@property (nonatomic, assign,readonly)CGFloat heightPrice;//外界可能需要展示这个最高价
@property (nonatomic, assign,readonly)CGFloat lowerPrice;//外界可能需要展示这个最低价
@property (nonatomic, assign,getter=isShowTrackingCross)BOOL ShowTrackingCross;


- (void)reload;//重新刷新视图 外界数据变化的时候可用
- (void)replacementLastPoint:(KlineModel *)model;//替换最后一点 tcp数据跳动的时候可用



#内部私有方法
- (void)offset_xPoint方法:
如果point.x >0 减去偏移量 显示之前的数据 为0的时候显示self.OffsetIndex开始的数据 否则显示之后的数据。



- (void)CalculationHeightAndLowerFromArray:(NSArray:) ;
//遍历获取显示数据的最高最低值



- (void)CalculationH;
//计算self.h每个点代表的值是多少



- (void)CalculationShowPointFromLastPrices:(NSArray <KlineModel *>*)array
//绘制所有蜡烛图通过代理获取到的model数据的蜡烛图



- (void)replacementLastPoint:(KlineModel *)model
//替换最后一个点 逻辑是删除self.ShapeLayer的最后一个视图 再通过model生成这个位置对应的蜡烛图 添加到父layer



- (CAShapeLayer *)GetShapeLayerFromModel:(KlineModel *)model Index:(NSInteger)idx
//通过model和对应下标生成蜡烛图 添加到父视图中 



- (void)offset_xPoint:(CGPoint)point
//滑动效果 改变OffsetIndex的值 刷新数据



- (void)pinchAction:(UIPinchGestureRecognizer *)pinch
//缩放效果 改变x_scale的值 刷新数据



- (void)panGesture:(UIPanGestureRecognizer *)pan
//通过self.isShowTrackingCross判断是否显示十字光标  否则拉动新的数据



- (void)TrackingCrossFromPoint:(CGPoint)point
//十字光标  通过point逆推得出index 现在的下标/(单元大小)*缩放量

//获取point.x坐标 和这个model的最新价或者其它价格对应的y  这里展示最新价

//把model通过@selector(TrackingCrossIndexModel:IndexPoint:)传递给外界 绘制当前路径



- (void)setShowTrackingCross:(BOOL)ShowTrackingCross
重写set方法判断是否隐藏十字光标



横屏效果
在监控到屏幕转动的时候重新设置frame 调用reload就好了。 里面暂时没做任何处理.

其它细节请参考理论篇 请找茬 共同进步！！

