//
//  LFSocketDataDeCode.m
//  LFSocketHelper
//
//  Created by 希洋 on 2017/11/27.
//  Copyright © 2017年 李建伟. All rights reserved.
//

#import "LFSocketDataDeCoder.h"

#define SIGN_SOCKET @"\r\n"


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

@interface LFSocketDataDeCoder ()

/**datamodel*/
@property (nonatomic , strong)SocketMsgModel *model;



/**cacheString*/
@property (nonatomic , strong)NSString *cacheString;


/**分线程队列*/
@property (nonatomic , strong)dispatch_queue_t queue;

@end


@implementation LFSocketDataDeCoder


+ (instancetype)shareInstance
{
    static LFSocketDataDeCoder *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance=[[self alloc] init];
        sharedInstance.queue = dispatch_queue_create("decodeQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    return sharedInstance;
}
#pragma mark - 字符流解析
- (void)getFullStringArrayWithData:(NSData *)data complete:(void(^)(id data))complete{
    
    dispatch_async(self.queue, ^{
        complete([self decodeData:data]);
    });
}
- (id)decodeString:(NSData *)data{
    
    NSArray *finArray = [[NSArray alloc] init];
    // 如果进入这个方法的时候 bool值为yes 说明上次进入的数据是半包 所以说直接进入半包的处理办法中拼接字符串
    NSString* aStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (self.cacheString.length > 0 )
    {
        finArray = [self statisticsSocketDataWithSocketData:aStr];
        return finArray;
    }else
    {
        // 这是一个全包数据
        if ([aStr hasSuffix:SIGN_SOCKET])
        {
            finArray =  [self dealWithSocketDataWith:aStr];
            
        }else if ([aStr rangeOfString:SIGN_SOCKET].location != NSNotFound)
        {
            // 这是一个粘包数据
            finArray =  [self dealWithSocketDataWith:aStr];
        }else
        {
            // 半包数据
            finArray = [self statisticsSocketDataWithSocketData:aStr];
        }
        return finArray;
    }
}
- (NSArray *)dealWithSocketDataWith:(NSString *)socketDataString
{
    // 处理粘包和半包
    NSMutableArray *finArray = [[NSMutableArray alloc] init];
    NSError *error = nil;
    NSArray *array = [socketDataString componentsSeparatedByString:SIGN_SOCKET];
    NSString *socketString;
    
    for (int i = 0; i<array.count ;i++)
    {
        socketString = array[i];
        //   判断   全包 | 半包  类型
        if (socketString.length != 0 && i == array.count-1)
        {
            // 那么后半段一个半包数据  需要执行存储方法
            [self statisticsSocketDataWithSocketData:socketString];
            break;
        }
        //  全包 |
        if ((socketString.length == 0 && i == array.count-1 )|| [socketString isEqualToString:@"Service-Ping"])
        {
            // 如果这是最后一个数据 并且是全包的结尾 那么这个数据应该是一个空的数据 所以直接跳出循环即可
            break ;
        }
        //  这是一个全包有数据类型   分为welcome 和正常数据类型  正常解析即可
//        if ([socketString isEqualToString:@"Welcome!"])
//        {
//            NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"gotoRegister",@"gotoRegister", nil];
//            [finArray addObject:dic];
//        }else if ([socketString hasPrefix:@"regist-client successfully"])
//        {
//            NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"successfully",@"successfully", nil];
//            [finArray addObject:dic];
//        }
//        else if ([socketString hasPrefix:@"regist-client failed"])
//        {
//            NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"failed",@"failed", nil];
//            [finArray addObject:dic];
//        }
        else
        {
            NSArray *babyArray = [socketString componentsSeparatedByString:@","];
            NSString *type = babyArray[0];
            NSString *jsonString = [socketString substringFromIndex:type.length+1];
            NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableLeaves
                                                              error:&error];
            NSDictionary *finDic = [[NSDictionary alloc] initWithObjectsAndKeys:jsonObject,type,nil];
            
            [finArray addObject:finDic];
        }
    }
    return finArray;
}
- (NSArray *)statisticsSocketDataWithSocketData:(NSString *)socketData
{
    // 如果这是一个半包类型 进入这个方法中 判断这个半包中是否有标识符 如果有这个标识符的的话 就进入全包的处理办法 如果没有的话 就正常拼接字符串即可
    self.cacheString =  [self.cacheString stringByAppendingString:socketData];
    
    NSMutableArray *finArray = [[NSMutableArray alloc] init];
    
    // 判断过来的数据是不是最后一个数据
    
    if ([self.cacheString hasSuffix:SIGN_SOCKET])
    {
        // 这是剩下的半包数据 或者半包数据加上新的数据
        finArray = [[self dealWithSocketDataWith:self.cacheString] mutableCopy];
        self.cacheString = @"";
        return finArray;
    }else
    {
        return nil;
    }
}
#pragma mark - 字节流解析
- (void)getFullDataArrayWithData:(NSData *)data complete:(void(^)(id data)) complete{
    
    dispatch_async(self.queue, ^{
        complete([self decodeData:data]);
    });
}
- (id)decodeData:(NSData *)data{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    if (self.model.cacheData.length > 0) {
        // 上次有数据  根据上次的包长找到对应的
        [self.model.cacheData appendData:data];
        NSData *getData = self.model.cacheData;
        self.model.cacheData = nil;
        [dataArray addObjectsFromArray:[self decodeData:getData]];
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
               [dataArray addObjectsFromArray:[self decodeData:otherData]];
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
//    Byte order ;
//    [[getData subdataWithRange:NSMakeRange(2, 1)] getBytes:&order length:sizeof(order)];
//    self.model.info.orderByte = order;
//    u_short c_length;
//    [[getData subdataWithRange:NSMakeRange(3, 2)] getBytes:&c_length length:sizeof(c_length)];
//    self.model.info.c_length =  c_length;
//    Byte orderNum ;
//    [[getData subdataWithRange:NSMakeRange(getData.length -4 , 1)] getBytes:&orderNum length:sizeof(order)];
//    self.model.info.orderNum = orderNum;
//    Byte chk ;
//    [[getData subdataWithRange:NSMakeRange(getData.length -3, 1)] getBytes:&chk length:sizeof(chk)];
//    self.model.info.chk = chk;
//     消息主题还未解析？？？？
    NSLog(@"<><>-%@",getData);
}
#pragma mark - lan
- (SocketMsgModel *)model{
    if (!_model) {
        _model = [[SocketMsgModel alloc] init];
    }
    return _model;
}
@end
