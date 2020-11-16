//
//  MMSpeechRecognizerDelegate.h
//  MMVoiceEngine
//
//  Created by Morris_ on 2020/11/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MMSpeechRecognizerDelegate <NSObject>

/*!
 *  开始录音回调
 *  当调用了`start`函数之后，如果没有发生错误则会回调此函数。如果发生错误则回调onError:
 */
- (void)onBeginOfSpeech;

/*!
 *  停止录音回调
 *  当调用了`stop`函数回调此函数。
 *  如果发生错误则回调onCompleted:函数
 */
- (void)onEndOfSpeech:(NSError *)error;

/*!
 *  停止录音回调
 *  当调用了`stop`函数回调此函数。
 *  如果发生错误则回调onCompleted:函数
 */
- (void)onCompleted:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
