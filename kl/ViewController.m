//
//  ViewController.m
//  kl
//
//  Created by Jia on 16/11/6.
//  Copyright © 2016年 Jia. All rights reserved.
//

#import "ViewController.h"
#import "KlineModel.h"
#import "KlineView.h"
#import "lineView.h"

@interface ViewController ()<lineDataSource>


@property (nonatomic, strong)NSArray *KlineModels;
@property (nonatomic, strong)lineView *line;
@property (nonatomic, assign)NSInteger index;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    KlineModel *model = [KlineModel new];
    
    __weak ViewController *selfWeak = self;
    [model GetModelArray:^(NSArray *dataArray) {
        __strong ViewController *strongSelf = selfWeak;
        strongSelf.KlineModels = dataArray;
    }];
    
    KlineView *kline = [[KlineView alloc] initWithFrame:CGRectMake(0, 200, [UIScreen mainScreen].bounds.size.width, 300) Delegate:self];

    kline.ShowTrackingCross = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        kline.ShowTrackingCross = NO;
    });
    
    [self.view addSubview:kline];

}

- (KlineModel *)LineView:(UIView *)view cellAtIndex:(NSInteger)index;{
    return [self.KlineModels objectAtIndex:index];
}


- (NSInteger)numberOfLineView:(UIView *)view{
    return self.KlineModels.count;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
