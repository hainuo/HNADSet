//
//  HNADSet.m
//  HNADSet
//
//  Created by hainuo on 2021/4/28.
//

#import "HNADSet.h"
#import <Leto/Leto.h>
#import <LetoAd/LetoAd.h>
#import <LetoUI/LetoUI.h>
#import <OSETSDK/OSETSDK.h>

@interface HNADSet()
@property (nonatomic, strong)  OSETSplashAd *splashAd;
@property (nonatomic,strong) NSString *splashAdType;
@property (nonatomic, strong) NSObject *splashAdObserver;
@property (nonatomic, strong) UIView *bottomView;
@end

@implementation HNADSet
#pragma mark - Override UZEngine
+ (void)onAppLaunch:(NSDictionary *)launchOptions {
    // 方法在应用启动时被调用
    NSLog(@"HNADSet 被调用了");
}

- (id)initWithUZWebView:(UZWebView *)webView {
    if (self = [super initWithUZWebView:webView]) {
        // 初始化方法
        NSLog(@"HNADSetUZWebView  被调用了");
    }
    return self;
}

- (void)dispose {
    // 方法在模块销毁之前被调用
    NSLog(@"HNADSet  被销毁了");
    [self removeSplashNotification];
}
#pragma mark - HNADSet INIT
JS_METHOD_SYNC(init:(UZModuleMethodContext *)context){

    NSDictionary *params = context.param;
    NSString *appId  = [params stringValueForKey:@"appId" defaultValue:nil];
    if(!appId) {
        return @{@"code":@0,@"msg":@"appId有误！"};
    }
    [OSETManager configure:@"媒体ID"];
    
    [OSETManager openDebugLog]; //打开日志模式(默认关闭)
        NSMutableDictionary *ret=[NSMutableDictionary new];
    
    [ret setValue:[OSETManager version] forKey:@"version"];
    BOOL result = [OSETManager checkConfigure];
    if (result) {
        NSLog(@"注册成功");
        [ret setValue:@1 forKey:@"code"];
        [ret setValue:@"appId注册成功" forKey:@"msg"];
    }else{
        NSLog(@"注册失败");
        [ret setValue:@0 forKey:@"code"];
        [ret setValue:@"appId注册失败" forKey:@"msg"];
    }
    return ret;
}
# pragma mark -- HNADSet SplashAd
-(void) removeSplashNotification {
    if(self.splashAdObserver) {
        NSLog(@"移除通知监听");
        [[NSNotificationCenter defaultCenter] removeObserver:self.splashAdObserver name:@"loadSplashAdObserver" object:nil];
        self.splashAdObserver = nil;
    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadSplashAdObserver" object:@{@"code":@1,@"splashAdType":self.splashAdType,@"eventType":@"doLoad",@"msg":@"广告加载命令执行成功"}];
}
@end
