//
//  NetWorkingHelper.m
//  
//
//  Created by CM on 16/3/25.
//  Copyright © 2016年 CM. All rights reserved.
//

#import "NetWorkingHelper.h"
#import "AFNetworking.h"

@implementation NetWorkingHelper

#pragma mark -- 拼接参数 --

+ (NSString *)makeURLString:(NSString *)String{
    
    return [NSString stringWithFormat:@"%@%@",NetWorkBaseUrl,String];
}

#pragma mark -- POST请求 --

+ (void)postWithURLString:(NSString *)URLString
               parameters:(id)parameters
             showHudBlock:(void (^)(void))showHudBlock
          warningHudBlock:(void (^)(NSString *warning))warningBlock
            hidenHudBlock:(void (^)(void))hidenHudBlock
                  success:(void (^)(id responseObject))success
                  failure:(void (^)(NSError *error))failure{
    
    // 如果有HUD 则添加HUD
    if (showHudBlock) {
        showHudBlock();
    }
    // 检查网络状态 并设置 回调 block
    [self checkNetStatusAndDoNetWork:^{
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        // 可以接受的类型
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        // 请求超时时间
        manager.requestSerializer.timeoutInterval = 5;
        // 请求队列的最大并发数
        manager.operationQueue.maxConcurrentOperationCount = 5;
        [manager POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (showHudBlock) {
                // 如果有HUD 则移除HUD
                hidenHudBlock();
            }
            // 调用请求成功回调
            [self requestSucceedResponseObject:responseObject success:success warningBlock:warningBlock];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (showHudBlock) {
                // 如果有HUD 则移除HUD
                hidenHudBlock();
            }
            // 调用请求失败回调
            [self requestFailureError:error failure:failure warningBlock:warningBlock];
        }];
    } showHudBlock:showHudBlock warningBlock:warningBlock hidenHudBlock:hidenHudBlock];
}

#pragma mark -- GET请求 --

+ (void)getWithURLString:(NSString *)URLString
              parameters:(id)parameters
            showHudBlock:(void (^)(void))showHudBlock
         warningHudBlock:(void (^)(NSString *warning))warningHudBlock
           hidenHudBlock:(void (^)(void))hidenHudBlock
                 success:(void (^)(id responseObject))success
                 failure:(void (^)(NSError * error))failure{
    
    if (showHudBlock) {
        showHudBlock();
    }
    [self checkNetStatusAndDoNetWork:^{
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer.timeoutInterval = 5;
        manager.operationQueue.maxConcurrentOperationCount = 5;
        [manager GET:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (showHudBlock) {
                hidenHudBlock();
            }
            [self requestSucceedResponseObject:responseObject success:success warningBlock:warningHudBlock];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (showHudBlock) {
                hidenHudBlock();
            }
            [self requestFailureError:error failure:failure warningBlock:warningHudBlock];
        }];
    } showHudBlock:showHudBlock warningBlock:warningHudBlock hidenHudBlock:hidenHudBlock];
}

#pragma mark -- 上传图片 --

+ (void)uploadWithURLString:(NSString *)URLString
                 parameters:(id)parameters
                uploadParam:(UploadParam *)uploadParam
               showHudBlock:(void (^)(void))showHudBlock
            warningHudBlock:(void (^)(NSString *warning))warningHudBlock
              hidenHudBlock:(void (^)(void))hidenHudBlock
                    success:(void (^)(id responseObject))success
                    failure:(void (^)(NSError * error))failure{
    if (showHudBlock) {
        showHudBlock();
    }
    [self checkNetStatusAndDoNetWork:^{
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            [formData appendPartWithFileData:uploadParam.value name:uploadParam.key fileName:uploadParam.filename mimeType:uploadParam.mimeType];
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (showHudBlock) {
                hidenHudBlock();
            }
            [self requestSucceedResponseObject:responseObject success:success warningBlock:warningHudBlock];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (showHudBlock) {
                hidenHudBlock();
            }
            [self requestFailureError:error failure:failure warningBlock:warningHudBlock];
        }];
//        [manager setTaskDidSendBodyDataBlock:^(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
//            //nytesSent 本次上传了多少字节
//            //totalBytesSent 累计上传了多少字节
//            //totalBytesExpectedToSend 文件有多大，应该上传多少
//            NSLog(@"task %@ progree is %f",task,totalBytesSent*1.0/totalBytesExpectedToSend);
//        }];
        
    } showHudBlock:showHudBlock warningBlock:warningHudBlock hidenHudBlock:hidenHudBlock];
    
}

/**
 检查网络状态

 @param netWork         网络请求
 @param showHudBlock    添加HUD的block
 @param warningHudBlock 展示提示信息HUD的block
 @param hidenHudBlock   移除HUD的block
 */
+ (void)checkNetStatusAndDoNetWork:(void(^)(void))netWork
                      showHudBlock:(void (^)(void))showHudBlock
                      warningBlock:(void(^)(NSString *))warningHudBlock
                     hidenHudBlock:(void (^)(void))hidenHudBlock{
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if (showHudBlock) {
            hidenHudBlock();
        }
        if (status == 1||status ==2) {
            netWork();
        }else{
            if (warningHudBlock) {
                warningHudBlock(@"网络未连接");
            }
        }
    }];
}

/**
 请求成功的回调

 @param responseObject 请求返回的Obj
 @param success        成功block
 @param warningBlock   展示提示信息HUD的block
 */
+ (void)requestSucceedResponseObject:(id _Nullable) responseObject
                             success:(void (^)(id responseObject))success
                        warningBlock:(void (^)(NSString *))warningBlock{
    
    if (success) {
        // 网络请求返回的字典
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        // 请求结果状态码
        NSString *code = [resultDict objectForKey:NetWorkCode];
        if ([code isEqualToString:NetWorkSucceedCode]) {
            /*
             {   code:200
              message:"请求成功"
                 data:{ name:"小明"
                         sex:"男"
                           ....
                      }
             }
             通常网络请求返回的数据的最外层字典只是用来判断请求是否成功的，并没有实质性的内容，所以我们在这里将最外层字典剥开，向内部回调真正的有用数据：
             { name:"小明"
                sex:"男"
                  ....
             }
             在这里解析外层字典，可以让每次网络请求时不必再写 解析外层字典的冗余代码
             */
            NSDictionary *dataDict = [resultDict objectForKey:NetWorkData];
            success(dataDict);
        }else{
            /*
             {   code:400
              message:"查无此人"
                 data:{
                      }
             }
             当请求失败时（服务器有正常的返回值），提示错误信息。
             */
            NSString *message = [NSString stringWithFormat:@"%@",[resultDict objectForKey:NetWorkMessage]];
            if (warningBlock) {
                warningBlock(message);
            }
        }
    }
}

/**
 请求失败的回调

 @param error        请求失败返回的错误
 @param failure      失败回调block
 @param warningBlock 展示提示信息HUD的block
 */
+ (void)requestFailureError:(NSError * _Nonnull)error
                    failure:(void (^)(NSError *error))failure
               warningBlock:(void(^)(NSString *))warningBlock{
    if (failure) {
        failure(error);
        NSString *message = [NSString stringWithFormat:@"Error:%@",error.userInfo[@"NSLocalizedDescription"]];
        if (warningBlock) {
            warningBlock(message);
        }
    }
}
@end
