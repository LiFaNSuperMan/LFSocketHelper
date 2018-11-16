# LFSocketHelper
* 针对的GCDSocket的三次面向对象的封装,包含拆包过程
* Example Code

```
    LFSocketConfig *config = [[LFSocketConfig alloc] init];
    config.host = 'your ip';
    config.port = 'your port';

    LFIMClient *im = [LFIMClient shareInstance];
    im.dataType = LFSocketReadDataTypeData;
    im.delegate = self;
    [im initialize:config serviceStatusConnectChangedBlock:^(LFSocketConnectStatus status) {
        print status;
    }];
    
    //TODO: callback数据
    - (void)lfSocketReadData:(id)data DataType:(LFSocketReadDataType)dataType
    {
        print data;
    }  
```  

* 通过block得到当前连接状态,通过代码得到当前接到消息回调,其余文件对应公司业务需求 可参考,完善中
* LFSocketDataDeCoder为针对socket返回数据的半包粘包解析 解析流程整理中
