//
//  ViewController.m
//  MMVoiceEngine-Demo
//
//  Created by Morris_ on 2020/11/10.
//

#import "ViewController.h"
#import <MMVoiceEngine/MMVoiceEngine.h>
#import "SpeechAnalyzer.h"

@interface ViewController ()<MMSpeechRecognizerDelegate, SpeechAnalyzerDelegate>

@property (nonatomic, strong) UIButton *startBtn;
@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) SpeechAnalyzer *speechAnalyzer;

@end

@implementation ViewController

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.startBtn.frame = CGRectMake(10, CGRectGetHeight(self.view.frame)-40-10, CGRectGetWidth(self.view.frame)-20, 40);
    self.textView.frame = CGRectMake(10, 64, CGRectGetWidth(self.view.frame)-20, CGRectGetHeight(self.view.frame)*0.5-64);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 检查授权
    [MMSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                self.startBtn.enabled = YES;
                [self.startBtn setTitle:@"Start Recording" forState:UIControlStateNormal];
                break;
            case SFSpeechRecognizerAuthorizationStatusDenied:
                self.startBtn.enabled = NO;
                [self.startBtn setTitle:@"User denied access to speech recognition" forState:UIControlStateNormal];
                break;
            case SFSpeechRecognizerAuthorizationStatusRestricted:
                self.startBtn.enabled = NO;
                [self.startBtn setTitle:@"Speech recognition restricted on this device" forState:UIControlStateNormal];
                break;
            default:
                self.startBtn.enabled = NO;
                break;
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.startBtn setTitle:@"Start Recording" forState:UIControlStateNormal];
    [self.startBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.startBtn addTarget:self action:@selector(startBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startBtn];
    
    self.textView = [[UITextView alloc] init];
    self.textView.textColor = [UIColor darkGrayColor];
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.userInteractionEnabled = NO;
    [self.view addSubview:self.textView];
}


// MARK:- Event

- (void)startBtnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected)
    {
        MMSpeechRecognizerConfig *config = [[MMSpeechRecognizerConfig alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"en"]];
        [[MMSpeechRecognizer sharedInstance] setConfig:config];
        [MMSpeechRecognizer sharedInstance].delegate = self;
        [[MMSpeechRecognizer sharedInstance] start];
    }
    else
    {
        [[MMSpeechRecognizer sharedInstance] stop];
    }
}

// MARK:- MMSpeechRecognizerDelegate

- (void)onStart
{
    NSLog(@"%s",__func__);
    self.startBtn.enabled = YES;
    [self.startBtn setTitle:@"Stop Recording" forState:UIControlStateNormal];
}

- (void)onStop:(NSError *)error
{
    NSLog(@"%s",__func__);
    self.startBtn.enabled = YES;
    [self.startBtn setTitle:@"Start Recording" forState:UIControlStateNormal];
}

- (void)result:(SFSpeechRecognitionResult * _Nullable)result
{
    [self.speechAnalyzer recognize:result];
}


// MARK:- SpeechAnalyzerDelegate

- (void)speechAnalyzer:(SpeechAnalyzer *)analyzer recognizedCommand:(NSString *)command
{
    NSLog(@"recognizedCommand: %@",command);
    NSLog(@"%@",[NSThread currentThread]);
    self.textView.text = command;
}


// MARK:- lazy load

- (SpeechAnalyzer *)speechAnalyzer {
    if (!_speechAnalyzer) {
        _speechAnalyzer = [[SpeechAnalyzer alloc] init];
        _speechAnalyzer.delegate = self;
    }
    return _speechAnalyzer;
}


@end
