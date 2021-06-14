//
//  MMSpeechRecognizer.h
//  MMVoiceEngine
//
//  Created by Morris_ on 2020/11/10.
//

#import <Foundation/Foundation.h>
#import <Speech/Speech.h>

@class MMSpeechRecognizerConfig;

NS_ASSUME_NONNULL_BEGIN

@protocol MMSpeechRecognizerDelegate <NSObject>

@optional

/*!
 *  开始录音回调
 *
 */
- (void)onStart;

/*!
 *
 *
 */
- (void)onStop:(NSError *)error;

/*!
 *
 *
 */
- (void)result:(SFSpeechRecognitionResult * _Nullable)result;

/*!
 *  音量变化回调
 *  在录音过程中，回调音频的音量。
 *
 *  @param volume 音量，范围从
 */
- (void)onVolumeChanged:(int)volume;

@end

/*!
 *  语音识别类，是一个单例对象。
 */
@interface MMSpeechRecognizer : NSObject

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
@property (nonatomic, strong) MMSpeechRecognizerConfig *config;

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
