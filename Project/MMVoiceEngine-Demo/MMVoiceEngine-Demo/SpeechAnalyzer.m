//
//  SpeechCommand.m
//  MMVoiceEngine-Demo
//
//  Created by Morris_ on 2021/6/15.
//

#import "SpeechAnalyzer.h"

@interface SpeechAnalyzer ()

@property (nonatomic, strong, readwrite) NSDictionary *commandDict;

@end

@implementation SpeechAnalyzer

- (instancetype)init {
    if (self = [super init]) {
        
        [self readData];
    }
    return self;
}

- (void)readData
{
    NSString *speechFilePath = [[NSBundle mainBundle] pathForResource:@"speechFile" ofType:@"plist"];
    self.commandDict = [NSDictionary dictionaryWithContentsOfFile:speechFilePath][@"Keys"];
}

- (void)recognize:(SFSpeechRecognitionResult * _Nullable)result
{
    if (result == nil) {
        return;
    }
    
    NSString *bestTranscription = result.bestTranscription.formattedString;
    NSLog(@"bestTranscription: %@",bestTranscription);
    
    [self.commandDict enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([bestTranscription.lowercaseString containsString:key]) {
            if ([self.delegate respondsToSelector:@selector(speechAnalyzer:recognizedCommand:)]) {
                [self callbackInMain:self.commandDict[key]];
            }
            *stop = YES;
        }
    }];
}

- (void)callbackInMain:(NSString *)command {
    if ([NSThread currentThread].isMainThread) {
        [self.delegate speechAnalyzer:self recognizedCommand:command];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate speechAnalyzer:self recognizedCommand:command];
        });
    }
}

@end
