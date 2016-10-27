//
//  ViewController.m
//  AFNetworking-note
//
//  Created by mtrcjs on 16/10/1.
//  Copyright © 2016年 CJS. All rights reserved.
//

#import "ViewController.h"
#import "NetWorkingHelper.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NetWorkingHelper postWithURLString:@"" parameters:nil showHudBlock:^{
        
    } warningHudBlock:^(NSString *warning) {
        
        NSLog(@"%@",warning);
        
    } hidenHudBlock:^{
        
    } success:^(id responseObject) {
        
    } failure:^(NSError *error) {
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
