//
//  MMSpeechRecognizer.m
//  MMVoiceEngine
//
//  Created by Morris_ on 2020/11/10.
//

#import "MMSpeechRecognizer.h"
#import "MMSpeechRecognizerConfig.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface MMSpeechRecognizer ()<SFSpeechRecognizerDelegate>

@property (nonatomic, strong) SFSpeechRecognizer *speechRecognizer;
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property (nonatomic, strong) SFSpeechRecognitionTask *recognitionTask;
@property (nonatomic, strong) AVAudioEngine *audioEngine;

@property (nonatomic, assign) BOOL starting;

@end

@implementation MMSpeechRecognizer

static MMSpeechRecognizer *_sharedInstance = nil;
static dispatch_once_t onceToken;

- (void)dealloc {
    // Remove monitor
    [self removeMonitor];
}

+ (instancetype)sharedInstance {
    dispatch_once(&onceToken, ^{
        // Init
        _sharedInstance = [[MMSpeechRecognizer alloc] init];
        // Add monitor
        [_sharedInstance addMonitor];
    });
    return _sharedInstance;
}

- (void)destroy {
    onceToken = 0;
    _sharedInstance = nil;
}

- (void)setConfig:(MMSpeechRecognizerConfig *)config {
    if (!_config) {
        _config = config;
    }
}

// Start. Private function.
- (void)reStart
{
    // Checking the authorization Status
    [MMSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        if (status == SFSpeechRecognizerAuthorizationStatusAuthorized)
        {
            [self resetRecognitionTask];
            [self startAudioEngine];
        }
        else
        {
            [self stopWithError:[NSError errorWithDomain:[NSString stringWithFormat:@"Authorization :%ld",(long)status] code:-1 userInfo:nil]];
        }
    }];
}

// Start event. Public function.
- (void)start
{
    [self startCallback];
    
    [self reStart];
}

// Stop audioEngine. Private function.
- (void)stopAudioEngine
{
    if (self.audioEngine && self.audioEngine.isRunning) {
        [self.audioEngine stop];
        [self.audioEngine.inputNode removeTapOnBus:0];
        [self.recognitionRequest endAudio];
    }
}
// Start audioEngine. Private function.
- (void)startAudioEngine
{
    [self stopAudioEngine];
    
    // Configure the microphone input.
    AVAudioInputNode *inputNode = self.audioEngine.inputNode;
    [inputNode removeTapOnBus:0];
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    __weak typeof(self)weakSelf = self;
    NSError *error = nil;
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        if (weakSelf.recognitionRequest) {
            [weakSelf.recognitionRequest appendAudioPCMBuffer:buffer];
        }
    }];
    [self.audioEngine prepare];
    [self.audioEngine startAndReturnError:&error];
    if (error)
    {
        [self stopWithError:error];
        return;
    }
}

// Stop event. Private function.
- (void)stopWithError:(NSError *)error
{
    [self stopAudioEngine];
    [self stopCallback:error];
}

// Stop event. Public function.
- (void)stop
{
    [self stopAudioEngine];
    
    [self stopCallback:nil];
}

// Authorization
+ (SFSpeechRecognizerAuthorizationStatus)authorizationStatus
{
    return [SFSpeechRecognizer authorizationStatus];
}
+ (void)requestAuthorization:(void(^)(SFSpeechRecognizerAuthorizationStatus status))handler {
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handler) {
                handler(status);
            }
        });
    }];
}

#pragma mark - SFSpeechRecognizerDelegate

- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available
{
    
}

#pragma mark - call back

- (void)startCallback
{
    if ([self.delegate respondsToSelector:@selector(onStart)]) {
        [self.delegate onStart];
    }
    self.starting = YES;
}

- (void)stopCallback:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(onStop:)]) {
        [self.delegate onStop:error];
    }
    self.starting = NO;
}

