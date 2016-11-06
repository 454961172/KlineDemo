//
//  KlineModel.h
//  kline
//
//  Created by HuangZiJia on 2016/10/27.
//  Copyright © 2016年 GuangZhou Heng Rui Asset Management Co. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KlineModel : NSObject

@property (nonatomic, copy)NSString *CreateTime;//时间
@property (nonatomic, copy)NSString *InstrumentID;
@property (nonatomic, copy)NSString *highs;//涨跌
@property (nonatomic, copy)NSString *ZhangFu;//涨幅
@property (nonatomic, copy)NSString *OpenInterest;//持仓量
@property (nonatomic, assign)float PreClosePrice;//上个收盘价格
@property (nonatomic, assign)float HighestPrice;//最高价
@property (nonatomic, assign)float LowestPrice;//最低价
@property (nonatomic, assign)float OpenPrice;//开盘
@property (nonatomic, assign)float LastPrice;//最新价
@property (nonatomic, copy)NSString *BidVolume;//买量
@property (nonatomic, copy)NSString *AskVolume;//卖量
@property (nonatomic, copy)NSString *BidPrice;//买价
@property (nonatomic, copy)NSString *AskPrice;//卖价

//k线数据

@property (nonatomic, copy)NSString *inventory;//持仓量
@property (nonatomic, copy)NSString *MinutePosition;//分钟持仓量
@property (nonatomic, copy)NSString *kHihgs;//涨跌
@property (nonatomic, copy)NSString *RiseAndFall;//涨跌幅
@property (nonatomic, copy)NSString *averages;//均价
@property (nonatomic, copy)NSString *ClosePrice;//昨收盘


- (void)GetModelArray:(void(^)(NSArray *dataArray))block;

@end
