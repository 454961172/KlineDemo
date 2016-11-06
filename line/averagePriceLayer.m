//
//  averagePriceLayer.m
//  kline
//
//  Created by HuangZiJia on 2016/11/1.
//  Copyright © 2016年 GuangZhou Heng Rui Asset Management Co. Ltd. All rights reserved.
//

#import "averagePriceLayer.h"
#import <UIKit/UIKit.h>
#import "KlineModel.h"

static NSString *const fiveColor = @"18c9f2";
static NSString *const TenColor  = @"ffe500";
static NSString *const TwentyColor  = @"dd3ddc";
static const NSInteger KlineCellSpace = 2;//cell间隔
static const NSInteger KlineCellWidth = 6;//cell宽度

static const NSInteger fiveLine = 4;
static const NSInteger tenLine  = 9;
static const NSInteger twenryLine = 19;


@interface averagePriceLayer()

@property (nonatomic, strong)CAShapeLayer *fiveMinAP;
@property (nonatomic, strong)CAShapeLayer *TenMinAP;
@property (nonatomic, strong)CAShapeLayer *TwentyMinAP;

@end

@implementation averagePriceLayer


- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    if (_fiveMinAP == nil) {
        _fiveMinAP = [CAShapeLayer layer];
        _fiveMinAP.frame = frame;
        _fiveMinAP.strokeColor = [self colorWithHexString:fiveColor].CGColor;
        _fiveMinAP.fillColor   = [UIColor clearColor].CGColor;
        [self addSublayer:_fiveMinAP];
    }
    
    if (_TenMinAP == nil) {
        _TenMinAP = [CAShapeLayer layer];
        _TenMinAP.frame = frame;
        _TenMinAP.strokeColor = [self colorWithHexString:TenColor].CGColor;
        _TenMinAP.fillColor   = [UIColor clearColor].CGColor;
        [self addSublayer:_TenMinAP];
    }
    if (_TwentyMinAP == nil) {
        _TwentyMinAP = [CAShapeLayer layer];
        _TwentyMinAP.frame = frame;
        _TwentyMinAP.strokeColor = [self colorWithHexString:TwentyColor].CGColor;
        _TwentyMinAP.fillColor   = [UIColor clearColor].CGColor;
        [self addSublayer:_TwentyMinAP];
    }
    
}

