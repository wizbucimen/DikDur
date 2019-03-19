//
//  HomeViewController
//  Dik Dur
//
//  Created by Burak Çiçek on 6.06.2018.
//  Copyright © 2018 UpApp. All rights reserved.
//

#import "HomeViewController.h"
#import "SettingsViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "HACBarChart.h"
#import "HACBarLayer.h"
#import "MBCircularProgressBarLayer.h"
#import "MBCircularProgressBarView.h"

@import UserNotifications;

@interface HomeViewController () <UNUserNotificationCenterDelegate>
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet HACBarChart *chart;
@property (weak, nonatomic) IBOutlet MBCircularProgressBarView *progressBar;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIView *dashboardView;
@property (weak, nonatomic) IBOutlet UILabel *weeklyLabel;
@property (weak, nonatomic) IBOutlet UILabel *dailyLabel;


@end

@implementation HomeViewController{
    NSMutableArray *data;
    NSUserDefaults *defaults;
    NSTimer *timer;
    NSTimer *timer2;
    int hour;
    int minute;
    long interval;
    long secondsLeft;
    long nowSecond;
    long wakeUpTime;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:)
                                                 name:@"refreshView" object:nil];
    
    _chart.showAxis = YES;   // Show axis line
    _chart.showProgressLabel = YES;   // Show text for bar
    _chart.vertical = YES;   // Orientation chart
    _chart.reverse = NO;   // Orientation chart
    _chart.showDataValue = YES;   // Show value contains _data, or real percent value
    _chart.showCustomText = YES;   // Show custom text, in _data with key kHACCustomText
    _chart.barsMargin = 5;     // Margin between bars
    _chart.sizeLabelProgress = 30;    // Width of label progress text
    _chart.numberDividersAxisY = 8;
    _chart.animationDuration = 2;
//  _chart.axisMaxValue = 1500;    // If no define maxValue, get maxium of _data
    _chart.progressTextColor = [UIColor darkGrayColor];
    _chart.axisYTextColor = [UIColor whiteColor];
    _chart.progressTextFont = [UIFont systemFontOfSize:8]; // [UIFont fontWithName:@"DINCondensed-Bold" size:6];
    _chart.typeBar = HACBarType2;
    _chart.dashedLineColor = [UIColor clearColor];
    _chart.axisXColor = [UIColor blackColor];
    _chart.axisYColor  = [UIColor blackColor];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    data = [[NSMutableArray alloc] init];
    
    [self timerStart];
    [self setNotifications];
    [self drawGraphic];
    }

- (void)refreshView:(NSNotification *) notification {
    [self viewDidLoad];
    data = [[NSMutableArray alloc] init];
    [self drawGraphic];
}

- (void)setNotifications {
    int wake = (int)[defaults integerForKey:@"wakeUpTime"];
    int sleep = (int)[defaults integerForKey:@"sleepTime"];
    int interval = (int)[defaults integerForKey:@"timeInterval"];
    int notifCount = (sleep-wake)/interval;
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center removeAllPendingNotificationRequests];
    [center removeAllDeliveredNotifications];
    
    for (int i = 1; i < notifCount; i++) {
        [self scheduleNotifications:i];
    }
}

- (void)scheduleNotifications:(int)i{
    NSDate *alarmDate = [defaults objectForKey:@"wakeUpDate"];
    int interval = (int)[defaults integerForKey:@"timeInterval"];
    alarmDate = [alarmDate dateByAddingTimeInterval:interval*i];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar setTimeZone:[NSTimeZone localTimeZone]];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:alarmDate];
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
    
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:@"Dik Dur!" arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:@"Sağlıklı Yaşa" arguments:nil];
    content.sound = [UNNotificationSound defaultSound];
    content.categoryIdentifier = @"TIMER_EXPIRED";
    //    content.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
    
    NSString *identifier = [NSString stringWithFormat:@"barbaros_%i",i];
    
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    // Create the custom actions for expired timer notifications.
    UNNotificationAction *snoozeAction = [UNNotificationAction
                                          actionWithIdentifier:@"SNOOZE_ACTION"
                                          title:@"Dik Durdum"
                                          options:UNNotificationActionOptionNone];
    
    UNNotificationAction *stopAction = [UNNotificationAction
                                        actionWithIdentifier:@"STOP_ACTION"
                                        title:@"Delete"
                                        options:UNNotificationActionOptionDestructive];
    
    // Create the category with the custom actions.
    UNNotificationCategory *expiredCategory = [UNNotificationCategory
                                               categoryWithIdentifier:@"TIMER_EXPIRED"
                                               actions:@[snoozeAction, stopAction]
                                               intentIdentifiers:@[]
                                               options:UNNotificationCategoryOptionNone];
    
    // Register the notification categories.
    NSSet *categories = [NSSet setWithObject:expiredCategory];
    [center setNotificationCategories:categories];
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (!error) {
            //            NSLog(@"Local Notification succeeded");
        }
        else {
            NSLog(@"Local Notification failed");
        }
    }];
}

