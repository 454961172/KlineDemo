//
//  GetKlinData.h
//  kline
//
//  Created by HuangZiJia on 2016/10/27.
//  Copyright © 2016年 GuangZhou Heng Rui Asset Management Co. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GetKlineData;

@protocol GetKlineDataDelegate <NSObject>

- (void)GetDatasFromGetKline:(GetKlineData *)obj Array:(NSArray *)array;

@end

@interface GetKlineData : NSObject

@property (weak, nonatomic)id <GetKlineDataDelegate>delegate;

- (void)GetDataAddDelegate:(id<GetKlineDataDelegate>)delegate;

@end
