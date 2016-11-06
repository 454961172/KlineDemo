//
//  KlineModel.m
//  kline
//
//  Created by HuangZiJia on 2016/10/27.
//  Copyright © 2016年 GuangZhou Heng Rui Asset Management Co. Ltd. All rights reserved.
//

#import "KlineModel.h"
#import "GetKlineData.h"

@interface KlineModel()<GetKlineDataDelegate>

@property (nonatomic, copy)void (^block)(NSArray *array);

@end

@implementation KlineModel



- (void)GetModelArray:(void (^)(NSArray *))block{
    self.block = [block copy];
    GetKlineData *GetObj = [GetKlineData new];
    [GetObj GetDataAddDelegate:self];
}

- (void)GetDatasFromGetKline:(GetKlineData *)obj Array:(NSArray *)array{
    NSMutableArray *datas = [NSMutableArray new];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [datas addObject:[self mymodel:obj]];
    }];
    if (self.block) {
        self.block(datas);
    }
}



/*
 * 数组的顺序
 InstrumentID,LastPrice,AveragePrice,PreSettlementPrice,HighestPrice, 0-4
 LowestPrice,PreClosePrice,BidPrice1,BidVolume1,AskPrice1, 5-9
 AskVolume1,CreateTime,OpenInterest 10-12
 */

- (KlineModel *)mymodel:(id)objc{//获取广告弹窗
    KlineModel *model;
    if ([[objc class] isSubclassOfClass:[NSArray class]]){
        NSMutableArray *dataArray = objc;
        model = [[KlineModel alloc] init];
        
        model.LastPrice     = [dataArray[1] floatValue];
        model.PreClosePrice = [dataArray[3] floatValue];
        model.HighestPrice  = [dataArray[4] floatValue];
        model.LowestPrice   = [dataArray[5] floatValue];
        model.OpenPrice     = [dataArray[6] floatValue];
    }else{
        return nil;
    }
    return model;
}




@end
