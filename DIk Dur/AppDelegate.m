//
//  AppDelegate.m
//  Dik Dur
//
//  Created by Burak Çiçek on 6.06.2018.
//  Copyright © 2018 UpApp. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import "HomeViewController.h"
@import UserNotifications;

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setUserDefaults];

    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
     }];
    
    return YES;
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    NSLog(@"User Info : %@",notification.request.content.userInfo);
    completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
    
    NSLog(@"NOTIF GELDI");
    
//    HomeViewController *vc = [[HomeViewController alloc] init];
//    [vc drawGraphic];
//
//
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"HH:mm"];
//    NSDate *lastNotification = [NSDate date];
//
//    [defaults setObject:lastNotification forKey:@"lastNotification"];
}


- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [NSDate date];
    NSString *currentDate = [dateFormatter stringFromDate:date];
    
//    if ([response.notification.request.content.categoryIdentifier isEqualToString:@"TIMER_EXPIRED"]) {
//        if ([response.actionIdentifier isEqualToString:@"SNOOZE_ACTION"]) {
//            //[defaults setInteger:[defaults integerForKey:currentDate]+1 forKey:currentDate];
//        }
//        else if ([response.actionIdentifier isEqualToString:@"STOP_ACTION"]) {
//
//        }
//    }
    

    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [defaults setInteger:[defaults integerForKey:currentDate]+1 forKey:currentDate];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshView" object:nil];
//        [HomeViewController set]
    } else {
        [defaults setInteger:[defaults integerForKey:currentDate]+1 forKey:currentDate];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshView" object:nil];
    }
}

- (void)application:(UNNotificationRequest *)application didReceiveLocalNotification:(UNNotificationRequest *)notification {

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    application.applicationIconBadgeNumber = 0;

}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    application.applicationIconBadgeNumber = 0;

}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)setUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // First Initiliaze UseR Defaults
    // =====================================================================
    if ([defaults boolForKey:@"first"] == NO) {
        [defaults setBool:YES forKey:@"first"];
        
        [defaults setInteger:32400 forKey:@"wakeUpTime"];
        [defaults setInteger:79200 forKey:@"sleepTime"];
        [defaults setInteger:900 forKey:@"timeInterval"];
        
        [defaults setObject:@"09:00" forKey:@"wake"];
        [defaults setObject:@"22:00" forKey:@"sleep"];
        [defaults setObject:@"00:15" forKey:@"interval"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [dateFormatter setDateFormat:@"HH:mm"];
        
        NSDate *wakeUpDate = [dateFormatter dateFromString:@"09:00"];
        NSDate *sleepDate = [dateFormatter dateFromString:@"22:00"];
//        NSDate *interval = [dateFormatter dateFromString:@"00:15"];
        
        [defaults setObject:wakeUpDate forKey:@"wakeUpDate"];
        [defaults setObject:sleepDate forKey:@"sleepDate"];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *wakeUpDate = [dateFormatter dateFromString:@"09:00"];
    [defaults setObject:wakeUpDate forKey:@"lastNotification"];
}


@end
