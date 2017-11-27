//
//  LFSendMsgHelper.h
//  LFSocketHelper
//
//  Created by 希洋 on 2017/11/24.
//  Copyright © 2017年 李建伟. All rights reserved.
//


// 针对公司业务对消息体的封装   字节流
#import <Foundation/Foundation.h>

@interface LFSendMsgHelper : NSObject




/**
 登录操作

 @return 返回设置好的data数据
 */
+ (NSData *)phoneSendLoginIn;

/**
 手机向业务服务器发送声音播放地址

 @param audioUrl 声音播放地址
 @return 设置好data
 */
+ (NSData *)phoneSendAudioAddress:(NSString *)audioUrl;

/**
 登出操作

 @return 设置好data
 */
+ (NSData *)phoneSendLoginOut;

/**
 手机向业务服务器发送挂断视频操作

 @return 设置好data
 */
+ (NSData *)phoneSendHangUp;

/**
 手机向业务服务器发送接到应答

 @return 设置好data
 */
+ (NSData *)phoneAckAudio;

/**
 发送心跳包

 @return 设置好data
 */
+ (NSData *)phoneHeartbeat;


@end
