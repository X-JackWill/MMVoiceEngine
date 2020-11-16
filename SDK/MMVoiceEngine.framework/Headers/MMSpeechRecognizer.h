//
//  MMSpeechRecognizer.h
//  MMVoiceEngine
//
//  Created by Morris_ on 2020/11/10.
//

#import <Foundation/Foundation.h>
#import <Speech/Speech.h>

@class MMSpeechRecognizerConfig;
@protocol MMSpeechRecognizerDelegate;

NS_ASSUME_NONNULL_BEGIN

/*!
 *  语音识别类，是一个单例对象。
 */
@interface MMSpeechRecognizer : NSObject
{
    MMSpeechRecognizerConfig *_config;
}
/*!
 *  返回单例对象
 */
+ (instancetype)sharedInstance;

/*!
 *  销毁单例对象
 */
- (void)destroy;

/*!
*  语音识别参数设置
*/
- (void)setConfig:(MMSpeechRecognizerConfig *)config;

/*!
*  语音识别参数获取
*/
- (MMSpeechRecognizerConfig *)config;

/*!
 *  开始语音识别
 *  即开始录入语音，并识别录入的语音，识别到就会有返回。
 */
- (void)start;

/*!
 *  停止语音识别
 *  即停止语音录入，结束语音识别。
 */
- (void)stop;

/*!
 *  回调
 *
 */
@property (nonatomic, weak) id <MMSpeechRecognizerDelegate> delegate;

/*!
 *  授权
 *
 */
+ (SFSpeechRecognizerAuthorizationStatus)authorizationStatus;
+ (void)requestAuthorization:(void(^)(SFSpeechRecognizerAuthorizationStatus status))handler;

@end

NS_ASSUME_NONNULL_END