- (void)resultCallback:(SFSpeechRecognitionResult * _Nullable)result
{
    if ([self.delegate respondsToSelector:@selector(result:)]) {
        [self.delegate result:result];
    }
}

#pragma mark - private

- (void)resetRecognitionTask
{
    // Cancel the previous task if it's running.
    if (self.recognitionTask) {
        //[self.recognitionTask cancel]; // Will cause the system error and memory problems.
        [self.recognitionTask finish];
    }
    self.recognitionTask = nil;
    
    // Configure the audio session for the app.
    NSError *error = nil;
    [AVAudioSession.sharedInstance setCategory:AVAudioSessionCategoryRecord withOptions:AVAudioSessionCategoryOptionDuckOthers error:&error];
    if (error)
    {
        [self stopWithError:error];
        return;
    }
    [AVAudioSession.sharedInstance setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    if (error)
    {
        [self stopWithError:error];
        return;
    }

    // Create and configure the speech recognition request.
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    self.recognitionRequest.taskHint = SFSpeechRecognitionTaskHintConfirmation;
    
    // Keep speech recognition data on device
    if (@available(iOS 13, *)) {
        self.recognitionRequest.requiresOnDeviceRecognition = NO;
    }

    // Create a recognition task for the speech recognition session.
    // Keep a reference to the task so that it can be canceled.
    __weak typeof(self)weakSelf = self;
    self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        __strong typeof(self)strongSelf = weakSelf;
        //NSLog(@"Recognized voice: %@",result.bestTranscription.formattedString);
        //NSLog(@"Recognized error: %@",error);
        //NSLog(@"Recognized finishing: %d",weakSelf.recognitionTask.isFinishing);
        
        [strongSelf resultCallback:result];
        
        if (error != nil || result.final)
        {
            // Stop recognizing speech if there is a problem.
            [strongSelf stopAudioEngine];
                        
            // Re-Strt
            // [Utility] +[AFAggregator logDictationFailedWithError:] Error Domain=kAFAssistantErrorDomain Code=209 "(null)"
            // [Utility] +[AFAggregator logDictationFailedWithError:] Error Domain=kAFAssistantErrorDomain Code=203 "SessionId=com.siri.cortex.ace.speech.session.event.SpeechSessionId@599be0be, Message=No audio data received." UserInfo={NSLocalizedDescription=SessionId=com.siri.cortex.ace.speech.session.event.SpeechSessionId@599be0be, Message=No audio data received., NSUnderlyingError=0x600002630090 {Error Domain=SiriSpeechErrorDomain Code=102 "(null)"}}
            //[strongSelf reStart];
            
            strongSelf.speechRecognizer = nil;
            [strongSelf performSelector:@selector(reStart) withObject:nil afterDelay:1];
        }
    }];
}

#pragma mark - Monitor

- (void)addMonitor
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)removeMonitor
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)appDidBecomeActive
{
    if (self.starting) {
        [self startAudioEngine];
    }
}

- (void)appDidEnterBackground
{
    if (self.starting) {
        [self stopAudioEngine];
    }
}

#pragma mark - get

- (SFSpeechRecognizer *)speechRecognizer {
    if (!_speechRecognizer) {
        if (!_config) {
            _config = [MMSpeechRecognizerConfig defaultConfig];
        }
        _speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:self.config.locale];
        _speechRecognizer.delegate = self;
    }
    return _speechRecognizer;
}

- (AVAudioEngine *)audioEngine {
    if (!_audioEngine) {
        _audioEngine = [[AVAudioEngine alloc] init];
    }
    return _audioEngine;
}

@end



//AVAudioSession    // 语音设置相关API
//AVAudioEngine     // 记录语音的API
//AVAudioFormat     // 音频的抽象类
//AVAudioInputNode  // 音频节点
//AVAudioPCMBuffer  //


/// 错误码
// 203/201 本次识别任务完成，未识别到任何语音
// 216  几次203/201之后报216，报216时recognitionTask.isFinishing=NO。程序再无反应。
