// AFNetworkReachabilityManager.m
// Copyright (c) 2011–2016 Alamofire Software Foundation ( http://alamofire.org/ )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AFNetworkReachabilityManager.h"
#if !TARGET_OS_WATCH

#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

NSString * const AFNetworkingReachabilityDidChangeNotification = @"com.alamofire.networking.reachability.change";
NSString * const AFNetworkingReachabilityNotificationStatusItem = @"AFNetworkingReachabilityNotificationStatusItem";

/**
 定义了一个 参数是 网络连接状态且 无返回值的 block 即 AFNetworkReachabilityStatusBlock
 
 @param status 网络连接状态
 */
typedef void (^AFNetworkReachabilityStatusBlock)(AFNetworkReachabilityStatus status);

/**
 网络状态字段

 @param status 网络连接状态枚举

 @return 网络连接状态字段
 */
NSString * AFStringFromNetworkReachabilityStatus(AFNetworkReachabilityStatus status) {
    switch (status) {
        case AFNetworkReachabilityStatusNotReachable:
            return NSLocalizedStringFromTable(@"Not Reachable", @"AFNetworking", nil);
        case AFNetworkReachabilityStatusReachableViaWWAN:
            return NSLocalizedStringFromTable(@"Reachable via WWAN", @"AFNetworking", nil);
        case AFNetworkReachabilityStatusReachableViaWiFi:
            return NSLocalizedStringFromTable(@"Reachable via WiFi", @"AFNetworking", nil);
        case AFNetworkReachabilityStatusUnknown:
        default:
            return NSLocalizedStringFromTable(@"Unknown", @"AFNetworking", nil);
    }
}

/**
 通过 flags 来判断当前网络配置状态

 */
static AFNetworkReachabilityStatus AFNetworkReachabilityStatusForFlags(SCNetworkReachabilityFlags flags) {
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));

    AFNetworkReachabilityStatus status = AFNetworkReachabilityStatusUnknown;
    if (isNetworkReachable == NO) {
        status = AFNetworkReachabilityStatusNotReachable;
    }
#if	TARGET_OS_IPHONE
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        status = AFNetworkReachabilityStatusReachableViaWWAN;
    }
#endif
    else {
        status = AFNetworkReachabilityStatusReachableViaWiFi;
    }

    return status;
}

/**
 * Queue a status change notification for the main thread.
 *
 * This is done to ensure that the notifications are received in the same order
 * as they are sent. If notifications are sent directly, it is possible that
 * a queued notification (for an earlier status condition) is processed after
 * the later update, resulting in the listener being left in the wrong state.
 */

/**
 该方法用来 执行回调和发送通知
 */
static void AFPostReachabilityStatusChange(SCNetworkReachabilityFlags flags, AFNetworkReachabilityStatusBlock block) {
    
    // 通过 flags 来 确定网络状态
    AFNetworkReachabilityStatus status = AFNetworkReachabilityStatusForFlags(flags);
    // 返回主线程 执行 block 并发送一个当前网络状态的通知
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) {
            block(status);
        }
        // 发送一个通知 通知当前网络状态
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        NSDictionary *userInfo = @{ AFNetworkingReachabilityNotificationStatusItem: @(status) };
        [notificationCenter postNotificationName:AFNetworkingReachabilityDidChangeNotification object:nil userInfo:userInfo];
    });
}
// 在网络状态变化时 会被调用
static void AFNetworkReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info) {
    AFPostReachabilityStatusChange(flags, (__bridge AFNetworkReachabilityStatusBlock)info);
}

/**
 创建 SCNetworkReachabilityContext 上下文的参数
 
 将Block Copy 到堆上 然后引用计数 ＋ 1
 @param info block

 */
static const void * AFNetworkReachabilityRetainCallback(const void *info) {
    return Block_copy(info);
}


/**
 创建 SCNetworkReachabilityContext 上下文的参数

 @param info block
 */