- (void)loadLayerPreMigration:(NSInteger)offsetX KmodelArray:(NSMutableArray<KlineModel *> *)array{

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __block CGFloat fiveLineFloat = 0;
        __block CGFloat TenLineFloat  = 0;
        __block CGFloat TwenryFloat   = 0;
        
        UIBezierPath *fivePath = [UIBezierPath bezierPath];
        UIBezierPath *TenPath  = [UIBezierPath bezierPath];
        UIBezierPath *TwenryPath  = [UIBezierPath bezierPath];
        
        __block NSInteger FiveCount = 0;
        __block NSInteger Tencount = 0;
        __block NSInteger Twenrycount = 0;
        
        NSInteger space = KlineCellSpace+KlineCellWidth;
        NSInteger HalfWidth = KlineCellWidth/2;
        
        //5个的均线
        __block NSInteger starIndex = offsetX-fiveLine;//开始展示的获取的数据下标
        __block NSInteger ShowIndex = 0;//开始展示的下标
        if (starIndex < fiveLine) {
            ShowIndex = -starIndex;
        }
        if (starIndex < 0) {
            starIndex = 0;
        }
        //10个的均线
        __block NSInteger starIndexTen = offsetX-tenLine;//开始展示的获取的数据下标
        __block NSInteger ShowIndexTen = 0;//开始展示的下标
        if (starIndexTen < tenLine) {
            ShowIndexTen = -starIndexTen;
        }
        if (starIndexTen < 0) {
            starIndexTen = 0;
        }
        
        //20个的均线
        __block NSInteger starIndexTwenry = offsetX-twenryLine;//开始展示的获取的数据下标
        __block NSInteger ShowIndexTwenry = 0;//开始展示的下标
        if (starIndexTwenry < twenryLine) {
            ShowIndexTwenry = -starIndexTwenry;
        }
        if (starIndexTwenry < 0) {
            starIndexTwenry = 0;
        }
        
        
        [array enumerateObjectsUsingBlock:^(KlineModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            //5的均线
            if (idx >= starIndex) {
                fiveLineFloat += obj.LastPrice;
                FiveCount ++;
                if (FiveCount >= 5) {
                    //下标开始的位置
                    CGFloat fivePrice_x = space*ShowIndex*self.x_scale+HalfWidth;
                    
                    CGFloat fivePrice_y = (fiveLineFloat/5-self.lowerPrice)/self.h;
                    
                    CGPoint point = CGPointMake(fivePrice_x, fivePrice_y);
                    
                    if (FiveCount == 5) {
                        [fivePath moveToPoint:point];
                    }else{
                        [fivePath addLineToPoint:point];
                    }
                    fiveLineFloat -= [[array objectAtIndex:idx-fiveLine] LastPrice];
                    ShowIndex ++;
                }
            }
            //10
            if (idx >= starIndexTen) {
                TenLineFloat += obj.LastPrice;
                Tencount ++;
                if (Tencount >= 10) {
                    //下标开始的位置
                    CGFloat TenPrice_x = space*ShowIndexTen*self.x_scale+HalfWidth;
                    
                    CGFloat TenPrice_y = (TenLineFloat/10-self.lowerPrice)/self.h;
                    
                    CGPoint point = CGPointMake(TenPrice_x, TenPrice_y);
                    
                    if (Tencount == 10) {
                        [TenPath moveToPoint:point];
                    }else{
                        [TenPath addLineToPoint:point];
                    }
                    TenLineFloat -= [[array objectAtIndex:idx-tenLine] LastPrice];
                    ShowIndexTen ++;
                }
            }
            if (idx >= starIndexTwenry) {
                TwenryFloat += obj.LastPrice;
                Twenrycount ++;
                if (Twenrycount >= 20) {
                    //下标开始的位置
                    CGFloat TwenryPrice_x = space*ShowIndexTwenry*self.x_scale+HalfWidth;
                    
                    CGFloat TwenryPrice_y = (TwenryFloat/20-self.lowerPrice)/self.h;
                    
                    CGPoint point = CGPointMake(TwenryPrice_x, TwenryPrice_y);
                    
                    if (Twenrycount == 20) {
                        [TwenryPath moveToPoint:point];
                    }else{
                        [TwenryPath addLineToPoint:point];
                    }
                    TwenryFloat -= [[array objectAtIndex:idx-twenryLine] LastPrice];
                    ShowIndexTwenry ++;
                }
            }
            
        }];
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.fiveMinAP.path = fivePath.CGPath;
            self.TenMinAP.path  = TenPath.CGPath;
            self.TwentyMinAP.path = TwenryPath.CGPath;
            
            [fivePath removeAllPoints];
            [TenPath removeAllPoints];
            [TwenryPath removeAllPoints];
        });
        
        [array removeAllObjects];
    });

}


- (UIColor *) colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([cString length] <6) {
        
        return [UIColor clearColor];
        
    }
    
    // strip 0X if it appears
    
    if ([cString hasPrefix:@"0X"])
        
        cString = [cString substringFromIndex:2];
    
    if ([cString hasPrefix:@"#"])
        
        cString = [cString substringFromIndex:1];
    
    if ([cString length] !=6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    
    NSRange range;
    
    range.location =0;
    
    range.length =2;
    
    
    NSString *rString = [cString substringWithRange:range];
    
    
    range.location =2;
    
    NSString *gString = [cString substringWithRange:range];
    
    
    range.location =4;
    
    NSString *bString = [cString substringWithRange:range];
    
    
    unsigned int r, g, b;
    
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r /255.0f) green:((float) g /255.0f) blue:((float) b /255.0f) alpha:1.0f];
}

@end
