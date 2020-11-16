//
//  MMSpeechRecognizerConfig.m
//  MMVoiceEngine
//
//  Created by Morris_ on 2020/11/11.
//

#import "MMSpeechRecognizerConfig.h"

@implementation MMSpeechRecognizerConfig

- (instancetype)init {
    if (self = [super init]) {
        self.defaultTaskHint = SFSpeechRecognitionTaskHintUnspecified;
        self.locale = [NSLocale currentLocale];
    }
    return self;
}

@end
