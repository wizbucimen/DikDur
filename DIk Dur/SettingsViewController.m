//
//  SettingsViewController.m
//  Dik Dur
//
//  Created by Burak Çiçek on 6.06.2018.
//  Copyright © 2018 UpApp. All rights reserved.
//

#import "SettingsViewController.h"

@import UserNotifications;

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UITextField *wakeUpTF;
@property (weak, nonatomic) IBOutlet UITextField *sleepTF;
@property (weak, nonatomic) IBOutlet UITextField *intervalTF;

@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *clockResultLabel;

@end

@implementation SettingsViewController{
    UIDatePicker *datePicker;
    NSUserDefaults *defaults;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-250, self.view.frame.size.width, 250)];
    datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"tr_TR"];
    datePicker.datePickerMode = UIDatePickerModeTime;
    datePicker.minuteInterval = 15;
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];

    _wakeUpTF.inputView = datePicker;
    _sleepTF.inputView = datePicker;
    _intervalTF.inputView = datePicker;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _wakeUpTF.text = [defaults objectForKey:@"wake"];
    _sleepTF.text = [defaults objectForKey:@"sleep"];
    _intervalTF.text = [defaults objectForKey:@"interval"];
    
    [self tillHours];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    int sleep = [_sleepTF.text intValue];
    NSLog(@"%i", sleep);

}

- (void)viewWillDisappear:(BOOL)animated {
    [self saveDefauls];
}

- (void)saveDefauls{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *wakeUpDate = [dateFormatter dateFromString:_wakeUpTF.text];
    NSDate *sleepDate = [dateFormatter dateFromString:_sleepTF.text];
    NSDate *intervalDate = [dateFormatter dateFromString:_intervalTF.text];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:wakeUpDate];
    NSInteger hour = [components hour] * 60 * 60;
    NSInteger minute = [components minute] * 60;
    [defaults setObject:_wakeUpTF.text forKey:@"wake"];
    [defaults setInteger:hour + minute forKey:@"wakeUpTime"];
    [defaults setObject:wakeUpDate forKey:@"wakeUpDate"];

    components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:sleepDate];
    hour = [components hour] * 60 * 60;
    minute = [components minute] * 60;
    [defaults setObject:_sleepTF.text forKey:@"sleep"];
    [defaults setInteger:hour + minute forKey:@"sleepTime"];
    [defaults setObject:sleepDate forKey:@"sleepDate"];
    
    components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:intervalDate];
    hour = [components hour] * 60 * 60 ;
    minute = [components minute] * 60 ;
    [defaults setObject:_intervalTF.text forKey:@"interval"];
    [defaults setInteger:hour + minute forKey:@"timeInterval"];
}

- (void)datePickerValueChanged:(id)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    if ([_wakeUpTF isFirstResponder]) {
        _wakeUpTF.text = [dateFormatter stringFromDate:datePicker.date];
//        datePicker.minimumDate = datePicker.date;
    } else if ([_sleepTF isFirstResponder]) {
        _sleepTF.text = [dateFormatter stringFromDate:datePicker.date];
    } else if ([_intervalTF isFirstResponder]) {
        _intervalTF.text = [dateFormatter stringFromDate:datePicker.date];
        
        NSDate *min = [dateFormatter dateFromString:@"00:15"];
        [datePicker setMinimumDate:min];
    }
    
    [self tillHours];
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isFirstResponder]) {
    } else {
        [textField resignFirstResponder];
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    if (textField == _wakeUpTF) {
        datePicker.date = [dateFormatter dateFromString:_wakeUpTF.text];
    } else if (textField == _sleepTF) {
        datePicker.date = [dateFormatter dateFromString:_sleepTF.text];
    } else if (textField == _intervalTF) {
        datePicker.date = [dateFormatter dateFromString:_intervalTF.text];
        
        NSDate *min = [dateFormatter dateFromString:@"00:15"];
        [datePicker setMinimumDate:min];
        
    }
}

- (void)tillHours {
    if (![_wakeUpTF.text isEqualToString:@""] && ![_sleepTF.text isEqualToString:@""]  && ![_intervalTF.text isEqualToString:@""]) {
        NSInteger sleep = [_sleepTF.text intValue];
        NSInteger wake = [_wakeUpTF.text intValue];
            if (sleep > wake) {
                _resultLabel.text = [NSString stringWithFormat:@"%li SAAT BOYUNCA, %@ ARALIKLA BILDIRIM ALACAKSINIZ.",(sleep - wake),_intervalTF.text];
                _clockResultLabel.text = [NSString stringWithFormat:@"%li",(sleep-wake)];
            } else {
                sleep = sleep + 24;
                _resultLabel.text = [NSString stringWithFormat:@"%li SAAT BOYUNCA, %@ ARALIKLA BILDIRIM ALACAKSINIZ.",(sleep - wake),_intervalTF.text];
                _clockResultLabel.text = [NSString stringWithFormat:@"%li",(sleep-wake)];
            }
    }
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)clearData:(id)sender {
    _wakeUpTF.text = @"09.00";
    _sleepTF.text = @"22:00";
    _intervalTF.text = @"00:15";
}
- (IBAction)pauseButtonAction:(id)sender {
    
}
- (IBAction)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];

}

@end