static void AFNetworkReachabilityReleaseCallback(const void *info) {
    if (info) {
        Block_release(info);
    }
}

@interface AFNetworkReachabilityManager ()

/**
 
 The SCNetworkReachability API allows an application to
 determine the status of a system's current network
 configuration and the reachability of a target host.
 SCNetworkReachability API 允许应用程序确定系统当前网络的状态配置 和 目标主机的可达性。
 
 SCNetworkReachabilityRef : This is the handle to a network address or name
 这是一个 网络地址 或 域名的 句柄
 
 */
@property (readonly, nonatomic, assign) SCNetworkReachabilityRef networkReachability;
/**
 网络连接状态
 */
@property (readwrite, nonatomic, assign) AFNetworkReachabilityStatus networkReachabilityStatus;

/**
 AFNetworkReachabilityStatusBlock类型的block
 */
@property (readwrite, nonatomic, copy) AFNetworkReachabilityStatusBlock networkReachabilityStatusBlock;
@end

@implementation AFNetworkReachabilityManager

+ (instancetype)sharedManager {

    // 单例创建 AFNetworkReachabilityManager
    static AFNetworkReachabilityManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 这段代码只会执行一次
        _sharedManager = [self manager];
    });

    return _sharedManager;
}

/**
 为一个 domain 初始化一个AFNetworkReachabilityManager
 
 @param domain 域名
 
 @return 初始化过的 manager
 */

+ (instancetype)managerForDomain:(NSString *)domain {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [domain UTF8String]);

    AFNetworkReachabilityManager *manager = [[self alloc] initWithReachability:reachability];
    
    CFRelease(reachability);

    return manager;
}

/**
 为一个 sockaddr_in 初始化一个AFNetworkReachabilityManager

 @param address sockaddr_in

 @return 初始化过的 manager
 */
+ (instancetype)managerForAddress:(const void *)address {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)address);
    AFNetworkReachabilityManager *manager = [[self alloc] initWithReachability:reachability];
    CFRelease(reachability);
    
    return manager;
}

/**
 为一个 sockaddr_in 初始化一个AFNetworkReachabilityManager

 @return 初始化过的 manager
 */
