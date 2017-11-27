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

@interface LFSocketDataDeCode : NSObject

+ (instancetype)shareInstance;


- (id)getFullArrayWithData:(NSData *)data;
@end



