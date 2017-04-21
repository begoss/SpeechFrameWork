//
//  ViewController.m
//  AVAudioSessionTest
//
//  Created by begoss on 2017/4/1.
//  Copyright © 2017年 begoss. All rights reserved.
//

#import "ViewController.h"
#import <Speech/Speech.h>
#import "HttpTool.h"
#import "SettingsViewController.h"

@interface ViewController () <SFSpeechRecognitionTaskDelegate, SFSpeechRecognizerDelegate>

@property (nonatomic, strong) SFSpeechRecognitionTask *recognitionTask;
@property (nonatomic, strong) SFSpeechRecognizer      *speechRecognizer;
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property (nonatomic, strong) UILabel                 *recognizerLabel;
@property (nonatomic, strong) UIButton                *button1;
@property (nonatomic, strong) UIButton                *editHost;
@property (nonatomic, strong) AVAudioEngine           *audioEngine;
@property (nonatomic, strong) AVAudioInputNode        *inputNode;

@end

@implementation ViewController


- (void)dealloc {
    [self.recognitionTask cancel];
    self.recognitionTask = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:KEY_API_HOST]==nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@"speech.andybear.top" forKey:KEY_API_HOST];
        [[NSUserDefaults standardUserDefaults] setObject:@"80" forKey:KEY_API_PORT];
    }
    
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                NSLog(@"NotDetermined");
                break;
            case SFSpeechRecognizerAuthorizationStatusDenied:
                NSLog(@"Denied");
                break;
            case SFSpeechRecognizerAuthorizationStatusRestricted:
                NSLog(@"Restricted");
                break;
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                NSLog(@"Authorized");
                break;
            default:
                break;
        }
    }];
    [self.view addSubview:self.recognizerLabel];
    [self.view addSubview:self.button1];
//    [self.view addSubview:self.editHost];
    
    //1.创建SFSpeechRecognizer识别实例
    self.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    
    self.audioEngine = [[AVAudioEngine alloc] init];
    /*
     //2.创建识别请求
     SFSpeechURLRecognitionRequest *request = [[SFSpeechURLRecognitionRequest alloc] initWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"101112.mp3" ofType:nil]]];
     
     //3.开始识别任务
     self.recognitionTask = [self recognitionTaskWithRequest1:request];
     */
}

- (void)buttonBegin:(UIButton *)button {
    self.recognizerLabel.text = @"说点什么。。";
    [button setTitle:@"松手识别" forState:UIControlStateNormal];
    [self startRecording];
}

- (void)buttonEnd:(UIButton *)button {
    [self.audioEngine stop];
    [self.recognitionRequest endAudio];
    [button setTitle:@"按下说话" forState:UIControlStateNormal];
}

- (void)recognizeString:(NSString *)str {
    NSString *key = @"-1";
    if ([str rangeOfString:TargetString1].location != NSNotFound) {
        key = @"1";
    }else if ([str rangeOfString:TargetString2].location != NSNotFound) {
        key = @"2";
    }else if ([str rangeOfString:TargetString3].location != NSNotFound) {
        key = @"3";
    }else if ([str rangeOfString:TargetString4].location != NSNotFound) {
        key = @"4";
    }else if ([str rangeOfString:TargetString5].location != NSNotFound) {
        key = @"5";
    }else if ([str rangeOfString:TargetString6].location != NSNotFound) {
        key = @"6";
    }else if (([str rangeOfString:TargetString7_1].location != NSNotFound)||([str rangeOfString:TargetString7_2].location != NSNotFound)) {
        key = @"7";
    }else if ([str rangeOfString:TargetString8].location != NSNotFound) {
        key = @"8";
    }else if ([str rangeOfString:TargetString9].location != NSNotFound) {
        key = @"9";
    }else if ([str rangeOfString:TargetString10].location != NSNotFound) {
        key = @"10";
    }
    if (![key isEqualToString:@"-1"]) {
        [HttpTool getWithPath:[NSString stringWithFormat:@"http://%@:%@/api/change_status",[[NSUserDefaults standardUserDefaults] objectForKey:KEY_API_HOST],[[NSUserDefaults standardUserDefaults] objectForKey:KEY_API_PORT]] params:[NSDictionary dictionaryWithObjectsAndKeys:key, @"status", nil] success:^(id JSON) {
            if ([[JSON objectForKey:@"status"] isEqualToString:@"ok"]) {
                NSLog(@"ok");
            }else {
                NSLog(@"%@",[JSON objectForKey:@"status"]);
            }
        } failure:^(NSError *error) {
            NSLog(@"failure");
        }];
    }
}