- (void)timerStart {
    if (timer) {
        [timer invalidate];
    }
    
    // ???? Neden var bu?
    if (nowSecond < wakeUpTime){
        nowSecond += 60*60*24;
    }
    
    wakeUpTime = [defaults integerForKey:@"wakeUpTime"];
    long sleepTime = [defaults integerForKey:@"sleepTime"];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate date]];
    
    long nowSecond = ([components hour] * 60 * 60) + ([components minute] * 60) + [components second];

    
    if (((wakeUpTime < sleepTime) && (nowSecond < sleepTime) && (nowSecond > wakeUpTime)) || ((sleepTime < wakeUpTime) && (nowSecond < sleepTime || nowSecond > wakeUpTime))) {
        interval = (int)[defaults integerForKey:@"timeInterval"];
        _progressBar.maxValue = interval;
       
        long timePassedSinceWakeUp = nowSecond - wakeUpTime;
        long lastNotificationIndex = timePassedSinceWakeUp / interval;
        long lastNotificationTime = lastNotificationIndex * interval + wakeUpTime;
        
        secondsLeft = interval - (nowSecond - lastNotificationTime);
        
        timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                 target:self
                                               selector:@selector(countDown)
                                               userInfo:nil
                                                repeats:YES];
    } else {
        _progressBar.value = 0;
    }
}

- (void)countDown {
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate date]];
    
    long nowSecond = ([components hour] * 60 * 60) + ([components minute] * 60) + [components second];
    
    // ???? Neden var bu?
    if (nowSecond < wakeUpTime){
        nowSecond += 60*60*24;
    }
    
    interval = (int)[defaults integerForKey:@"timeInterval"];
    
    long timePassedSinceWakeUp = nowSecond - wakeUpTime;
    long lastNotificationIndex = timePassedSinceWakeUp / interval;
    long lastNotificationTime = lastNotificationIndex * interval + wakeUpTime;
    
    secondsLeft = interval - (nowSecond - lastNotificationTime);
    secondsLeft--;
    _progressBar.value = secondsLeft;
    
    if (secondsLeft == 0) {
        [timer invalidate];
        [self timerStart];
    }
}

- (void)drawGraphic{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"tr_TR"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:locale];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *dateToChange = [NSDate date];
    dateToChange = [dateToChange dateByAddingTimeInterval:-86400 * 7];
    
    UIColor *color = [UIColor colorWithRed:0.000f green:0.620f blue:0.890f alpha:1.0f];
    long weeklyCount = 0;
    
    // Dummy App Store Data 
//    int res = 0;
//
//    for (int i = -7 ; i < 0 ; i ++) {
//        dateToChange = [dateToChange dateByAddingTimeInterval:86400];
//        [formatter setDateFormat:@"yyyy-MM-dd"];
//
//        NSString *stringDate = [formatter stringFromDate:dateToChange];
//        [formatter setDateFormat:@"EEE"];
//
//        int test = arc4random() % 15;
//
//        res =  res + test;
//
//        [data addObject:
//         @{
//           kHACPercentage    :   [NSNumber numberWithInteger:test],
//           kHACColor         :   color,
//           kHACCustomText    :   [NSString stringWithFormat:@"%@ (%i)",[formatter stringFromDate:dateToChange],test]
//           }
//         ];
//
//        _dailyLabel.text = [NSString stringWithFormat:@"%@ Kez", [defaults integerForKey:stringDate] ? [NSNumber numberWithInteger:[defaults integerForKey:stringDate]] : [NSNumber numberWithInteger:test]];
//
//        weeklyCount = weeklyCount + [defaults integerForKey:stringDate];
//        _weeklyLabel.text = [NSString stringWithFormat:@"%i Kez",res];
//
//    }
    
    for (int i = -7 ; i < 0 ; i ++) {
        dateToChange = [dateToChange dateByAddingTimeInterval:86400];
        [formatter setDateFormat:@"yyyy-MM-dd"];

        NSString *stringDate = [formatter stringFromDate:dateToChange];
        [formatter setDateFormat:@"EEE"];

        [data addObject:
             @{
               kHACPercentage    :   [defaults integerForKey:stringDate] ? [NSNumber numberWithInteger:[defaults integerForKey:stringDate]] : [NSNumber numberWithInteger:0],
               kHACColor         :   color,
               kHACCustomText    :   [NSString stringWithFormat:@"%@ (%@)",[formatter stringFromDate:dateToChange],[defaults integerForKey:stringDate] ? [NSNumber numberWithInteger:[defaults integerForKey:stringDate]] : [NSNumber numberWithInteger:0]]
               }
         ];

        _dailyLabel.text = [NSString stringWithFormat:@"%@ Kez", [defaults integerForKey:stringDate] ? [NSNumber numberWithInteger:[defaults integerForKey:stringDate]] : [NSNumber numberWithInteger:0]];

        weeklyCount = weeklyCount + [defaults integerForKey:stringDate];
        _weeklyLabel.text = [NSString stringWithFormat:@"%li Kez", weeklyCount];

    }

    [_chart clearChart];
    _chart.data = data;
    [_chart draw];
}

- (IBAction)settingsButtonAction:(id)sender {
    [self.navigationController pushViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingsViewController"] animated:YES];
}

- (IBAction)infoButtonAction:(id)sender {
    [self.navigationController pushViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"InfoViewController"] animated:YES];
}

@end
