//
//  ViewController.m
//  CTRecorder
//
//  Created by Chance_xmu on 16/1/7.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "ViewController.h"
#import "CTRecorderDef.h"

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


}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    //    NSLog(@"touch..");
    UITouch *touch = touches.allObjects[0];
    if (touch.view == _testView1) {
        CTRecordBegin
    }
    
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    UITouch *touch = touches.allObjects[0];
    if (touch.view == _testView1) {
        CTRecordEnd
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
