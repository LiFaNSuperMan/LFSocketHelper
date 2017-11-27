# LFSocketHelper
针对的GCDSocket的三次面向对象的封装,包含拆包过程
简单引入即可 
代码如下：

    LFSocketConfig *config = [[LFSocketConfig alloc] init];
    config.host = your ip;
    config.port = your port;

    LFIMClient *im = [LFIMClient shareInstance];
    im.dataType = LFSocketReadDataTypeData;
    im.delegate = self;
    [im initialize:config serviceStatusConnectChangedBlock:^(LFSocketConnectStatus status) {
        self.statusLabel.text = [NSString stringWithFormat:@"%ld",status];
    }];
    
    //代理
    - (void)lfSocketReadData:(id)data DataType:(LFSocketReadDataType)dataType
    {
        NSLog(@"--%@",data);
    }  
    
通过block得到当前连接状态  通过代码得到当前接到消息回调   
其余文件对应公司业务需求 可参考  
完善中
