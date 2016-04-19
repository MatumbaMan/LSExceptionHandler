//
//  ViewController.m
//  LSExceptionHandler
//
//  Created by HouKinglong on 16/4/19.
//  Copyright © 2016年 HouKinglong. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
}

- (void)initView {
    UIButton * crashButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
    [crashButton setTitle:@"Crash" forState:UIControlStateNormal];
    [crashButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    crashButton.layer.borderWidth = 0.1;
    crashButton.layer.borderColor = [UIColor whiteColor].CGColor;
    crashButton.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.3f];
    crashButton.layer.cornerRadius = 2;
    crashButton.clipsToBounds = YES;
    crashButton.center = self.view.center;
    [crashButton addTarget:self action:@selector(testCrash) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:crashButton];
}

- (void)testCrash {
    NSArray * array = @[@"hello,world"];
    NSString * name = [array objectAtIndex:1024];
    NSLog(@"NO.1024 string = %@.", name);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
