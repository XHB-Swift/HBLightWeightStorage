//
//  ViewController.m
//  HBLightWeightStorage
//
//  Created by 谢鸿标 on 2019/11/12.
//  Copyright © 2019 谢鸿标. All rights reserved.
//

#import "ViewController.h"
#import "Sources/HBLightWeightStorage.h"

@interface ViewController ()

@property (nonatomic, strong) HBLightWeightStorage *storage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //创建一个轻量存储对象，同时从本地NSUserDefault加载数据到内存
    self.storage = [HBLightWeightStorage lightWeightStorageWithType:0];
}


@end
