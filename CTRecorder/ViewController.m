//
//  ViewController.m
//  CTRecorder
//
//  Created by Chance_xmu on 16/1/7.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "ViewController.h"
#import "CTRecorderDef.h"

#define CURRENT_RECORD_TAG @"comic_readerOpen"

@interface ViewController (){

    UILabel *_testView1;
}

@end

@implementation ViewController

-(void)loadView{

    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    _testView1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, CGRectGetWidth(self.view.frame), 50)];
    _testView1.text = @"CLICK ME";
    _testView1.textAlignment = NSTextAlignmentCenter;
    _testView1.backgroundColor = [UIColor grayColor];
    _testView1.userInteractionEnabled = YES;
    [self.view addSubview:_testView1];
    INIT_CTRECORDER_WITH_NAME(@"chance");

}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    //    NSLog(@"touch..");
    UITouch *touch = touches.allObjects[0];
    if (touch.view == _testView1) {
        CTRecordAdvBegin(CURRENT_RECORD_TAG)
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CTRecordAdv(CURRENT_RECORD_TAG,@"request1")
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.211 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CTRecordAdv(CURRENT_RECORD_TAG,@"request2")
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.278 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CTRecordAdv(CURRENT_RECORD_TAG,@"UIiNIT")
    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        CTRecordAdv(@"newTag",@"wait5")
//    });
    
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    UITouch *touch = touches.allObjects[0];
    if (touch.view == _testView1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CTRecordAdvEnd(CURRENT_RECORD_TAG)
        });
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
