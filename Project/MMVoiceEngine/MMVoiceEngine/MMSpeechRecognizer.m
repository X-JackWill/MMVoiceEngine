//
//  MMSpeechRecognizer.m
//  MMVoiceEngine
//
//  Created by Morris_ on 2020/11/10.
//

#import "MMSpeechRecognizer.h"
#import "MMSpeechRecognizerConfig.h"
#import <AVFoundation/AVFoundation.h>
#import "MMSpeechRecognizerDelegate.h"

@interface MMSpeechRecognizer ()<SFSpeechRecognizerDelegate>

@property (nonatomic, strong) SFSpeechRecognizer *speechRecognizer;
@property (nonatomic, strong) MMSpeechRecognizerConfig *config;
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property (nonatomic, strong) SFSpeechRecognitionTask *recognitionTask;
@property (nonatomic, strong) AVAudioEngine *audioEngine;

@end

@implementation MMSpeechRecognizer

static MMSpeechRecognizer *_sharedInstance = nil;
static dispatch_once_t onceToken;

+ (instancetype)sharedInstance {
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[MMSpeechRecognizer alloc] init];
    });
    return _sharedInstance;
}

- (void)destroy {
    onceToken = 0;
    _sharedInstance = nil;
}

- (void)setConfig:(MMSpeechRecognizerConfig *)config {
    _config = config;
}

- (MMSpeechRecognizerConfig *)config {
    if (!_config) {
        _config = [[MMSpeechRecognizerConfig alloc] init];
    }
    return _config;
}

- (void)start
{
    // Cancel the previous task if it's running.
    if (self.recognitionTask) {
        [self.recognitionTask cancel];
    }
    self.recognitionTask = nil;

    // Configure the audio session for the app.
    NSError *error = nil;
    [AVAudioSession.sharedInstance setCategory:AVAudioSessionCategoryRecord withOptions:AVAudioSessionCategoryOptionDuckOthers error:&error];
    if (error)
    {
        [self onError:error];
        return;
    }
    [AVAudioSession.sharedInstance setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    if (error)
    {
        [self onError:error];
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
        
        NSLog(@"Recognized voice: %@",result.bestTranscription.formattedString);
        NSLog(@"Recognized voice: %@",result.transcriptions);
        NSLog(@"Recognized error: %@",error);

        if (weakSelf.recognitionTask.isFinishing) {
            NSLog(@"Recognized finishing: %d",weakSelf.recognitionTask.isFinishing);
        }
    }];
    
    // Configure the microphone input.
    AVAudioInputNode *inputNode = self.audioEngine.inputNode;
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        if (weakSelf.recognitionRequest) {
            [weakSelf.recognitionRequest appendAudioPCMBuffer:buffer];
        }
    }];
    [self.audioEngine prepare];
    [self.audioEngine startAndReturnError:&error];
    if (error)
    {
        [self onError:error];
        return;
    }
    
    
}

- (void)stop
{
    [self.audioEngine stop];
    [self.recognitionRequest endAudio];
}

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

#pragma mark - 回调

- (void)onError:(NSError *)error
{
//    if ([self.delegate respondsToSelector:@selector(onError:)]) {
//        [self.delegate onError:error];
//    }
}



#pragma mark - get

- (SFSpeechRecognizer *)speechRecognizer {
    if (!_speechRecognizer) {
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
