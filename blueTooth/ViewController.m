//
//  ViewController.m
//  blueTooth
//
//  Created by mac on 17/5/19.
//  Copyright © 2017年 cai. All rights reserved.
//

#import "ViewController.h"
#import <GameKit/GameKit.h>

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, GKPeerPickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;

@property (nonatomic, strong) GKSession *session;//会话类

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)connect:(id)sender {
    
    //创建连接控制器
    GKPeerPickerController *picker = [[GKPeerPickerController alloc] init];
    
    //设置代理  -->获取数据
    picker.delegate = self;
    
    //显示控制器
    [picker show];
}

#pragma mark -代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //获取图片到界面
    self.selectedImageView.image = info[UIImagePickerControllerOriginalImage];
    
    //关闭
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -GKPeerPickerControllerDelegate
/*
 在连接到另一台设备时，会调用
 peerID 另一台设备的ID
 session 用于接收和发送数据
 */
- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session
{
    //保留session
    self.session = session;
    
    //设置句柄  收到数据将会处理
    //实现这个方法 需要实现另一个方法- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context;
    [self.session setDataReceiveHandler:self withContext:nil];
    
    //消失控制器
    [picker dismiss];
    
}

//接收到数据的时候 会调用此方法来处理
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context
{
    //将data转成Image 显示到界面上
    UIImage *image = [UIImage imageWithData:data];
    self.selectedImageView.image = image;
}

- (IBAction)selectImage:(id)sender {
    
    //选择图片
    //是否可用
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        NSLog(@"相册不可用");
        return;
    }
    
    //创建选择器
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    //设置类型
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    //代理
    picker.delegate = self;
    
    //弹出
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)sendImage:(id)sender {
    
    //将Image转成NSData对象 再发送
    NSData *data = UIImageJPEGRepresentation(self.selectedImageView.image, 0.5);
    
    /*
     typedef NS_ENUM(int, GKSendDataMode)
     {
     GKSendDataReliable,   如果发送失败  再次发送
     GKSendDataUnreliable, 发送一次
     */
    [self.session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
