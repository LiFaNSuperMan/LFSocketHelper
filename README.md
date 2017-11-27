# LFSocketHelper
针对的GCDSocket的三次面向对象的封装,包含拆包过程
简单引入即可 
代码如下：

    LFSocketConfig *config = [[LFSocketConfig alloc] init];
    config.host = @"192.168.1.229";
    config.port = 20066;

    LFIMClient *im = [LFIMClient shareInstance];
    im.dataType = LFSocketReadDataTypeData;
    im.delegate = self;
    [im initialize:config serviceStatusConnectChangedBlock:^(LFSocketConnectStatus status) {
        self.statusLabel.text = [NSString stringWithFormat:@"%ld",status];
    }];
    
    
**通过block得到当前连接状态  通过代码得到当前接到消息回调   
**其余文件对应公司业务需求 可参考  
完善中
