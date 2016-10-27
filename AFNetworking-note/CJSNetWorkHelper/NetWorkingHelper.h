//
//  NetWorkingHelper.h
//  
//
//  Created by CM on 16/3/25.
//  Copyright © 2016年 CM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UploadParam.h"
#import "NetWorkingConst.h"

@interface NetWorkingHelper : NSObject


/**
 *  拼接参数
 *
 *  @param String 地址
 *  @return 请求的URL
 */
+ (NSString *)makeURLString:(NSString *)String;


/**
 post 请求

 @param URLString       请求地址
 @param parameters      请求参数
 @param showHudBlock    添加HUD的block(不需要可传 nil)
 @param warningHudBlock 展示提示信息HUD的block(不需要可传 nil)
 @param hidenHudBlock   移除HUD的block(不需要可传 nil)
 @param success         成功回调
 @param failure         失败回调
 */
+ (void)postWithURLString:(NSString *)URLString
               parameters:(id)parameters
             showHudBlock:(void (^)(void))showHudBlock
          warningHudBlock:(void (^)(NSString *warning))warningHudBlock
            hidenHudBlock:(void (^)(void))hidenHudBlock
                  success:(void (^)(id responseObject))success
                  failure:(void (^)(NSError *error))failure;
/**
 get 请求
 
 @param URLString       请求地址
 @param parameters      请求参数
 @param showHudBlock    添加HUD的block(不需要可传 nil)
 @param warningHudBlock 展示提示信息HUD的block(不需要可传 nil)
 @param hidenHudBlock   移除HUD的block(不需要可传 nil)
 @param success         成功回调
 @param failure         失败回调
 */
+ (void)getWithURLString:(NSString *)URLString
              parameters:(id)parameters
            showHudBlock:(void (^)(void))showHudBlock
         warningHudBlock:(void (^)(NSString *warning))warningHudBlock
           hidenHudBlock:(void (^)(void))hidenHudBlock
                 success:(void (^)(id responseObject))success
                 failure:(void (^)(NSError *error))failure;


/**
 上传图片

 @param URLString       请求地址
 @param parameters      请求参数
 @param uploadParam     图片参数
 @param showHudBlock    添加HUD的block(不需要可传 nil)
 @param warningHudBlock 展示提示信息HUD的block(不需要可传 nil)
 @param hidenHudBlock   移除HUD的block(不需要可传 nil)
 @param success         成功回调
 @param failure         失败回调
 */
+ (void)uploadWithURLString:(NSString *)URLString
                 parameters:(id)parameters
                uploadParam:(UploadParam *)uploadParam
               showHudBlock:(void (^)(void))showHudBlock
            warningHudBlock:(void (^)(NSString *warning))warningHudBlock
              hidenHudBlock:(void (^)(void))hidenHudBlock
                    success:(void (^)(id responseObject))success
                    failure:(void (^)(NSError * error))failure;
@end
