//
//  MMSpeechSynthesizer.m
//  MMVoiceEngine
//
//  Created by Morris_ on 2020/11/10.
//

#import "MMSpeechSynthesizer.h"
#import <AVFoundation/AVFoundation.h>

@interface MMSpeechSynthesizer ()<AVSpeechSynthesizerDelegate>

@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;

@end


@implementation MMSpeechSynthesizer

static MMSpeechSynthesizer *_sharedInstance = nil;
static dispatch_once_t onceToken;

- (void)dealloc {

}

+ (instancetype)sharedInstance {
    dispatch_once(&onceToken, ^{
        // Init
        _sharedInstance = [[MMSpeechSynthesizer alloc] init];
    });
    return _sharedInstance;
}

- (void)destroy {
    onceToken = 0;
    _sharedInstance = nil;
}

- (AVSpeechSynthesizer *)synthesizer {
    if (!_synthesizer) {
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
        _synthesizer.delegate = self;
    }
    return _synthesizer;
}


#pragma mark - AVSpeechSynthesizerDelegate



@end
