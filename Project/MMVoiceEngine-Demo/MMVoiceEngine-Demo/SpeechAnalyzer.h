//
//  SpeechCommand.h
//  MMVoiceEngine-Demo
//
//  Created by Morris_ on 2021/6/15.
//

#import <Foundation/Foundation.h>
#import <MMVoiceEngine/MMVoiceEngine.h>

NS_ASSUME_NONNULL_BEGIN

@class SpeechAnalyzer;

@protocol SpeechAnalyzerDelegate <NSObject>

@required
- (void)speechAnalyzer:(SpeechAnalyzer *)analyzer recognizedCommand:(NSString *)command;

@end


@interface SpeechAnalyzer : NSObject

@property (nonatomic, strong, readonly) NSDictionary *commandDict;

@property (nonatomic, weak) id <SpeechAnalyzerDelegate> delegate;

- (void)recognize:(SFSpeechRecognitionResult * _Nullable)result;

@end

NS_ASSUME_NONNULL_END
