//
//  LFIMClient.h
//  LFSocketHelper
//
//  Created by 希洋 on 2017/11/24.
//  Copyright © 2017年 李建伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "LFSocketConfig.h"
#import "LFSendMsgHelper.h"

typedef NS_ENUM(NSInteger, LFSocketConnectStatus) {
    LFSocketConnectStatusDisconnected = 0,  // 未连接
    LFSocketConnectStatusConnecting = 1,     // 连接中
    LFSocketConnectStatusConnected = 2       // 已连接
};

typedef NS_ENUM(NSInteger , LFSocketReadDataType) {
    
    LFSocketReadDataTypeString = 0,       // 字节流
    LFSocketReadDataTypeData   = 1        // 字符流
};


typedef void(^ServiceStatusConnectChangedBlock)(LFSocketConnectStatus status);


@protocol LFSocketDelegate <NSObject>

@optional


/**
 监听服务器发送的数据  根据类型区分为返回为字符串和数据流

 @param data 返回具体数据
 @param dataType 返回数据类型
 */
- (void)lfSocketReadData:(id)data DataType:(LFSocketReadDataType)dataType;

@end

@interface LFIMClient : NSObject

/**delegate*/
@property (nonatomic , strong)id<LFSocketDelegate> delegate;

/**设置当前socket数据传递方式   default is string */
@property (nonatomic , assign)LFSocketReadDataType dataType;

/**
 获取单例

 @return id
 */
+(instancetype) shareInstance;

/**
 初始化 必须设置

 @param config 网络配置
 @param serviceStatusConnectChangedBlock 可以得到当前的网络连接状态
 */
-(void)initialize:(LFSocketConfig *)config serviceStatusConnectChangedBlock:(ServiceStatusConnectChangedBlock )serviceStatusConnectChangedBlock;


/**
 发送消息到服务器 字符串类型

 @param msg 消息实体 注意结束符
 */
- (void)sendMsg:(NSString *)msg;

/**
 发送数据流到服务器

 @param data 数据实体
 */
- (void)sendData:(NSData *)data;

/**
 配置后开始连接
 */
- (void)connectServer;

/**
 断开连接
 */
- (void)disConnectServer;


@end


