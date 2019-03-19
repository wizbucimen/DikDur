//
//  InfoViewController.m
//  Dik Dur
//
//  Created by Burak Çiçek on 6.06.2018.
//  Copyright © 2018 UpApp. All rights reserved.
//
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define PDF1 111
#define PDF2 112
#define PDF3 113

#import "InfoViewController.h"

@interface InfoViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textField;
@property (weak, nonatomic) IBOutlet UIButton *article1Button;
@property (weak, nonatomic) IBOutlet UIButton *article2Button;

@end

@implementation InfoViewController{
    UIWebView *webView;
    UIButton *closeButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)pdfButtonAction:(UIButton *)sender {
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    webView.delegate = self;
    NSString *path = @"";
    switch (sender.tag) {
        case PDF1:
            path = [[NSBundle mainBundle] pathForResource:@"dikdur1" ofType:@"pdf"];
            break;
        case PDF2:
            path = [[NSBundle mainBundle] pathForResource:@"dikdur2" ofType:@"pdf"];
            break;
        case PDF3 :
            path = [[NSBundle mainBundle] pathForResource:@"dikdur3" ofType:@"pdf"];
        default:
            break;
}
    NSURL *targetURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [webView loadRequest:request];
    [self.view addSubview:webView];
    
    closeButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-40, 22, 25, 25)];
    [closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventAllEvents];
    [self.view addSubview:closeButton];
}

- (void)closeAction{
    [webView removeFromSuperview];
    [closeButton removeFromSuperview];
    webView = nil;
    closeButton = nil;
}
- (IBAction)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];

}

@end
