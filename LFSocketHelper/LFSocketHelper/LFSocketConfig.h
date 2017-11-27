//
//  LFSocketConfig.h
//  LFSocketHelper
//
//  Created by 希洋 on 2017/11/24.
//  Copyright © 2017年 李建伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LFSocketConfig : NSObject

/**地址*/
@property(nonatomic, copy) NSString *host;
/**端口*/
@property(nonatomic, assign) UInt16 port;

@end
