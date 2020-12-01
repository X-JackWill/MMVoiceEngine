//
//  MMSpeechRecognizerDelegate.h
//  MMVoiceEngine
//
//  Created by Morris_ on 2020/11/11.
//

#import <Foundation/Foundation.h>

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
 *  音量变化回调<
 *  在录音过程中，回调音频的音量。
 *
 *  @param volume 音量，范围从
 */
- (void)onVolumeChanged:(int)volume;


@end

NS_ASSUME_NONNULL_END
