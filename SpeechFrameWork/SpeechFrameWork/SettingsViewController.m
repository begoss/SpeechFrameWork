//
//  SettingsViewController.m
//  SpeechFrameWork
//
//  Created by 刘润东 on 2017/4/21.
//  Copyright © 2017年 begoss. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()<UIAlertViewDelegate>

@property (nonatomic, strong) UITextField *hostTF;
@property (nonatomic, strong) UITextField *portTF;
@property (nonatomic, strong) UIButton *testButton;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.hostTF];
    [self.view addSubview:self.portTF];
    [self.view addSubview:self.testButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveSetting {
    if (self.hostTF.text.length && self.portTF.text.length) {
        [[NSUserDefaults standardUserDefaults] setObject:self.hostTF.text forKey:KEY_API_HOST];
        [[NSUserDefaults standardUserDefaults] setObject:self.portTF.text forKey:KEY_API_PORT];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"修改成功" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    }
}

- (UITextField *)hostTF {
    if (!_hostTF) {
        _hostTF = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-100, 100, 200, 40)];
        _hostTF.placeholder = @"host";
        _hostTF.borderStyle = UITextBorderStyleRoundedRect;
        _hostTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _hostTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
    }
    return _hostTF;
}

- (UITextField *)portTF {
    if (!_portTF) {
        _portTF = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-100, 150, 200, 40)];
        _portTF.placeholder = @"port";
        _portTF.borderStyle = UITextBorderStyleRoundedRect;
        _portTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _portTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
    }
    return _portTF;
}

- (UIButton *)testButton {
    if (!_testButton) {
        _testButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-40, 200, 80, 40)];
        _testButton.layer.cornerRadius = 4.0f;
        _testButton.backgroundColor = [UIColor grayColor];
        [_testButton setTitle:@"确认" forState:UIControlStateNormal];
        [_testButton addTarget:self action:@selector(saveSetting) forControlEvents:UIControlEventTouchUpInside];
    }
    return _testButton;
}

@end
