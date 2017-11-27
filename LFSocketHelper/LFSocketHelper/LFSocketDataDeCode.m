//
//  LFSocketDataDeCode.m
//  LFSocketHelper
//
//  Created by 希洋 on 2017/11/27.
//  Copyright © 2017年 李建伟. All rights reserved.
//

#import "LFSocketDataDeCode.h"

@implementation SocketMsgModel


- (NSMutableData *)cacheData{
    if (!_cacheData) {
        _cacheData = [[NSMutableData alloc] init];
    }
    return _cacheData;
}

@end

@implementation SocketDetailInfo

- (NSString *)description{
    return [NSString stringWithFormat:@"%ld-%hu-%@-%hhu-%hhu-%hhu",self.dataLength,self.c_length,self.header,self.orderNum,self.chk,self.orderByte];
}
@end

@interface LFSocketDataDeCode ()

/**model*/
@property (nonatomic , strong)SocketMsgModel *model;


@end


@implementation LFSocketDataDeCode

+ (instancetype)shareInstance
{
    static LFSocketDataDeCode *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance=[[self alloc] init];
    });
    return sharedInstance;
}

- (id)getFullArrayWithData:(NSData *)data{

    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    if (self.model.cacheData.length > 0) {
        // 上次有数据  根据上次的包长找到对应的
        [self.model.cacheData appendData:data];
        NSData *getData = self.model.cacheData;
        self.model.cacheData = nil;
        
        [dataArray addObjectsFromArray:[self getFullArrayWithData:getData]];
    }else{

        // 上次数据已经完结 重新计算生成 或没有上次数据 这是第一次数据
        self.model.info = [[SocketDetailInfo alloc] init];
        // 找到头
        NSData *headerData = [data subdataWithRange:NSMakeRange(0, 2)];
        self.model.info.header = headerData;

        // 找尾 判断是不是半包
        for (int i = 2 ; i < data.length ; i++ ) {
            if (i + 1 >= data.length) { break ;}
            NSData *rangeData = [data subdataWithRange:NSMakeRange(i, 2)];
            if ([rangeData isEqualToData:headerData]) {
                // 完整数据
                self.model.info.isFullData = YES;
                self.model.info.dataLength = i+2;
                self.model.info.taild = rangeData;
                break;
            }
        }
        if (self.model.info.isFullData) {
            // 计算出完整部分的数据体   有可能是粘包
            // 判断是不是粘包
            if (self.model.info.dataLength < data.length) {
                // 是粘包
                NSData *getData = [data subdataWithRange:NSMakeRange(0, self.model.info.dataLength)];
                [self configFullData:getData];
                [dataArray addObject:self.model.info];
                NSData *otherData = [data subdataWithRange:NSMakeRange(self.model.info.dataLength, data.length - self.model.info.dataLength)];
                [dataArray addObjectsFromArray:[self getFullArrayWithData:otherData]];
                
            }else{
                NSData *getData = [data subdataWithRange:NSMakeRange(0, self.model.info.dataLength)];
                [self configFullData:getData];
                [dataArray addObject:self.model.info];
            }
        }else{
            // 不是一个完整的数据  存入缓存 等待下一次的接入
            [self.model.cacheData appendData:data];
        }
    }
    return dataArray;
}
- (void)configFullData:(NSData *)getData{
    // 赋值操作
    Byte order ;
    [[getData subdataWithRange:NSMakeRange(2, 1)] getBytes:&order length:sizeof(order)];
    self.model.info.orderByte = order;
    u_short c_length;
    [[getData subdataWithRange:NSMakeRange(3, 2)] getBytes:&c_length length:sizeof(c_length)];
    self.model.info.c_length =  c_length;
    Byte orderNum ;
    [[getData subdataWithRange:NSMakeRange(getData.length -4 , 1)] getBytes:&orderNum length:sizeof(order)];
    self.model.info.orderNum = orderNum;
    Byte chk ;
    [[getData subdataWithRange:NSMakeRange(getData.length -3, 1)] getBytes:&chk length:sizeof(chk)];
    self.model.info.chk = chk;
//     消息主题还未解析？？？？
    
}
#pragma mark - lan
- (SocketMsgModel *)model{
    if (!_model) {
        _model = [[SocketMsgModel alloc] init];
    }
    return _model;
}
@end
