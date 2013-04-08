//
//  GWriteViewController.m
//  GWrite
//
//  Created by Raul Uranga on 4/5/13.
//  Copyright (c) 2013 Raul Uranga. All rights reserved.
//

#import "GWriteViewController.h"
#import "SundownWrapper.h"

@interface GWriteViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *splitView;
@property (assign, nonatomic) CGRect textViewFrame;
@property (assign, nonatomic) CGRect webViewFrame;

@end

@implementation GWriteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHiiden:) name:UIKeyboardWillHideNotification object:nil];
    //
    //Setup Inconsolata font
    [self.textView setFont:[UIFont fontWithName:@"Inconsolata" size:self.textView.font.pointSize]];
    
    UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"pattern"]];
    [self.splitView setBackgroundColor:backgroundColor];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /*/
    id html = [SundownWrapper convertMarkdownString:self.textView.text];
    //NSLog(@"html: %@", html);
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    //NSString *sampleHTML = @"<!DOCTYPE html><html><head><link rel=\"stylesheet\" href=\"bootstrap.min.css\" type=\"text/css\" /><link rel=\"stylesheet\" href=\"main.css\" type=\"text/css\" /></head><body><h1>My First Heading</h1><p>My first paragraph.</p></body></html>";
    
    NSString *sampleHTML = [NSString stringWithFormat:@"<!DOCTYPE html><html><head><link rel='stylesheet' href='bootstrap.min.css' type='text/css' /><link rel='stylesheet' href='main.css' type='text/css' /></head><body>%@</body></html>", html];
    
    [self.webView loadHTMLString:sampleHTML baseURL:baseURL];
    //*/
    [self refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) refresh {
    
    NSString *rawText = self.textView.text;
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.grupow.gwrite.queue", NULL);
    dispatch_async(backgroundQueue, ^(void) {
        
        id html = [SundownWrapper convertMarkdownString:rawText];
        
        NSLog(@"%@", html);
        
        NSString *sampleHTML = [NSString stringWithFormat:@"<!DOCTYPE html><html><head><link rel='stylesheet' href='bootstrap.min.css' type='text/css' /><link rel='stylesheet' href='main.css' type='text/css' /></head><body>%@</body></html>", html];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.webView loadHTMLString:sampleHTML baseURL:baseURL];
        });
    });
    
}

-(void) resizeViewFromKeyboardFrame:(CGRect)keyboardFrame view:(UIView *)theView {
    
    CGRect frame =  theView.frame;
    
    float offset = keyboardFrame.size.height;
    //[UIDevice currentDevice].orientation
    if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)) {
        NSLog(@"code for landscape orientation");
        offset = keyboardFrame.size.width;
    }
    
    frame.size.height -= offset;
    [theView setFrame:frame];

}

#pragma mark -
#pragma mark UIKeyboard Notifications

- (void)keyboardShown:(NSNotification *)note {
    
    CGRect keyboardFrame;
    [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
   
    self.textViewFrame = self.textView.frame;
    self.webViewFrame = self.webView.frame;
    
    [self resizeViewFromKeyboardFrame:keyboardFrame view:self.textView];
    [self resizeViewFromKeyboardFrame:keyboardFrame view:self.webView];
}

- (void)keyboardHiiden:(NSNotification *)note {
    
    [self.textView setFrame:self.textViewFrame];
    [self.webView setFrame:self.webViewFrame];
}

#pragma mark -
#pragma mark UITextFieldDelegate protocl implementation

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ( [text isEqualToString:@"\n"] ) {
        [self refresh];
    }
    return YES;
}

@end