- (void)startRecording {
    if (self.recognitionTask != nil) {
        [self.recognitionTask cancel];
        self.recognitionTask = nil;
    }
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    [audioSession setMode:AVAudioSessionModeMeasurement error:nil];
    [audioSession setActive:YES error:nil];
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    self.inputNode = self.audioEngine.inputNode;
    self.recognitionRequest.shouldReportPartialResults = YES;
    self.recognitionTask = [self recognitionTaskWithRequest0:self.recognitionRequest];
    [self.inputNode installTapOnBus:0 bufferSize:1024 format:[self.inputNode outputFormatForBus:0] block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [self.recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    [self.audioEngine prepare];
    [self.audioEngine startAndReturnError:nil];
}

- (void)setHost {
    SettingsViewController *vc = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (SFSpeechRecognitionTask *)recognitionTaskWithRequest0:(SFSpeechRecognitionRequest *)request{
    return [self.speechRecognizer recognitionTaskWithRequest:request resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        BOOL isFinal = NO;
        if (result != nil) {
            NSLog(@"语音识别解析正确--%@", result.bestTranscription.formattedString);
            self.recognizerLabel.text = result.bestTranscription.formattedString;
            isFinal = result.isFinal;
        }
        if (isFinal) {
            NSLog(@"结束");
            [self recognizeString:self.recognizerLabel.text];
            [self.audioEngine stop];
            [self.inputNode removeTapOnBus:0];
            self.recognitionRequest = nil;
            self.recognitionTask = nil;
        }else if (error != nil) {
            NSLog(@"失败:%@",error);
            [self.audioEngine stop];
            [self.inputNode removeTapOnBus:0];
            self.recognitionRequest = nil;
            self.recognitionTask = nil;
        }
    }];
}

- (SFSpeechRecognitionTask *)recognitionTaskWithRequest1:(SFSpeechRecognitionRequest *)request{
    return [self.speechRecognizer recognitionTaskWithRequest:request delegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- SFSpeechRecognitionTaskDelegate

// Called when the task first detects speech in the source audio
- (void)speechRecognitionDidDetectSpeech:(SFSpeechRecognitionTask *)task {
    
}

// Called for all recognitions, including non-final hypothesis
- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didHypothesizeTranscription:(SFTranscription *)transcription {
    
}

// Called only for final recognitions of utterances. No more about the utterance will be reported
- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishRecognition:(SFSpeechRecognitionResult *)recognitionResult {
    self.recognizerLabel.text = recognitionResult.bestTranscription.formattedString;
}

// Called when the task is no longer accepting new audio but may be finishing final processing
- (void)speechRecognitionTaskFinishedReadingAudio:(SFSpeechRecognitionTask *)task {
    
}

// Called when the task has been cancelled, either by client app, the user, or the system
- (void)speechRecognitionTaskWasCancelled:(SFSpeechRecognitionTask *)task {
    
}

// Called when recognition of all requested utterances is finished.
// If successfully is false, the error property of the task will contain error information
- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishSuccessfully:(BOOL)successfully {
    if (successfully) {
        NSLog(@"全部解析完毕");
    }
}

#pragma mark- getter

- (UILabel *)recognizerLabel {
    if (!_recognizerLabel) {
        _recognizerLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-150, SCREEN_HEIGHT/3, 300, 50)];
        _recognizerLabel.numberOfLines = 0;
        _recognizerLabel.textAlignment = UITextAlignmentCenter;
        _recognizerLabel.text = @"按住按钮说话";
        _recognizerLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _recognizerLabel.adjustsFontForContentSizeCategory = YES;
        _recognizerLabel.textColor = [UIColor orangeColor];
    }
    return _recognizerLabel;
}

- (UIButton *)button1 {
    if (!_button1) {
        _button1 = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-60, SCREEN_HEIGHT*2/3, 120, 50)];
        _button1.tag = 1;
        _button1.layer.cornerRadius = 5.0f;
        _button1.backgroundColor = [UIColor grayColor];
        [_button1 setTitle:@"按下说话" forState:UIControlStateNormal];
        [_button1 addTarget:self action:@selector(buttonBegin:) forControlEvents:UIControlEventTouchDown];
        [_button1 addTarget:self action:@selector(buttonEnd:) forControlEvents:UIControlEventTouchUpInside];
        [_button1 addTarget:self action:@selector(buttonEnd:) forControlEvents:UIControlEventTouchUpOutside];
    }
    return _button1;
}

- (UIButton *)editHost {
    if (!_editHost) {
        _editHost = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-60, SCREEN_HEIGHT*2/3+60, 120, 50)];
        _editHost.backgroundColor = [UIColor whiteColor];
        [_editHost addTarget:self action:@selector(setHost) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editHost;
}

@end
