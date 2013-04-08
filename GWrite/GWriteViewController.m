//
//  GWriteViewController.m
//  GWrite
//
//  Created by Raul Uranga on 4/5/13.
//  Copyright (c) 2013 Raul Uranga. All rights reserved.
//

#import "GWriteViewController.h"
#import "SundownWrapper.h"

@interface GWriteViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *splitView;

@end

@implementation GWriteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    id html = [SundownWrapper convertMarkdownString:self.textView.text];
    NSLog(@"html: %@", html);
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    //NSString *sampleHTML = @"<!DOCTYPE html><html><head><link rel=\"stylesheet\" href=\"bootstrap.min.css\" type=\"text/css\" /><link rel=\"stylesheet\" href=\"main.css\" type=\"text/css\" /></head><body><h1>My First Heading</h1><p>My first paragraph.</p></body></html>";
    
    NSString *sampleHTML = [NSString stringWithFormat:@"<!DOCTYPE html><html><head><link rel='stylesheet' href='bootstrap.min.css' type='text/css' /><link rel='stylesheet' href='main.css' type='text/css' /></head><body>%@</body></html>", html];
    
    [self.webView loadHTMLString:sampleHTML baseURL:baseURL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
