//
//  LFSocketDataDeCode.h
//  LFSocketHelper
//
//  Created by 希洋 on 2017/11/27.
//  Copyright © 2017年 李建伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocketDetailInfo :NSObject

/**header*/
@property (nonatomic , strong)NSData *header;
/**命令字*/
@property (nonatomic , assign)Byte orderByte;
/**包长*/
@property (nonatomic , assign)u_short c_length;
/**消息主题*/
@property (nonatomic , strong)id baby;
/**orderNum*/
@property (nonatomic , assign)Byte orderNum;
/**异或值*/
@property (nonatomic , assign)Byte chk;
/**taild*/
@property (nonatomic , assign)NSData *taild;

/**是否完整*/
@property (nonatomic , assign)BOOL isFullData;
/**当前数据长度*/
@property (nonatomic , assign)NSInteger dataLength;


@end
@interface SocketMsgModel :NSObject

/**cacheData*/
@property (nonatomic , strong)NSMutableData *cacheData;
/**消息体*/
@property (nonatomic , strong)SocketDetailInfo *info;

@end

@interface LFSocketDataDeCoder : NSObject

+ (instancetype)shareInstance;

/**
  字节流解码 返回的是处理好的socketdetailinfo数据（数组形式）  可自行修改

 @param data socket返回的未处理数据
 @param complete 返回block
 */
- (void)getFullDataArrayWithData:(NSData *)data complete:(void(^)(id data))complete;
/**
 字符流解码 返回的是处理好的string数据（数组形式）  可自行修改
 
 @param data socket返回的未处理数据
 @param complete 返回block
 */
- (void)getFullStringArrayWithData:(NSData *)data complete:(void(^)(id data))complete;
@end



