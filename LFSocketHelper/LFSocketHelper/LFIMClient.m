//
//  LFIMClient.m
//  LFSocketHelper
//
//  Created by 希洋 on 2017/11/24.
//  Copyright © 2017年 李建伟. All rights reserved.
//

#import "LFIMClient.h"
#import "LFSendMsgHelper.h"
#import "LFSocketDataDeCoder.h"

@interface LFIMClient()<GCDAsyncSocketDelegate>

/**
 GCDSocket实体
 */
@property (nonatomic , strong)GCDAsyncSocket *socket;
/**
 socket的配置
 */
@property (nonatomic , strong)LFSocketConfig *config;

/**
 当前连接状态
 */
@property(nonatomic,assign)BOOL serviceStatus;

/**
 断线重连
 */
@property(nonatomic,strong)NSTimer *netTimer;

/**
 心跳包
 */
@property(nonatomic,strong)NSTimer *sendTimer;

/**
 检测网络
 */
@property(nonatomic,strong)NSTimer *checkTimer;

/**
 最后一次接到消息的时间
 */
@property(nonatomic,assign)NSTimeInterval lastInteval;

/**
 状态改变得到的block
 */
@property(nonatomic,strong)ServiceStatusConnectChangedBlock serviceStatusConnectChangedBlock;

@end

@implementation LFIMClient


+ (instancetype)shareInstance
{
    static LFIMClient *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance=[[self alloc] init];
    });
    return sharedInstance;
}
-(void)initialize:(LFSocketConfig *)config serviceStatusConnectChangedBlock:(ServiceStatusConnectChangedBlock)serviceStatusConnectChangedBlock
{
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.config = config;
    self.serviceStatusConnectChangedBlock = serviceStatusConnectChangedBlock;
}
#pragma mark - publicAction
-(void)connectServer
{
    if (!self.serviceStatus) {
        NSError *error=nil;
        [self.socket connectToHost:self.config.host onPort:self.config.port error:&error];
        if (error) {
            NSLog(@"--%@",error);
        }
    }
}
-(void)disConnectServer{
    [self.socket disconnect];
}
- (void)sendMsg:(NSString *)msg{
    
}
- (void)sendData:(NSData *)data{

    if (self.serviceStatus) {
        [self.socket writeData:data withTimeout:-1 tag:0];
    }else{
        NSLog(@"连接断开了");
    }
    
}
#pragma mark - GCDSocketDelegate
// 连接成功后 会走到这个回调
- (void)socket:(GCDAsyncSocket*)sock didConnectToHost:(NSString*)host port:(UInt16)port{
    NSLog(@"--连接成功--");
    if (self.serviceStatusConnectChangedBlock) {
        self.serviceStatus = YES;
        self.serviceStatusConnectChangedBlock(LFSocketConnectStatusConnected);
    }
    if (self.netTimer) {
        [self.netTimer invalidate];
        self.netTimer=nil;
    }
    if (!self.sendTimer) {
        self.sendTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(sendTimerAction) userInfo:nil repeats:YES];
    }
    if (!self.checkTimer) {
        self.checkTimer = [NSTimer scheduledTimerWithTimeInterval:13 target:self selector:@selector(checkTimerAction) userInfo:nil repeats:YES];
    }
    
    [sock readDataWithTimeout:-1 tag:0];
}
// 连接失败后 会走到这个回调
- (void)socketDidDisconnect:(GCDAsyncSocket*)sock withError:(NSError*)err{
    NSLog(@"--连接失败--");
    if (self.serviceStatusConnectChangedBlock) {
        self.serviceStatus = NO;
        self.serviceStatusConnectChangedBlock(LFSocketConnectStatusDisconnected);
    }
    sock = nil;
    if (!self.netTimer) {
        self.netTimer=[NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(netTimerAction) userInfo:nil repeats:YES];
    }
    if (self.sendTimer) {
        [self.sendTimer invalidate];
        self.sendTimer=nil;
    }
    if (self.checkTimer) {
        [self.checkTimer invalidate];
        self.checkTimer=nil;
    }
}
// 得到服务器发送的消息
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{

    NSLog(@"---%@",data);
    [self configData:data];
    self.lastInteval=[[NSDate date] timeIntervalSince1970];
    [sock readDataWithTimeout:-1 tag:0];
}
#pragma mark - 数据
- (void)configData:(NSData *)data{
    
    // 此处做半包粘包判断 以及心跳包过滤
    switch (self.dataType) {
        case LFSocketReadDataTypeData:
            {
                [[LFSocketDataDeCoder shareInstance] getFullDataArrayWithData:data complete:^(id data) {
                    NSArray *array = (NSArray *)data;
                    if (array.count == 0 || array == nil) {
                        return;
                    }
                    if ([self.delegate respondsToSelector:@selector(LFSocketReadData:DataType:)]) {
                        [self.delegate LFSocketReadData:array DataType:LFSocketReadDataTypeData];
                    }
                }];
            }
            break;
        case LFSocketReadDataTypeString:
            {
               [[LFSocketDataDeCoder shareInstance] getFullStringArrayWithData:data complete:^(id data) {
                   NSArray *array = (NSArray *)data;
                   if (array.count == 0 || array == nil) {
                       return;
                   }
                   if ([self.delegate respondsToSelector:@selector(LFSocketReadData:DataType:)]) {
                       [self.delegate LFSocketReadData:array DataType:LFSocketReadDataTypeData];
                   }
                }];
            }
            break;
        default:
            break;
    }
}
- (void)netTimerAction
{
    [self connectServer];
}
- (void)sendTimerAction
{
    [self sendData:[LFSendMsgHelper phoneHeartbeat]];
}
// 乒乓检测
- (void)checkTimerAction
{
//    NSTimeInterval interval=[[NSDate date]timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:self.lastInteval]];
//    if (interval>13) {
//        [self disConnectServer];
//    }
}
@end
