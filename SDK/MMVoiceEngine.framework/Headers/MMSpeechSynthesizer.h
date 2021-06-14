//
//  MMSpeechSynthesizer.h
//  MMVoiceEngine
//
//  Created by Morris_ on 2020/11/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 *  语音合成类。
 */
@interface MMSpeechSynthesizer : NSObject

/*!
 *  语音合成单例对象
 */
+ (instancetype)sharedInstance;

/*!
 *  销毁单例对象
 */
- (void)destroy;

@end

NS_ASSUME_NONNULL_END