+ (instancetype)manager
{
#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000) || (defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    // 声明一个结构体 作为 + (instancetype)managerForAddress:(const void *)address 这个方法的参数
    struct sockaddr_in6 address;
    // bzero 置字节字符串s的前n个字节为零且包括‘\0’
    // 此处调用 bzero 函数 将 sockaddr_in6 这个结构体 全部置零！
    bzero(&address, sizeof(address));
    address.sin6_len = sizeof(address);
    address.sin6_family = AF_INET6;
#else
    struct sockaddr_in address;
    bzero(&address, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
#endif
    return [self managerForAddress:&address];
}

/**
 通过 SCNetworkReachabilityRef 初始化 AFNetworkReachabilityManager
 为AFNetworkReachabilityManager.networkReachabilityStatus
  AFNetworkReachabilityManager.networkReachability 赋值
 */
- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability {
    self = [super init];
    if (!self) {
        return nil;
    }
    // 初始化的manager的 _networkReachability 设置为 CFRetain(reachability)
    _networkReachability = CFRetain(reachability);
    // manager类初始化时 AFNetworkReachabilityStatus 设置为 AFNetworkReachabilityStatusUnknown
    self.networkReachabilityStatus = AFNetworkReachabilityStatusUnknown;

    return self;
}

- (instancetype)init NS_UNAVAILABLE
{
    return nil;
}

- (void)dealloc {
    [self stopMonitoring];
    
    if (_networkReachability != NULL) {
        CFRelease(_networkReachability);
    }
}

#pragma mark -
/**
 判断是否连接网络
 
 */
- (BOOL)isReachable {
    return [self isReachableViaWWAN] || [self isReachableViaWiFi];
}

/**
 判断是否连接WWAN

 */
- (BOOL)isReachableViaWWAN {
    return self.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN;
}
/**
 判断是否连接WiFi
 
 */
- (BOOL)isReachableViaWiFi {
    return self.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi;
}

#pragma mark -

/**
 开始监视网络连接的变化
 本类中，最重要的方法
 */
- (void)startMonitoring {
    [self stopMonitoring];

    if (!self.networkReachability) {
        // 如果 self.networkReachability 没有赋值 则return
        return;
    }
    
    /*
     weakSelf是为了block不持有self，避免循环引用，而再声明一个strongSelf是因为一旦进入block执行，就不允许self在这个执行过程中释放。block执行完后这个strongSelf会自动释放，没有循环引用问题。
     */

    __weak __typeof(self) weakSelf = self;
    
    // 初始化一个 AFNetworkReachabilityStatusBlock
    
    AFNetworkReachabilityStatusBlock callback = ^(AFNetworkReachabilityStatus status) {
        
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        // 更改网络连接状态
        strongSelf.networkReachabilityStatus = status;
        /*
         如果 @property (readwrite, nonatomic, copy) AFNetworkReachabilityStatusBlock networkReachabilityStatusBlock; 这个属性有值，则调用这个 block ，参数为 status
         
         这个 block 在 
         - (void)setReachabilityStatusChangeBlock:(void (^)(AFNetworkReachabilityStatus status))block {
             self.networkReachabilityStatusBlock = block;
         }
         方法中设置
         
         */
        if (strongSelf.networkReachabilityStatusBlock) {
            strongSelf.networkReachabilityStatusBlock(status);
        }

    };
    
    // 创建 SCNetworkReachability 上下文
    SCNetworkReachabilityContext context = {0, (__bridge void *)callback, AFNetworkReachabilityRetainCallback, AFNetworkReachabilityReleaseCallback, NULL};
    
    // 设置回调
    // 这个回调在网络状态变化时 执行
    SCNetworkReachabilitySetCallback(self.networkReachability, AFNetworkReachabilityCallback, &context);
    
    // 加入到 主线程的 Runloop 中 在RunLoop 中监视网络状态
    // Runloop 博客 http://blog.ibireme.com/2015/05/18/runloop/
    //             http://www.jianshu.com/p/2d3c8e084205
    SCNetworkReachabilityScheduleWithRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    
    /*
     异步执行全局并发队列
     在这个方法里判断出了 当前的网络状态
     */
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        
        SCNetworkReachabilityFlags flags;
        /*
         判断 用当前网络配置环境 能否 访问指定主机
         如果当前网络状态是有效的合法的 将为 flags 赋值 并执行 AFPostReachabilityStatusChange
         */
        if (SCNetworkReachabilityGetFlags(self.networkReachability, &flags)) {
            AFPostReachabilityStatusChange(flags, callback);
        }
    });
}

- (void)stopMonitoring {
    if (!self.networkReachability) {
        return;
    }
    // 从 Runloop 中移除
    SCNetworkReachabilityUnscheduleFromRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
}

#pragma mark -

/**
 本地化网络状态

 @return 本地化的网络状态
 */
- (NSString *)localizedNetworkReachabilityStatusString {
    return AFStringFromNetworkReachabilityStatus(self.networkReachabilityStatus);
}

#pragma mark -

/**
 设置网络状态变化时执行的block

 @param block 要执行的block
 */
- (void)setReachabilityStatusChangeBlock:(void (^)(AFNetworkReachabilityStatus status))block {
    self.networkReachabilityStatusBlock = block;
}

#pragma mark - NSKeyValueObserving

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([key isEqualToString:@"reachable"] || [key isEqualToString:@"reachableViaWWAN"] || [key isEqualToString:@"reachableViaWiFi"]) {
        return [NSSet setWithObject:@"networkReachabilityStatus"];
    }

    return [super keyPathsForValuesAffectingValueForKey:key];
}

@end
#endif
