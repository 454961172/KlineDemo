# KlineDemo

#demo介绍文章: http://www.jianshu.com/p/f37ab1e73006

方法介绍（包含以上除了横屏外的所有效果实现）
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

