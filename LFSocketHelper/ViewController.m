//
//  ViewController.m
//  LFSocketHelper
//
//  Created by 希洋 on 2017/11/24.
//  Copyright © 2017年 李建伟. All rights reserved.
//

#import "ViewController.h"
#import "LFIMClient.h"

@interface ViewController ()<LFSocketDelegate>


/**im*/
@property (nonatomic , strong)LFIMClient *im;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    LFSocketConfig *config = [[LFSocketConfig alloc] init];
    config.host = @"your ip";
    config.port = 20066;

    LFIMClient *im = [LFIMClient shareInstance];
    im.dataType = LFSocketReadDataTypeData;
    im.delegate = self;
    [im initialize:config serviceStatusConnectChangedBlock:^(LFSocketConnectStatus status) {
        self.statusLabel.text = [NSString stringWithFormat:@"%ld",status];
    }];
    self.im = im;
}
- (IBAction)connectBtnClick:(id)sender {
        [self.im connectServer];
}
- (IBAction)sendDataBtnClick:(id)sender {
    [self.im sendData:[LFSendMsgHelper phoneSendLoginIn]];
}
- (IBAction)disconnectBtnClick:(id)sender {
      [self.im disConnectServer];
}
#pragma mark - delegate
- (void)LFSocketReadData:(id)data DataType:(LFSocketReadDataType)dataType
{
    NSLog(@"--%@",data);
}


@end
