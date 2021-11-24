//
//  SceneDelegate.m
//  MMVoiceEngine-Demo
//
//  Created by Morris_ on 2020/11/10.
//

#import "SceneDelegate.h"
#import <BackgroundTasks/BackgroundTasks.h>
#import "ViewController.h"

@interface SceneDelegate ()

@end

static NSString *const kRefreshTaskId = @"com.encompass.ios.em.background.refresh";
static NSString *const kCleanTaskId = @"com.encompass.ios.em.background.db_cleaning";

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    
//    [self registerBgTask];
}


- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}

- (void)registerBgTask {
    
    if (@available(iOS 13.0, *)) {
        BOOL registerFlag = [[BGTaskScheduler sharedScheduler] registerForTaskWithIdentifier:kRefreshTaskId usingQueue:nil launchHandler:^(__kindof BGTask * _Nonnull task) {
            [self handleAppRefresh:task];
        }];
        if (registerFlag) {
            NSLog(@"注册成功");
        } else {
            NSLog(@"注册失败");
        }
    } else {
        // Fallback on earlier versions
    }
    
    if (@available(iOS 13.0, *)) {
        [[BGTaskScheduler sharedScheduler] registerForTaskWithIdentifier:kCleanTaskId usingQueue:nil launchHandler:^(__kindof BGTask * _Nonnull task) {
            [self handleAppRefresh:task];
        }];
    } else {
        // Fallback on earlier versions
    }
}

- (void)handleAppRefresh:(BGAppRefreshTask *)appRefreshTask  API_AVAILABLE(ios(13.0)){
    
    [self scheduleAppRefresh];
    
    NSLog(@"App刷新====================================================================");
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.maxConcurrentOperationCount = 1;
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:AppViewControllerRefreshNotificationName object:nil];
        
        NSLog(@"操作");
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString *timeString = [dateFormatter stringFromDate:date];
        
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"EMLog.txt"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSData *data = [timeString dataUsingEncoding:NSUTF8StringEncoding];
            [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil];
        } else {
            NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
            NSString *originalContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *content = [originalContent stringByAppendingString:[NSString stringWithFormat:@"\n时间：%@\n", timeString]];
            data = [content dataUsingEncoding:NSUTF8StringEncoding];
            [data writeToFile:filePath atomically:YES];
        }
    }];
    
    appRefreshTask.expirationHandler = ^{
        [queue cancelAllOperations];
    };
    [queue addOperation:operation];
    
    __weak NSBlockOperation *weakOperation = operation;
    operation.completionBlock = ^{
        [appRefreshTask setTaskCompletedWithSuccess:!weakOperation.isCancelled];
    };
}

- (void)scheduleAppRefresh {
    
    if (@available(iOS 13.0, *)) {
        BGAppRefreshTaskRequest *request = [[BGAppRefreshTaskRequest alloc] initWithIdentifier:kRefreshTaskId];
        // 最早1分钟后启动后台任务请求
        request.earliestBeginDate = [NSDate dateWithTimeIntervalSinceNow:1.0 * 60];
        NSError *error = nil;
        [[BGTaskScheduler sharedScheduler] submitTaskRequest:request error:&error];
        if (error) {
            NSLog(@"错误信息：%@", error);
        }
        
    } else {
        // Fallback on earlier versions
    }
}


@end
