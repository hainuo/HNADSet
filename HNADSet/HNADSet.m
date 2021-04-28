//
//  HNADSet.m
//  HNADSet
//
//  Created by hainuo on 2021/4/28.
//

#import "HNADSet.h"
#import <OSETSDK/OSETSDK.h>

@interface HNADSet ()<OSETSplashAdDelegate>
@property (nonatomic, strong)  OSETSplashAd *splashAd;
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
	NSLog(@"appId %@",appId);
	[OSETManager configure:appId];

	[OSETManager openDebugLog]; //打开日志模式(默认关闭)


	NSMutableDictionary *ret=[NSMutableDictionary new];

	[ret setValue:[OSETManager version] forKey:@"version"];
	NSLog(@"操作成功");
	[ret setValue:@1 forKey:@"code"];
	[ret setValue:@"操作成功！" forKey:@"msg"];

	NSLog(@"ret %@",ret);
	return ret;
}
JS_METHOD_SYNC(checkInit:(UZModuleMethodContext *)context){
	NSMutableDictionary *ret=[NSMutableDictionary new];

	[ret setValue:[OSETManager version] forKey:@"version"];
	BOOL result = [OSETManager checkConfigure];
	NSLog(@"结果 %@",result?@1:@0);
	if (result) {
		NSLog(@"注册成功");
		[ret setValue:@1 forKey:@"code"];
		[ret setValue:@"appId register successful" forKey:@"msg"];
	}else{
		NSLog(@"注册失败");
		[ret setValue:@0 forKey:@"code"];
		[ret setValue:@"appId register failed" forKey:@"msg"];
	}
	NSLog(@"ret %@",ret);
	return ret;
}
#pragma mark -- HNADSet SplashAd Action
JS_METHOD(loadSplashAd:(UZModuleMethodContext *)context){
	NSDictionary *params = context.param;
	NSString *adId  = [params stringValueForKey:@"adId" defaultValue:nil];
	UIWindow *window = [UIApplication sharedApplication].windows[0];

	NSString *logoPath = [params stringValueForKey:@"logoPath" defaultValue:nil];
	NSString *fullLogoPath = nil;
	if (logoPath) {
		fullLogoPath = [self getPathWithUZSchemeURL:logoPath];
		NSLog(@"fullLogoPath %@",fullLogoPath);
		UIImageView *imageView = [UIImageView new];
		imageView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100);
		imageView.image = [UIImage imageWithContentsOfFile:fullLogoPath];
		imageView.contentMode = UIViewContentModeCenter;
		_bottomView = imageView;
	}else{
		_bottomView = nil;
	}

	self.splashAd = [[OSETSplashAd alloc] initWithSlotId:adId window:window bottomView:_bottomView];
	self.splashAd.delegate = self;


	NSLog(@"加载开屏广告！");
	[self.splashAd loadAdDataAndShow];


	if(!self.splashAdObserver) {
		__weak typeof(self) _self = self;
		self.splashAdObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"loadSplashAdObserver" object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
		                                 NSLog(@"接收到loadSplashAdObserver通知，%@",note.object);
		                                 __strong typeof(_self) self = _self;
		                                 if(!self) return;
		                                 [context callbackWithRet:note.object err:nil delete:NO];
					 }];
	}

	[context callbackWithRet:@{@"code":@1,@"splashAdType":@"loadSplashAd",@"eventType":@"doLoad",@"msg":@"广告加载命令执行成功"} err:nil delete:NO];
}


-(void) removeSplashNotification {
	if(self.splashAdObserver) {
		NSLog(@"移除通知监听");
		[[NSNotificationCenter defaultCenter] removeObserver:self.splashAdObserver name:@"loadSplashAdObserver" object:nil];
		self.splashAdObserver = nil;
	}
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadSplashAdObserver" object:@{@"code":@1,@"splashAdType":@"loadSplashAd",@"eventType":@"doLoad",@"msg":@"广告加载命令执行成功"}];
}


#pragma mark -- SplashAd delegate

/// 开屏加载成功
/// @param splashAd 开屏实例
/// @param slotId 广告位ID
- (void)splashDidReceiveSuccess:(id)splashAd slotId:(NSString *)slotId {
	NSLog(@"广告位 %@ 广告加载成功！",slotId);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadSplashAdObserver" object:@{@"code":@1,@"splashAdType":@"loadSplashAd",@"eventType":@"adLoaded",@"msg":@"广告加载成功"}];
};

/// 开屏加载失败
- (void)splashLoadToFailed:(id)splashAd error:(NSError *)error {
	NSLog(@"广告加载失败！错误 %@ ",error);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadSplashAdObserver" object:@{@"code":@1,@"splashAdType":@"loadSplashAd",@"eventType":@"adFailed",@"msg":@"广告加载失败",@"userInfo":error.userInfo}];
};

/// 开屏点击
- (void)splashDidClick:(id)splashAd {
	NSLog(@"广告被点击了");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadSplashAdObserver" object:@{@"code":@1,@"splashAdType":@"loadSplashAd",@"eventType":@"adClicked",@"msg":@"广告被点击了"}];
};

/// 开屏关闭
- (void)splashDidClose:(id)splashAd {
	NSLog(@"广告已关闭");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadSplashAdObserver" object:@{@"code":@1,@"splashAdType":@"loadSplashAd",@"eventType":@"adClosed",@"msg":@"广告关闭"}];
    [self removeSplashNotification];
};
/// 开屏将要关闭
- (void)splashWillClose:(id)splashAd {
	NSLog(@"广告即将关闭");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadSplashAdObserver" object:@{@"code":@1,@"splashAdType":@"loadSplashAd",@"eventType":@"addWillClose",@"msg":@"广告即将关闭"}];
};





@end
