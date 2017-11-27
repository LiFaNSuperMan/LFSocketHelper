//
//  NSString+GetFullString.m
//  LFSocketHelper
//
//  Created by 希洋 on 2017/11/27.
//  Copyright © 2017年 李建伟. All rights reserved.
//

#import "NSString+GetFullString.h"

#define SIGN_SOCKET @"\r\n"

static NSString *statisticsString = @"";
static BOOL isNotCompleteSocketData = NO;

@implementation NSString (GetFullString)
- (id)toArrayOrNSDictionary
{
    // 半包
    // 半包 | 全包 |
    // 半包 | 半包
    // 全包 |
    // 全包 | 半包
    
    NSArray *finArray = [[NSArray alloc] init];
    
    // 如果进入这个方法的时候 bool值为yes 说明上次进入的数据是半包 所以说直接进入半包的处理办法中拼接字符串
    // 如果这个bool值为NO 说说是新数据
    
    if (isNotCompleteSocketData)
    {
        
        finArray = [self statisticsSocketDataWithSocketData:self];
        
        return finArray;
        
    }else
    {
        // 这是一个全包数据
        if ([self hasSuffix:SIGN_SOCKET])
        {
            finArray =  [self dealWithSocketDataWith:self];
            
        }else if ([self rangeOfString:SIGN_SOCKET].location != NSNotFound)
        {
            // 这是一个粘包数据
            finArray =  [self dealWithSocketDataWith:self];
        }else
        {
            // 半包数据
            finArray = [self statisticsSocketDataWithSocketData:self];
        }
        
        return finArray;
    }
    
    
}
- (NSArray *)dealWithSocketDataWith:(NSString *)socketDataString
{
    isNotCompleteSocketData = NO;
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
            // 那么后半段一个半包数据  需要执行存储方法 标记bool值
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
        if ([socketString isEqualToString:@"Welcome!"])
        {
            NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"gotoRegister",@"gotoRegister", nil];
            [finArray addObject:dic];
        }else if ([socketString hasPrefix:@"regist-client successfully"])
        {
            NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"successfully",@"successfully", nil];
            [finArray addObject:dic];
        }
        else if ([socketString hasPrefix:@"regist-client failed"])
        {
            NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"failed",@"failed", nil];
            [finArray addObject:dic];
        }
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
    isNotCompleteSocketData = YES;
    statisticsString =  [statisticsString stringByAppendingString:socketData];
    
    NSMutableArray *finArray = [[NSMutableArray alloc] init];
    
    // 判断过来的数据是不是最后一个数据
    
    if ([statisticsString hasSuffix:SIGN_SOCKET])
    {
        // 这是剩下的半包数据 或者半包数据加上新的数据
        finArray = [[socketData dealWithSocketDataWith:statisticsString] mutableCopy];
        statisticsString = @"";
        return finArray;
    }else
    {
        return nil;
    }
}
@end
