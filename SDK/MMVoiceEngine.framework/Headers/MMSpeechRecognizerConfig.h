//
//  MMSpeechRecognizerConfig.h
//  MMVoiceEngine
//
//  Created by Morris_ on 2020/11/11.
//

#import <Foundation/Foundation.h>
#import <Speech/SFSpeechRecognitionTaskHint.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMSpeechRecognizerConfig : NSObject

+ (MMSpeechRecognizerConfig *)defaultConfig;
- (instancetype)initWithLocale:(NSLocale *)locale;

/*!
 *  语言设置。
 *
 */
@property (nonatomic, strong) NSLocale *locale;

/*!
 *  语音场景设置。
 *
 */
@property (nonatomic) SFSpeechRecognitionTaskHint defaultTaskHint;

/*!
 *  语音场景设置。
 *
 */
@property (nonatomic, copy) NSArray<NSString *> *contextualStrings;

/*!
 *  扩展参数。
 *
 */
@property (nonatomic, strong, nonnull) NSDictionary *params;

@end

NS_ASSUME_NONNULL_END
