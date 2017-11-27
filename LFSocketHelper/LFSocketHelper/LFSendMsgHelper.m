//
//  LFSendMsgHelper.m
//  LFSocketHelper
//
//  Created by 希洋 on 2017/11/24.
//  Copyright © 2017年 李建伟. All rights reserved.
//

#import "LFSendMsgHelper.h"
#import "AppDelegate.h"

#import "LFSocketDataDeCode.h"


@implementation LFSendMsgHelper

#pragma mark - publicAction

static Byte orderNum = -1;

+ (NSData *)phoneSendLoginIn{
    
    NSMutableData *finallyData = [[NSMutableData alloc] init];
    char header[] = {0xAA,0x75,0xA4,0x00,0x00};
    [finallyData appendBytes:header length:sizeof(header)];
    
    NSString *string = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    string = [[string stringByReplacingOccurrencesOfString:@"-" withString:@""] uppercaseString];
    NSData *uuidData = [self convertHexStrToData:string];
    [finallyData appendData:uuidData];
    

    orderNum++;
    if (orderNum > 127) { orderNum = 0;}

    NSData *numData = [NSData dataWithBytes:&orderNum length:sizeof(orderNum)];
    [finallyData appendData:numData];
    
    // 异或值
    Byte *sourceDataPoint = (Byte *)[finallyData bytes];
    Byte end = '\0';

    for (int i = 0 ; i < finallyData.length; i ++) {
        end = sourceDataPoint[i] ^ end;
    }
    NSData *endData = [NSData dataWithBytes:&end length:sizeof(end)];
    [finallyData appendData:endData];

    char tailed[] = {0xAA,0x75};
    [finallyData appendBytes:tailed length:sizeof(tailed)];

    return finallyData;
}

+ (NSData *)phoneSendAudioAddress:(NSString *)audioUrl{
    NSMutableData *data = [[NSMutableData alloc] init];
    return data;
    
}

+ (NSData *)phoneSendLoginOut{
    NSMutableData *data = [[NSMutableData alloc] init];
    return data;
    
}

+ (NSData *)phoneSendHangUp{
    NSMutableData *data = [[NSMutableData alloc] init];
    return data;
}

+ (NSData *)phoneAckAudio{
    NSMutableData *data = [[NSMutableData alloc] init];
    return data;
}
+ (NSData *)phoneHeartbeat{
    NSMutableData *finallyData = [[NSMutableData alloc] init];
    char header[] = {0xAA,0x75,0xA5,0x00,0x00};
    [finallyData appendBytes:header length:sizeof(header)];
    
    NSString *string = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    string = [[string stringByReplacingOccurrencesOfString:@"-" withString:@""] uppercaseString];
    NSData *uuidData = [self convertHexStrToData:string];
    [finallyData appendData:uuidData];
    
    
    orderNum++;
    if (orderNum > 127) { orderNum = 0;}
    
    NSData *numData = [NSData dataWithBytes:&orderNum length:sizeof(orderNum)];
    [finallyData appendData:numData];
    
    // 异或值
    Byte *sourceDataPoint = (Byte *)[finallyData bytes];
    Byte end = '\0';
    
    for (int i = 0 ; i < finallyData.length; i ++) {
        end = sourceDataPoint[i] ^ end;
    }
    NSData *endData = [NSData dataWithBytes:&end length:sizeof(end)];
    [finallyData appendData:endData];
    
    char tailed[] = {0xAA,0x75};
    [finallyData appendBytes:tailed length:sizeof(tailed)];
    
    return finallyData;
}
#pragma mark - private

/**
 手机uuid转设备id码data 发给服务器

 @param str uuid
 @return 修改好的数据
 */
+ (NSMutableData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] %2 == 0) {
        range = NSMakeRange(0,2);
    } else {
        range = NSMakeRange(0,1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    
    return hexData;
}
@end
