//
//  NetWorkingConst.m
//  CJSNet-Hud
//
//  Created by mtrcjs on 16/9/30.
//  Copyright © 2016年 CJS. All rights reserved.
//

#import "NetWorkingConst.h"

// 测试基地址
#define NetWorkBaseUrl_test @"后台给的测试基地址"
// 生产基地址
#define NetWorkBaseUrl_product @"后台给的生产基地址"

NSString *const TOKEN = @"token";

// 解析外层字典所需参数 参考接口文档自行修改
NSString *const NetWorkCode = @"code";
NSString *const NetWorkMessage = @"message";
NSString *const NetWorkData = @"Data";
NSString *const NetWorkSucceedCode = @"200";
// 基地址
NSString *const NetWorkBaseUrl = NetWorkBaseUrl_product;
// 具体请求地址
NSString *const NetLogin = @"具体请求地址";
